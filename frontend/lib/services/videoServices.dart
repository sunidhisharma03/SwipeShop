import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swipeshop_frontend/modal/video.dart';
import 'package:swipeshop_frontend/modal/comments.dart';
import 'package:swipeshop_frontend/modal/user.dart';

Future<void> addToFirestore(Video video) async {
  try {
    await FirebaseFirestore.instance.collection('Videos').add(video.toJson());
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
          .collection('Users')
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

Future<void> likeVideo(String videoId, String userId) async {
  try {
    // Get a reference to the video document
    var videoDocRef =
        FirebaseFirestore.instance.collection('Videos').doc(videoId);

    // Start a Firestore transaction
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the current video document
      var videoDoc = await transaction.get(videoDocRef);

      if (!videoDoc.exists) {
        throw Exception("Video does not exist");
      }

      // Check if the user has already liked this video
      var likeQuerySnapshot = await FirebaseFirestore.instance
          .collection('Likes')
          .where('videoID', isEqualTo: videoId)
          .where('userID', isEqualTo: userId)
          .get();

      if (likeQuerySnapshot.docs.isNotEmpty) {
        // User has already liked this video, abort the transaction
        throw Exception("User has already liked this video");
      }

      // Increment the like count
      var newLikeCount = (videoDoc['likeCount'] as int) + 1;

      // Update the like count in the Videos collection
      transaction.update(videoDocRef, {'likeCount': newLikeCount});

      // Add an entry to the Likes collection
      var likeDocRef = FirebaseFirestore.instance.collection('Likes').doc();
      transaction.set(likeDocRef, {
        'videoID': videoId,
        'userID': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Add the video to the user's likedVideos array
      var userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);
      transaction.update(userDocRef, {
        'likedVideos': FieldValue.arrayUnion([videoId])
      });
    });

    print('Video liked successfully');
  } catch (error) {
    print('Error liking video: $error');
  }
}

Future<void> commentVideo(String videoId, String userId, String content) async {
  try {
    // Get a reference to the video document
    var videoDocRef =
        FirebaseFirestore.instance.collection('Videos').doc(videoId);

    // Start a Firestore transaction
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the current video document
      var videoDoc = await transaction.get(videoDocRef);

      if (!videoDoc.exists) {
        throw Exception("Video does not exist");
      }

      // Check if the user has already liked this video
      // var likeQuerySnapshot = await FirebaseFirestore.instance
      //     .collection('Likes')
      //     .where('videoID', isEqualTo: videoId)
      //     .where('userID', isEqualTo: userId)
      //     .get();

      // if (likeQuerySnapshot.docs.isNotEmpty) {
      //   // User has already liked this video, abort the transaction
      //   throw Exception("User has already liked this video");
      // }

      // // Increment the like count
      // var newLikeCount = (videoDoc['likeCount'] as int) + 1;

      // Update the like count in the Videos collection
      // transaction.update(videoDocRef, {'likeCount': newLikeCount});

      // Add an entry to the Likes collection
      var commentDocRef =
          FirebaseFirestore.instance.collection('Comments').doc();
      transaction.set(commentDocRef, {
        'videoID': videoId,
        'userID': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'content': content,
      });

      // Add the video to the user's likedVideos array
      // var userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      // transaction.update(userDocRef, {
      //   'likedVideos': FieldValue.arrayUnion([videoId])
      // });
    });

    print('Commented Successfully.');
  } catch (error) {
    print('Error commenting video: $error');
  }
}

Future<List<Comment>> getVideoComments(String videoId) async {
  try {
    var commentsQuerySnapshot = await FirebaseFirestore.instance
        .collection('Comments')
        .where('videoID', isEqualTo: videoId)
        .get();
    // print(commentsQuerySnapshot.docs);
    List<Comment> comments = commentsQuerySnapshot.docs.map((doc) {
      return Comment(
        videoId: doc['videoID'],
        userId: doc['userID'],
        content: doc['content'],
        timestamp: doc['timestamp'].toDate(),
      );
    }).toList();
    return comments;
  } catch (e) {
    print('Error fetching videos: $e');
    return [];
  }
}

Future<String> getUserName(String userId) async {
  try {
    var userQuerySnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (userQuerySnapshot.exists) {
      return userQuerySnapshot.data()?['name'];
    } else {
      print('User document does not exist');
      return 'null';
    }
  } catch (e) {
    print('Error fetching comments: $e');
    return 'Null';
  }
}

Future<Users> getUser(String userId) async {
  try {
    var userQuerySnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (userQuerySnapshot.exists) {
      print(userQuerySnapshot.data()?['email']);
      print(userQuerySnapshot.data()?['name']);
      Users returnVar = Users(
        email: userQuerySnapshot.data()?['email'],
        name: userQuerySnapshot.data()?['name'],
        url: userQuerySnapshot.data()?['url'],
        likedVideos: userQuerySnapshot.data()?['likedVideos'],
        isMerchant: userQuerySnapshot.data()?['isMerchant'],
      );
      return returnVar;
    } else {
      print('User document does not exist');
      return Users(
          email: '', likedVideos: [], name: '', url: '', isMerchant: false);
    }
  } catch (e) {
    print('Error fetching users: $e');
    return Users(
        email: '', likedVideos: [], name: '', url: '', isMerchant: false);
  }
}

Future<List<String>> getVideos({required String userId}) async {
  try {
    var videoQuery = await FirebaseFirestore.instance
        .collection('Videos')
        .where('ownerID', isEqualTo: userId)
        .get();

    List<String> videoUrls = videoQuery.docs.map((doc) {
      return doc['url'] as String; // Cast each 'url' to String
    }).toList();

    return videoUrls;
  } catch (e) {
    print('Error fetching videos: $e');
    return [];
  }
}

Future<List<String>>  getChat(
    {required String userId, required String sellerId}) async {
  try {
    var chatQuery = await FirebaseFirestore.instance
        .collection('Chats')
        .where('senderID', whereIn: [userId, sellerId])
        .where('receiverID', whereIn: [userId, sellerId])
        .orderBy(
            'timestamp') // Assuming you have a timestamp field for sorting messages
        .get();
    List<String> chat = chatQuery.docs.map((doc) {
      return doc['content'] as String;
    }).toList();
    
    return chat;
  } catch (e) {
    print(e);
    return [];
  }
}
