class Publication {
  final String id;
  final String title;
  final String abstract;
  final String cover;
  final String pdfUrl;
  final String date;
  final String size;

  Publication({
    required this.id,
    required this.title,
    required this.abstract,
    required this.cover,
    required this.pdfUrl,
    required this.date,
    required this.size,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: json['pub_id'] ?? "",
      title: json['title'] ?? "",
      abstract: json['abstract'] ?? "",
      cover: json['cover'] ?? "",
      pdfUrl: json['pdf'] ?? "",
      date: json['rl_date'] ?? "",
      size: json['size'] ?? "",
    );
  }
}
