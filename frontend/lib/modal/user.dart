class Users{
  final String email;
  final List<String> likedVideos;
  final String name;
  String? url;
  Users({
    required this.email,
    required this.likedVideos,
    required this.name, required url,
  });

factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      email: json['email'],
      likedVideos: json['likedVideos'],
      name: json['name'],
      url: json['url'],
    );
}

Map<String, dynamic> toJson() {
    return {
      'email':email,
      'likedVideos': likedVideos,
      'name': name,
      'url': url,
    };
  }
}