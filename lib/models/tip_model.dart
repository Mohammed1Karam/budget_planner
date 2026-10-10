/// An article in the Tips grid and on the article screen.
class TipModel {
  const TipModel({
    required this.id,
    required this.title,
    required this.publishedAt,
    required this.image,
    this.lead = '',
    this.body = '',
    this.bullets = const <String>[],
  });

  final String id;
  final String title;
  final DateTime publishedAt;

  /// Asset path of the illustration on the card and at the top of the article.
  final String image;

  /// The paragraph directly under the article title.
  final String lead;

  /// The closing paragraph, after the bullet list.
  final String body;

  final List<String> bullets;

  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      id: json['id'] as String,
      title: json['title'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
      image: json['image'] as String? ?? '',
      lead: json['lead'] as String? ?? '',
      body: json['body'] as String? ?? '',
      bullets: (json['bullets'] as List<dynamic>? ?? <dynamic>[])
          .cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'published_at': publishedAt.toIso8601String(),
        'image': image,
        'lead': lead,
        'body': body,
        'bullets': bullets,
      };
}
