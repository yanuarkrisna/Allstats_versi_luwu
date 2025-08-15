import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class ImageFullScreenPage extends StatelessWidget {
  final String imagePath;

  const ImageFullScreenPage({Key? key, required this.imagePath})
    : super(key: key);

  // Future<void> saveImageToGallery(
  //   String assetPath,
  //   BuildContext context,
  // ) async {
  //   try {
  //     // Ambil bytes dari asset
  //     final bytes = await rootBundle.load(assetPath);
  //     final result = await ImageGallerySaver.saveImage(
  //       bytes.buffer.asUint8List(),
  //       quality: 100,
  //       name: assetPath.split('/').last.split('.').first,
  //     );

  //     if (result['isSuccess'] == true) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('✅ Gambar berhasil disimpan ke galeri')),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('❌ Gagal menyimpan gambar')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('⚠️ Error: $e')));
  //   }
  // }

  Future<Uint8List> loadAssetImageAsBytes(String path) async {
    final byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  }

  Future<void> _saveImage(BuildContext context, String imageOath) async {
    try {
      // 1. Ambil bytes dari assets
      final bytes = await loadAssetImageAsBytes(imagePath);

      // 2. Minta user pilih lokasi simpan
      String? savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan Gambar',
        fileName: imagePath.split('/').last,
        allowedExtensions: ['png'],
        type: FileType.custom,
        bytes: bytes,
      );

      // 3. Simpan file
      if (savePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Tiket tersimpan di: $savePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Penyimpanan dibatalkan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Gagal menyimpan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Zoom')),
      body: Stack(
        children: [
          Center(child: InteractiveViewer(child: Image.asset(imagePath))),
          Positioned(
            bottom: 40,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () => _saveImage(context, imagePath),
              child: const Icon(Icons.download, color: Colors.black),
            ),
          ),
          Text('$imagePath'),
        ],
      ),
    );
  }
}
