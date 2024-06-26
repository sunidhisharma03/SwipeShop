class Likes{
  final String userId;
  final String videoId;
  final DateTime timestamp;
  Likes({
    required this.userId,
    required this.videoId,
    required this.timestamp,
  });

factory Likes.fromJson(Map<String, dynamic> json) {
    return Likes(
      userId: json['userID'],
      videoId: json['videoID'],
      timestamp: DateTime.parse(json['timestamp']),
    );
}

Map<String, dynamic> toJson() {
    return {
      'userID':userId,
      'videoID': videoId,
      'timestamp': timestamp,
    };
  }
}