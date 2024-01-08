class User {
  User({
    required this.id,
    required this.email,
    required this.name,
    this.displayName,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String email;
  String name;
  String? displayName;
  String? avatarUrl;
  DateTime createdAt;
  DateTime updatedAt;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        email = json['email'] as String,
        name = json['name'] as String,
        displayName = json['displayName'] as String?,
        avatarUrl = json['avatarUrl'] as String?,
        createdAt = DateTime.parse(json['createdAt'] as String),
        updatedAt = DateTime.parse(json['updatedAt'] as String);
}
