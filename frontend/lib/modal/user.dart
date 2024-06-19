class Users{
  final String email;
  final List<dynamic> likedVideos;
  final String name;
  final String url;
  final bool isMerchant;
  Users({
    required this.email,
    required this.likedVideos,
    required this.name, required this.url, required this.isMerchant,
  });

factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      email: json['email'],
      likedVideos: json['likedVideos'],
      name: json['name'],
      url: json['url'],
      isMerchant: json['isMerchant'],
    );
}

Map<String, dynamic> toJson() {
    return {
      'email':email,
      'likedVideos': likedVideos,
      'name': name,
      'url': url,
      'isMerchant': isMerchant,
    };
  }
}