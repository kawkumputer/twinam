class TwinUser {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt;

  const TwinUser({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
  });

  factory TwinUser.fromJson(Map<String, dynamic> json) {
    return TwinUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      username: json['username'] as String,
      displayName: json['display_name'] as String? ?? json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'display_name': displayName,
    'avatar_url': avatarUrl,
    'created_at': createdAt.toIso8601String(),
  };

  TwinUser copyWith({
    String? displayName,
    String? avatarUrl,
  }) {
    return TwinUser(
      id: id,
      email: email,
      username: username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
    );
  }
}
