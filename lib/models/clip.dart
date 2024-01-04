import 'article.dart';

class Clip {
  int id;
  int status;
  int progress;
  String? comment;
  Article? article;
  int articleId;
  String userId;
  DateTime createdAt;
  DateTime updatedAt;

  Clip({
    required this.id,
    required this.status,
    required this.progress,
    required this.comment,
    required this.article,
    required this.articleId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Clip.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        status = json['status'] as int,
        progress = json['progress'] as int,
        comment = json['comment'] as String?,
        article = json['article'] != null
            ? Article.fromJson(json['article'] as Map<String, dynamic>)
            : null,
        articleId = json['articleId'] as int,
        userId = json['userId'] as String,
        createdAt = DateTime.parse(json['createdAt'] as String),
        updatedAt = DateTime.parse(json['updatedAt'] as String);

  @override
  bool operator ==(Object other) {
    return other is Clip && other.hashCode == hashCode;
  }

  @override
  int get hashCode => Object.hash(id, articleId);
}
