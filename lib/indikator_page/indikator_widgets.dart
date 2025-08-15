// indikator_widgets.dart
import 'package:flutter/material.dart';
import 'package:luwu_stats/models/indikator.dart';

class YearFilter extends StatelessWidget {
  final String selectedYear;
  final List<Indicator> indicators;
  final Function(String) onYearChanged;

  const YearFilter({
    Key? key,
    required this.selectedYear,
    required this.indicators,
    required this.onYearChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final years = indicators.map((e) => e.year).toSet().toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedYear,
          items: years.map((year) {
            return DropdownMenuItem<String>(value: year, child: Text(year));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onYearChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}

class IndicatorCard extends StatelessWidget {
  final Indicator indicator;

  const IndicatorCard({Key? key, required this.indicator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(color: Colors.orange, width: 1),
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
}
