import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';
import 'package:swipeshop_frontend/Comments/newComment.dart';
import 'package:swipeshop_frontend/Inbox/chat.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swipeshop_frontend/firebase_options.dart';
import 'package:swipeshop_frontend/services/customChewieControls.dart';
import 'package:swipeshop_frontend/services/videoServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwipeShop',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: VideoListScreen(),
    );
  }
}

class newHome extends StatefulWidget {
  const newHome({super.key});

  @override
  State<newHome> createState() => _newHomeState();
}

class _newHomeState extends State<newHome> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final CollectionReference videosCollection =
      FirebaseFirestore.instance.collection('Videos');
  final String apiUrl = 'http://10.0.2.2:8000/recommendations/';
  List<dynamic>? to_display;

  @override
  void initState() {
    super.initState();
    fetchapi();
  }

  Future<void> fetchapi() async {
    try {
      var userId = FirebaseAuth.instance.currentUser!.uid;
      String name = await getUserName(userId);
      print(name);
      print('Hello $name');

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final body = response.body;
        print(body);
        final json = jsonDecode(body);
        print("Herejson is $json");
        if (name == "Anon") {
          to_display = json[0]["Anon_based_on_ash"];
        } else {
          to_display = json[0]["ash_based_on_Anon"];
        }
        print(to_display);
        setState(() {
          // Ensure to_display is updated
          to_display = to_display;
        });
      } else {
        print('GET request failed with status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error sending GET request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.grey.withOpacity(0.5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder(
          stream: videosCollection.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            if (to_display == null) {
              // Handle case where to_display is still null (optional)
              return Center(child: CircularProgressIndicator());
            }

            final videos = snapshot.data!.docs
                .where((doc) => to_display!.contains(doc.id))
                .map((doc) {
              return {
                'id': doc.id,
                'url': doc['url'],
              };
            }).toList();
            print(videos);

            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return VideoPlayerItem(
                    videoUrl: videos[index]['url'],
                    videoID: videos[index]['id']);
              },
            );
          },
        ),
      ),
    );
  }
}


class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final String videoID;

  VideoPlayerItem({Key? key, required this.videoUrl, required this.videoID})
      : super(key: key);

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool isLiked = false;
  var title = '';
  var description = '';
  var creatorId;
  var userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _videoPlayerController.initialize().then((_) {
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: true,
          customControls: CustomChewieControls(),
          aspectRatio: _videoPlayerController.value.aspectRatio,
          allowFullScreen: true, // Allow full screen mode
        );
      });
    });
    _checkIfLiked();
    _captions();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _checkIfLiked() async {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    var likeQuerySnapshot = await FirebaseFirestore.instance
        .collection('Likes')
        .where('videoID', isEqualTo: widget.videoID)
        .where('userID', isEqualTo: userId)
        .get();

    setState(() {
      isLiked = likeQuerySnapshot.docs.isNotEmpty;
      userId = userId;
    });
  }

  Future<void> _captions() async {
    try {
      // Fetch video data from Firestore
      var videoSnapshot = await FirebaseFirestore.instance
          .collection('Videos')
          .doc(widget.videoID)
          .get();

      if (videoSnapshot.exists) {
        // Check if the document exists
        setState(() {
          title = videoSnapshot['title'];
          description = videoSnapshot['description'];
          creatorId = videoSnapshot['ownerID'];
        });

        // Use title and description as needed
        print('Title: $title');
        print('Description: $description');
        print('Creator ID: $creatorId');
      } else {
        // Handle case where document does not exist
        print('Document with ID ${widget.videoID} does not exist');
      }
    } catch (e) {
      // Handle any errors that occur during the fetch operation
      print('Error fetching video data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      GestureDetector(
          onTap: () {
            setState(() {
              _videoPlayerController.value.isPlaying
                  ? _videoPlayerController.pause()
                  : _videoPlayerController.play();
            });
          },
          child: _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(controller: _chewieController!)
              : Center(child: CircularProgressIndicator())),
      Positioned(
        right: 10,
        top: MediaQuery.of(context).size.height / 2 - 75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Chat(
                              sellerId: creatorId,
                              userId: userId,
                            )));
              },
              icon: const Icon(
                Iconsax.message_circle,
                size: 35,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            IconButton(
              icon: Icon(
                Iconsax.heart,
                color: isLiked ? Color.fromRGBO(222, 12, 82, 1) : Colors.white,
                size: 35,
              ),
              onPressed: () {
                var userId = FirebaseAuth.instance.currentUser!.uid;
                likeVideo(widget.videoID, userId);
              },
            ),
            const SizedBox(height: 12),
            IconButton(
              icon: const Icon(
                Iconsax.message,
                color: Colors.white,
                size: 35,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  enableDrag: true,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Comments(videoId: widget.videoID),
                      color: Colors.black.withOpacity(0.5),
                    );
                  },
                );
                // Handle comment button press
              },
            ),
            const SizedBox(height: 12),
            IconButton(
              icon: const Icon(
                Iconsax.send_2,
                color: Colors.white,
                size: 35,
              ),
              onPressed: () {
                // Handle share button press
              },
            ),
          ],
        ),
      ),
      Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SingleChildScrollView(
                child: Text(title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
              Text(
                description,
                style: TextStyle(color: Colors.white, fontSize: 15),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              )
            ]),
          )),
    ]);
  }
}
