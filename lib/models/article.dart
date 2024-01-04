class Article {
  Article({
    required this.id,
    required this.title,
    required this.url,
    required this.body,
    this.ogImageUrl,
    this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String title;
  String url;
  String body;
  String? ogImageUrl;
  String? summary;
  DateTime createdAt;
  DateTime updatedAt;

  Article.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        title = json['title'] as String,
        url = json['url'] as String,
        body = json['body'] as String,
        ogImageUrl = json['ogImageUrl'] as String?,
        summary = json['summary'] as String?,
        createdAt = DateTime.parse(json['createdAt'] as String),
        updatedAt = DateTime.parse(json['updatedAt'] as String);
}
