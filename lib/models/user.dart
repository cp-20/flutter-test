class User {
  User({
    required this.id,
    required this.email,
    required this.name,
    this.displayName,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String email;
  String name;
  String? displayName;
  String? avatar;
  DateTime createdAt;
  DateTime updatedAt;

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        email = json['email'] as String,
        name = json['name'] as String,
        displayName = json['displayName'] as String?,
        avatar = json['avatar'] as String?,
        createdAt = DateTime.parse(json['createdAt'] as String),
        updatedAt = DateTime.parse(json['updatedAt'] as String);
}
