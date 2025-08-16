import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luwu_stats/models/publikasi.dart';
import 'package:luwu_stats/publikasi/publikasi_baca.dart';
import 'package:http/http.dart' as http;

class PublicationFullPage extends StatelessWidget {
  final Publication publication;

  const PublicationFullPage({super.key, required this.publication});

  Future<Uint8List> loadPdfFromNetwork(String pdfUrl) async {
    final response = await http.get(Uri.parse(pdfUrl));
    // Cek apakah file benar-benar PDF (cek header %PDF)
    if (response.bodyBytes.length < 4 ||
        response.bodyBytes[0] != 0x25 ||
        response.bodyBytes[1] != 0x50 ||
        response.bodyBytes[2] != 0x44 ||
        response.bodyBytes[3] != 0x46) {
      throw Exception('File bukan PDF valid');
    }
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load PDF: ${response.statusCode}');
    }
  }

  Future<void> downloadPdf(BuildContext context, String pdfUrl) async {
    try {
      if (pdfUrl.isEmpty) {
        throw Exception('URL PDF kosong');
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('⏳ Memulai download...')));

      final bytes = await loadPdfFromNetwork(pdfUrl);

      String? savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan PDF',
        fileName: '${publication.title}.pdf',
        allowedExtensions: ['pdf'],
        type: FileType.custom,
        bytes: bytes,
      );

      if (savePath != null) {
        await File(savePath).writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Berhasil disimpan di $savePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Penyimpanan dibatalkan')),
        );
      }
    } catch (e) {
      debugPrint('Download error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Gagal: ${e.toString()}')));

      if (e.toString().contains('Connection closed')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File mungkin sudah tersimpan, cek folder download'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        title: Text('Detail Publikasi'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 100, // Space for footer
            ),
            child: Column(
              children: [
                Image.network(
                  publication.cover,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image, size: 80),
                ),
                const SizedBox(height: 20),
                Text(
                  publication.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Tanggal Rilis: ${publication.date}",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text("${publication.abstract}", textAlign: TextAlign.justify),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  //baca pdf
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text('Baca'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BpsPdfViewer(pdfUrl: publication.pdfUrl),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Unduh'),
                      onPressed: () => downloadPdf(context, publication.pdfUrl),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
