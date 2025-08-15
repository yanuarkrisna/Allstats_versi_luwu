import 'package:flutter/material.dart';
import 'package:luwu_stats/indikator_page/indikator_page.dart';
import 'package:luwu_stats/indikator_page/indikator_widgets.dart';
import 'infinite_carousel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'search_page.dart';
import 'package:luwu_stats/models/indikator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  String _selectedYear = '2023';
  late List<Indicator> _filteredIndicators;

  @override
  void initState() {
    super.initState();
    _filteredIndicators = _filterByYear(allIndicators, _selectedYear);
  }

  List<Indicator> _filterByYear(List<Indicator> indicators, String year) {
    return indicators.where((indicator) => indicator.year == year).toList();
  }

  Future<void> downloadImage(int index) async {
    try {
      // 1. Minta user memilih lokasi penyimpanan
      String? savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan File PNG',
        fileName:
            'image_${DateTime.now().millisecondsSinceEpoch}.png', // Nama default
        allowedExtensions: ['png'], // Filter ekstensi
        type: FileType.custom,
      );

      if (savePath != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('File tersimpan di: $savePath')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')),
      );
    }
  }

  Future<String> getAssetPath(String asset) async {
    final byteData = await rootBundle.load(asset);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${asset.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  // fungsi buat menu di tengah itu
  Widget _buildMenuButton(String title, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // Aksi ketika menu diklik
          print('$title tapped');
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  //fungsi buka search page
  void _openSearch(BuildContext context) {
    showSearch(context: context, delegate: StatsSearchDelegate());
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
                colors: [Color.fromARGB(255, 2, 155, 198), Colors.amberAccent],
              ),
            ),
          ),
          title: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/mattapa.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image),
                ),
                const Text('Selamat Datang', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                //nanti aksi login ke gmail
              },
              icon: const Icon(Icons.person, size: 28),
            ),
            IconButton(
              onPressed: () {
                //pop up informasi tentang aplikasi
              },
              icon: const Icon(Icons.info, size: 28),
            ),
          ],
          centerTitle: false,
          backgroundColor: Colors.amber,
          elevation: 2,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              child: Column(
                children: [
                  // Carousel Section
                  Container(child: InfiniteCarousel(images: carouselImages)),

                  //widget menu ditengah yang 2 row itu
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      shrinkWrap: true, // Penting untuk nested scroll
                      physics:
                          const NeverScrollableScrollPhysics(), // Nonaktifkan scroll internal
                      crossAxisCount: 3, // 3 item per baris
                      childAspectRatio: 1.2, // Rasio lebar/tinggi item
                      mainAxisSpacing: 12, // Spasi vertikal antar baris
                      crossAxisSpacing: 12, // Spasi horizontal antar item
                      children: [
                        _buildMenuButton('Publikasi', Icons.library_books),
                        _buildMenuButton(
                          'Indikator Strategis',
                          Icons.assessment,
                        ),
                        _buildMenuButton('Survei Kepuasan', Icons.favorite),
                        _buildMenuButton('Infografis', Icons.pie_chart),
                        _buildMenuButton('Media Sosial', Icons.share),
                        _buildMenuButton('Lainnya', Icons.apps),
                      ],
                    ),
                  ),

                  //widget menu pencarian
                  InkWell(
                    onTap: () => _openSearch(context),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.all(16), // Tambah margin
                      decoration: BoxDecoration(
                        color: Colors.white, // Background putih
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            'Cari data statistik...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  //widget buat tampilan list indikator strategis
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Indikator Strategis',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        YearFilter(
                          selectedYear: _selectedYear,
                          indicators: allIndicators,
                          onYearChanged: (newYear) {
                            setState(() {
                              _selectedYear = newYear;
                              _filteredIndicators = _filterByYear(
                                allIndicators,
                                newYear,
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        //widget list indicator
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredIndicators.length > 3
                              ? 3
                              : _filteredIndicators.length,
                          itemBuilder: (context, index) {
                            return IndicatorCard(
                              indicator: _filteredIndicators[index],
                            );
                          },
                        ),
                        //widget teks liat semua
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IndikatorPage(
                                    indikatorList: allIndicators,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Lihat Semua'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
