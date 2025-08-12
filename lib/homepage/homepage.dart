import 'package:flutter/material.dart';
import 'infinite_carousel.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> {
  final List<String> carouselImages = [
    'assets/images/maklumat.png',
    'assets/images/oneapp.png',
    'assets/images/merdeka2025.png',
  ];

  Future<void> downloadImage(int index) async {
    // Request izin penyimpanan
    if (await Permission.storage.request().isGranted) {
      final dir = await getExternalStorageDirectory();
      final imagePath = await getAssetPath(carouselImages[index]);

      await FlutterDownloader.enqueue(
        url: 'file://$imagePath',
        savedDir: dir!.path,
        fileName: 'image_${DateTime.now().millisecondsSinceEpoch}.png',
        showNotification: true,
        openFileFromNotification: true,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Izin penyimpanan ditolak')));
    }
  }

  Future<String> getAssetPath(String asset) async {
    final byteData = await rootBundle.load(asset);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${asset.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 218, 88, 7),
                  Color.fromARGB(255, 218, 88, 7),
                  Color.fromARGB(255, 218, 88, 7),
                  Colors.amberAccent,
                ],
              ),
            ),
          ),
          title: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Image.asset(
              'assets/images/mattapa.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.person, size: 28),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.info, size: 28),
            ),
          ],
          centerTitle: false,
          backgroundColor: Colors.amber,
          elevation: 2,
        ),
        body: Column(
          children: [
            // Carousel Section
            InfiniteCarousel(images: carouselImages, onDownload: downloadImage),
          ],
        ),
      ),
    );
  }
}
