import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luwu_stats/models/publikasi.dart';
import 'package:luwu_stats/publikasi/publikasi_detail.dart';

class AllPublicationsPage extends StatefulWidget {
  const AllPublicationsPage({Key? key}) : super(key: key);

  @override
  _AllPublicationsPageState createState() => _AllPublicationsPageState();
}

class _AllPublicationsPageState extends State<AllPublicationsPage> {
  //final PublicationService _service = PublicationService();
  final List<Publication> _publications = [];
  List<Publication> _filteredPublications = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchController = TextEditingController();
  String _selectedYear = 'Semua';
  String _sortBy = 'Terbaru';
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadMorePublications();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadMorePublications();
      }
    });
    _searchController.addListener(() {
      _onSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // generate tahun dari sekarang sampai 2009
  List<String> get _years {
    final now = DateTime.now().year;
    return ["Semua", for (int y = now; y >= 2009; y--) y.toString()];
  }

  //fetch per keyword dan page
  Future<Map<String, dynamic>> _fetchPublications({
    required int page,
    required String year,
    String? keyword,
  }) async {
    final baseUrl =
        "https://webapi.bps.go.id/v1/api/list/model/publication/lang/ind/domain/7317";
    final key = "20b34b1102b76110c8c41ad3ef5457b7";

    String url;

    if (keyword != null && keyword.isNotEmpty) {
      final encoded = Uri.encodeComponent(keyword);
      url = "$baseUrl/page/$page/keyword/$encoded/key/$key/";
    } else if (year != "Semua") {
      url = "$baseUrl/year/$year/page/$page/key/$key/";
    } else {
      url = "$baseUrl/page/$page/key/$key/";
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["data"] == null || data["data"].length < 2) {
        return {"publications": [], "totalPages": 1};
      }
      final list = data["data"][1] as List<dynamic>;
      final totalPages = data["data"][0]["pages"] ?? 1;

      return {
        "publications": list.map((e) => Publication.fromJson(e)).toList(),
        "totalPages": totalPages,
      };
    } else {
      throw Exception("Gagal ambil data publikasi");
    }
  }

  Future<void> _onSearch(String query) async {
    setState(() {
      _searchQuery = query;
      _publications.clear();
      _currentPage = 1;
      _hasMore = true;
    });
    await _loadMorePublications();
  }

  Future<void> _loadMorePublications() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final result = await _fetchPublications(
        page: _currentPage,
        year: _selectedYear,
        keyword: _searchQuery.isEmpty ? null : _searchQuery,
      );
      if (!mounted) return;
      setState(() {
        _publications.addAll(
          result['publications'].where((pub) => !_publications.contains(pub)),
        );
        _totalPages = result['totalPages'];
        _currentPage++;
        _hasMore = _currentPage <= _totalPages;
        if (_searchController.text.isEmpty && _selectedYear == 'Semua') {
          _filteredPublications = List.from(_publications);
          _sortPublications(_filteredPublications);
        } else {
          _filterPublications();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterPublications() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredPublications = _publications.where((pub) {
        return pub.title.toLowerCase().contains(query) ||
            pub.abstract.toLowerCase().contains(query);
      }).toList();
      _sortPublications(_filteredPublications);
    });
  }

  void _sortPublications(List<Publication> publications) {
    List<Publication> sorted = List.from(publications);
    if (_sortBy == 'Terbaru') {
      sorted.sort((a, b) => b.date.compareTo(a.date));
    } else if (_sortBy == 'Terlama') {
      sorted.sort((a, b) => a.date.compareTo(b.date));
    } else if (_sortBy == 'A-Z') {
      sorted.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortBy == 'Z-A') {
      sorted.sort((a, b) => b.title.compareTo(a.title));
    }

    setState(() {
      _filteredPublications.clear();
      _filteredPublications = sorted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortOptions = ['Terbaru', 'Terlama', 'A-Z', 'Z-A'];
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
        title: const Text('Semua Publikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _selectedYear = 'Semua';
                _sortBy = 'Terbaru';
                _filterPublications();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari judul atau abstrak...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterPublications();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    value: _selectedYear,
                    items: _years,
                    onChanged: (value) async {
                      setState(() {
                        _selectedYear = value!;
                        _publications.clear();
                        _filteredPublications.clear();
                        _currentPage = 1;
                        _hasMore = true;
                        //_filterPublications();
                      });
                      await _loadMorePublications();
                    },
                    label: 'Tahun',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterDropdown(
                    value: _sortBy,
                    items: sortOptions,
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                        _filterPublications();
                      });
                    },
                    label: 'Urutkan',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Text(
                  '${_filteredPublications.length} Hasil',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredPublications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 50,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada publikasi ditemukan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Coba kata kunci atau filter berbeda',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent &&
                          _hasMore) {
                        _loadMorePublications();
                      }
                      return true;
                    },
                    child: ListView.builder(
                      itemCount:
                          _filteredPublications.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _filteredPublications.length) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : _filteredPublications.isEmpty
                                  ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 16),
                                        Text('Tidak ada publikasi ditemukan'),
                                        Text(
                                          'Coba kata kunci atau filter berbeda',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    )
                                  : const Text('Tidak ada data lagi'),
                            ),
                          );
                        }
                        return _PublicationCard(
                          publication: _filteredPublications[index],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _buildFilterDropdown({
  required String value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  required String label,
}) {
  return InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isDense: true,
        isExpanded: true,
        items: items.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

//kelas sendiri untuk buat card view list publikasi karena beda format
class _PublicationCard extends StatelessWidget {
  final Publication publication;

  const _PublicationCard({Key? key, required this.publication})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          // Navigasi ke detail publikasi jika diperlukan
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: publication.cover,
                      width: 80,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.picture_as_pdf, size: 40),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          publication.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          publication.date,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          publication.abstract,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ukuran: ${publication.size}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Lihat'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PublicationFullPage(publication: publication),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
