import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewie/chewie.dart';
import 'package:iconsax/iconsax.dart';
import 'package:swipeshop_frontend/Comments/comment.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:swipeshop_frontend/firebase_options.dart';
import 'package:swipeshop_frontend/services/customChewieControls.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
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

class VideoListScreen extends StatelessWidget {
  final CollectionReference videosCollection =
      FirebaseFirestore.instance.collection('Videos');

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
            final videos = snapshot.data!.docs.map((doc) {
              return {
                'id': doc.id,
                'url': doc['url'],
              };
            }).toList();
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return VideoPlayerItem(videoUrl: videos[index]['url']);
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

  VideoPlayerItem({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

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
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
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
              onPressed: () {},
              icon: const Icon(
                Iconsax.message_circle,
                size: 35,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            IconButton(
              icon: const Icon(
                Iconsax.heart,
                color: Colors.white,
                size: 35,
              ),
              onPressed: () {},
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
                      child: const Comments(),
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
      )
    ]);
  }
}
