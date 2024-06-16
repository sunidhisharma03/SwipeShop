import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swipeshop_frontend/modal/video.dart';

Future<void> addToFirestore(Video video) async {
  try {
    await FirebaseFirestore.instance
        .collection('Videos')
        .add(video.toJson());
    print('Video added to Firestore successfully');
  } catch (error) {
    print('Error adding Video to Firestore: $error');
  }
}

Future<Map<String, List<Video>>> getFromFireStore() async {
  try {
    var challengeQuerySnapshot =
        await FirebaseFirestore.instance.collection('Videos').get();

    Map<String, List<Video>> challengeMap = {};

    for (var challengeDoc in challengeQuerySnapshot.docs) {
      var userId = challengeDoc['ownerID'];

      var userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      var userName = userDoc['username'];

      var challenge = Video(
        title: challengeDoc['title'],
        ownerID: challengeDoc['ownerID'],
        timestamp: DateTime.parse(challengeDoc['timestamp']),
        description: challengeDoc['description'],
        url: challengeDoc['url'],
        likeCount: challengeDoc['likeCount'],
        commentCount: challengeDoc['commentCount'],
        shareCount: challengeDoc['shareCount'],
      );

      // Check if the user already has entries in the map
      if (challengeMap.containsKey(userName)) {
        // If the user already exists in the map, add the new challenge to the existing list
        challengeMap[userName]!.add(challenge);
      } else {
        // If the user doesn't exist in the map, create a new list and add the challenge to it
        challengeMap[userName] = [challenge];
      }
    }
print(challengeMap);
    return challengeMap;
  } catch (e) {
    print('Error fetching videos: $e');
    return {};
  }
  
}
Future<Map<String, List<Video>>> getUsersVideo(String userId) async {
  try {
    var challengeQuerySnapshot = await FirebaseFirestore.instance
        .collection('Videos')
        .where('ownerID', isEqualTo: userId) // Filter challenges by userId
        .get();
        print(challengeQuerySnapshot.docs);
    Map<String, List<Video>> challengeMap = {};
    List<Video> challenge = [];
    for (var challengeDoc in challengeQuerySnapshot.docs) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      var userName = userDoc['name'];
       challenge.add(Video(
        title: challengeDoc['title'],
        ownerID: challengeDoc['ownerID'],
        timestamp: DateTime.parse(challengeDoc['timestamp']),
        description: challengeDoc['description'],
        url: challengeDoc['url'],
        likeCount: challengeDoc['likeCount'],
        commentCount: challengeDoc['commentCount'],
        shareCount: challengeDoc['shareCount'],
      ));

      // Add the challenge to the map with user name as key
      challengeMap[userName] = challenge;
    }
    
    return challengeMap;
  } catch (e) {
    print('Error fetching videos: $e');
    return {};
  }

}
  
