import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class BpsPdfViewer extends StatefulWidget {
  final String pdfUrl;

  const BpsPdfViewer({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  _BpsPdfViewerState createState() => _BpsPdfViewerState();
}

class _BpsPdfViewerState extends State<BpsPdfViewer> {
  // Deklarasikan controller tanpa langsung menginisialisasi
  late InAppWebViewController _webViewController;
  bool _isLoading = true;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromARGB(255, 2, 155, 198), Colors.amberAccent],
            ),
          ),
        ),
        title: const Text('Baca Publikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _webViewController.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          Expanded(
            child: InAppWebView(
              // Konfigurasi awal
              initialSettings: InAppWebViewSettings(
                useHybridComposition: true, // Penting untuk Android
                javaScriptEnabled: true,
              ),

              // URL menggunakan Google Docs Viewer
              initialUrlRequest: URLRequest(
                url: WebUri(
                  'https://docs.google.com/viewer?url=${Uri.encodeComponent(widget.pdfUrl)}',
                ),
              ),

              // Inisialisasi controller
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },

              // Handle loading state
              onLoadStart: (controller, url) {
                setState(() {
                  _isLoading = true;
                  _progress = 0;
                });
              },

              onLoadStop: (controller, url) {
                setState(() => _isLoading = false);
              },

              onProgressChanged: (controller, progress) {
                setState(() => _progress = progress.toDouble());
              },

              // Error handling
              onReceivedError: (controller, url, error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${error.description}'),
                    action: SnackBarAction(
                      label: 'Buka di Browser',
                      onPressed: () => launchUrl(Uri.parse(widget.pdfUrl)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
