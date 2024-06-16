class Video{
  final String title;
  final String description;
  final String ownerID;
  final String url;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final DateTime timestamp;
  Video({
    required this.ownerID,
    required this.title,
    required this.url,
    required this.description,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.timestamp,
  });

factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: json['title'],
      ownerID: json['ownerID'],
      timestamp: DateTime.parse(json['timestamp']),
      description: json['description'],
      url: json['url'],
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
      shareCount: json['shareCount'],
    );
}

Map<String, dynamic> toJson() {
    return {
      'title':title,
      'description': description,
      'ownerID': ownerID,
      'url': url,
      'timestamp': timestamp,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount' : shareCount,
    };
  }
}