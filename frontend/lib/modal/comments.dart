class Comment{
  String userId;
  final String videoId;
  final String content;
  final DateTime timestamp;
  Comment({
    required this.userId,
    required this.videoId,
    required this.content,
    required this.timestamp,
  });

factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json['userID'],
      videoId: json['videoID'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
}

Map<String, dynamic> toJson() {
    return {
      'userID':userId,
      'videoID': videoId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}