import 'article.dart';

class InboxItem {
  int id;
  String userId;
  int articleId;
  DateTime createdAt;
  DateTime updatedAt;

  InboxItem({
    required this.id,
    required this.articleId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  InboxItem.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        articleId = json['articleId'] as int,
        userId = json['userId'] as String,
        createdAt = DateTime.parse(json['createdAt'] as String),
        updatedAt = DateTime.parse(json['updatedAt'] as String);

  @override
  bool operator ==(Object other) {
    return other is InboxItem && other.hashCode == hashCode;
  }

  @override
  int get hashCode => Object.hash(id, userId, articleId);
}

class InboxItemWithArticle extends InboxItem {
  InboxItemWithArticle({
    required super.id,
    required super.userId,
    required super.articleId,
    required super.createdAt,
    required super.updatedAt,
    required this.article,
  });

  final Article article;

  InboxItemWithArticle.fromJson(super.json)
      : article = Article.fromJson(json['article'] as Map<String, dynamic>),
        super.fromJson();
}
