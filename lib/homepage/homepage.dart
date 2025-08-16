import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:luwu_stats/indikator_page/indikator_page.dart';
import 'package:luwu_stats/indikator_page/indikator_widgets.dart';
import 'package:luwu_stats/publikasi/publikasi_all.dart';
import 'package:luwu_stats/publikasi/publikasi_card.dart';
import 'infinite_carousel.dart';
import 'search_page.dart';
import 'package:luwu_stats/models/indikator.dart';
import 'package:http/http.dart' as http;
import 'package:luwu_stats/models/publikasi.dart';

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
  List<Publication> publications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _filteredIndicators = _filterByYear(allIndicators, _selectedYear);
  }

  List<Indicator> _filterByYear(List<Indicator> indicators, String year) {
    return indicators.where((indicator) => indicator.year == year).toList();
  }

  // fungsi buat menu di tengah itu
  Widget _buildMenuButton(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
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

  Future<List<Publication>> fetchPublications({int limit = 0}) async {
    const url =
        "https://webapi.bps.go.id/v1/api/list/model/publication/domain/7317/key/20b34b1102b76110c8c41ad3ef5457b7/";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response: $data');

        if (data.containsKey("data") && data["data"] is List) {
          final List<dynamic> dataList = data["data"];
          if (dataList.length > 1 && dataList[1] is List) {
            final List<dynamic> publikasiList = dataList[1];
            var result = publikasiList
                .where((item) => item is Map<String, dynamic>)
                .map((json) => Publication.fromJson(json));

            // Jika limit > 0, ambil sejumlah limit, jika tidak ambil semua
            return limit > 0 ? result.take(limit).toList() : result.toList();
          }
        }
        throw Exception("Struktur data tidak sesuai");
      } else {
        throw Exception("Gagal load publikasi: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching publikasi: $e");
      throw Exception("Terjadi kesalahan: $e");
    }
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
                        _buildMenuButton(
                          'Publikasi',
                          Icons.library_books,
                          () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Memuat semua publikasi...'),
                              ),
                            );
                            try {
                              final allPublications =
                                  await fetchPublications(); // Tanpa limit
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllPublicationsPage(),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal memuat: $e')),
                              );
                            }
                          },
                        ),
                        _buildMenuButton(
                          'Indikator Strategis',
                          Icons.assessment,
                          () {},
                        ),
                        _buildMenuButton(
                          'Survei Kepuasan',
                          Icons.favorite,
                          () {},
                        ),
                        _buildMenuButton('Infografis', Icons.pie_chart, () {}),
                        _buildMenuButton('Media Sosial', Icons.share, () {}),
                        _buildMenuButton('Lainnya', Icons.apps, () {}),
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
                        Text(
                          'Indikator Strategis',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
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
                  const SizedBox(height: 10),
                  //widget container buat publikasi
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Publikasi Terbaru',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        FutureBuilder<List<Publication>>(
                          future: fetchPublications(limit: 3),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text("Error: ${snapshot.error}"),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text("Tidak ada publikasi"),
                              );
                            }

                            final publications = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: publications.length,
                              itemBuilder: (context, index) {
                                return PublicationCard(
                                  pub: publications[index],
                                );
                              },
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Memuat semua publikasi...'),
                                ),
                              );
                              try {
                                final allPublications =
                                    await fetchPublications(); // Tanpa limit
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AllPublicationsPage(),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal memuat: $e')),
                                );
                              }
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
