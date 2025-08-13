import 'package:flutter/material.dart';

class StatsSearchDelegate extends SearchDelegate<String> {
  final List<String> _allData = [
    'Penduduk Miskin 2023',
    'PDRB Triwulan IV',
    'Inflasi November',
    'Pengangguran Terbuka',
  ];

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''), // Kembali ke halaman sebelumnya
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, '');
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _allData
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(results[index]),
        onTap: () => close(context, results[index]),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? _allData
        : _allData
              .where((item) => item.toLowerCase().contains(query.toLowerCase()))
              .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestionList[index]),
        onTap: () => close(context, suggestionList[index]),
      ),
    );
  }
}
