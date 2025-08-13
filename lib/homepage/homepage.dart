import 'package:flutter/material.dart';
import 'infinite_carousel.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'search_page.dart';
import 'package:luwu_stats/models/indikator.dart';

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

  //buat widget filter tahun
  Widget _buildYearFilter() {
    final years = allIndicators.map((e) => e.year).toSet().toList();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedYear,
              items: years.map((year) {
                return DropdownMenuItem<String>(value: year, child: Text(year));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedYear = newValue!;
                  _filteredIndicators = _filterByYear(
                    allIndicators,
                    _selectedYear,
                  );
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  //widget untuk build card view indikator strategis
  Widget _buildIndicatorCard(Indicator indicator) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(color: Colors.orange, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              indicator.location,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              indicator.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  indicator.value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    indicator.unit,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Method untuk menampilkan semua indikator (semenstara msh popup)
  void _showAllIndicators(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Semua Indikator', style: TextStyle(fontSize: 18)),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredIndicators.length,
                  itemBuilder: (context, index) {
                    return _buildIndicatorCard(_filteredIndicators[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                children: [
                  // Carousel Section
                  InfiniteCarousel(
                    images: carouselImages,
                    onDownload: downloadImage,
                  ),

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
                  Column(
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
                      _buildYearFilter(),
                      const SizedBox(height: 10),
                      //widget list indicator
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredIndicators.length > 3
                            ? 3
                            : _filteredIndicators.length,
                        itemBuilder: (context, index) {
                          return _buildIndicatorCard(
                            _filteredIndicators[index],
                          );
                        },
                      ),
                      //widget teks liat semua
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showAllIndicators(context),
                          child: const Text('Lihat Semua'),
                        ),
                      ),
                    ],
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
