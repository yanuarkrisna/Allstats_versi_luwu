import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luwu_stats/models/publikasi.dart';

class PublicationService {
  static const String _apiKey = '20b34b1102b76110c8c41ad3ef5457b7';
  static const String _domain = '7317';

  Future<Map<String, dynamic>> fetchPublications(int page) async {
    final url = Uri.parse(
      'https://webapi.bps.go.id/v1/api/list/model/publication/lang/ind/domain/$_domain/page/$page/key/$_apiKey/',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'publications': (data['data'][1] as List)
            .map((e) => Publication.fromJson(e))
            .toList(),
        'totalPages': data['data'][0]['pages'],
        'currentPage': data['data'][0]['page'],
      };
    } else {
      throw Exception('Failed to load publications');
    }
  }
}
