// IndikatorPage.dart
import 'package:flutter/material.dart';
import 'package:luwu_stats/indikator_page/indikator_widgets.dart';
import 'package:luwu_stats/models/indikator.dart';

class IndikatorPage extends StatefulWidget {
  final dynamic indikatorList;

  const IndikatorPage({super.key, required this.indikatorList});

  @override
  State<IndikatorPage> createState() => _IndikatorPageState();
}

class _IndikatorPageState extends State<IndikatorPage> {
  String selectedYear = '2023';
  late List<Indicator> filteredIndicators;

  List<Indicator> filterByYear(List<Indicator> indicators, String year) {
    return indicators.where((indicator) => indicator.year == year).toList();
  }

  @override
  void initState() {
    super.initState();
    filteredIndicators = filterByYear(allIndicators, selectedYear);
  }

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
        title: const Text('Semua Indikator'),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Tahun: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    YearFilter(
                      selectedYear: selectedYear,
                      indicators: allIndicators,
                      onYearChanged: (year) {
                        setState(() {
                          selectedYear = year;
                          filteredIndicators = filterByYear(
                            allIndicators,
                            year,
                          );
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Indikator Strategis',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filteredIndicators.length,
              itemBuilder: (context, index) {
                return IndicatorCard(indicator: filteredIndicators[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
