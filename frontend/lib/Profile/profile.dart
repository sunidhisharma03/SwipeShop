import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeshop_frontend/Profile/merchantStatistics.dart';
import 'package:swipeshop_frontend/modal/user.dart';
import 'package:swipeshop_frontend/services/videoServices.dart';
import 'package:swipeshop_frontend/signIn/authwrapper.dart';
import 'package:swipeshop_frontend/signIn/firebase_signIn.dart';
import 'package:swipeshop_frontend/vidUpload/vidUpload.dart';
import 'package:video_player/video_player.dart';

class Profile extends StatefulWidget {
  final Users current;

  const Profile({Key? key, required this.current}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<String> _videoUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    List<String> videos = await getVideos(userId: userId);
    print(_videoUrls);
    setState(() {
      _videoUrls = videos;
      _isLoading = false;
    });
  }

  Future<String?> _signOut() async {
    final Firebase _firebase = Firebase();
    String? check;
    check = await _firebase.logout();
    return check;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black,
                Colors.grey.shade900,
                Colors.black,
                Colors.grey.shade900,
              ],
              stops: [0, 0.25, 0.7, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              widget.current.isMerchant
                  ? SizedBox(height: 80)
                  : SizedBox(height: 0),
              CircleAvatar(
                radius: 50,
                backgroundImage: widget.current.url.isNotEmpty
                    ? NetworkImage(widget.current.url)
                    : NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQH4skylfJs-mOf6lz4pGDuTMvX6zqPc4LppQ&s'),
              ),
              SizedBox(height: 20),
              Text(
                widget.current.name,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                widget.current.email,
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.current.isMerchant) ...[
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            enableDrag: true,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: MerchantStats(),
                                color: Colors.grey.withOpacity(0.5),
                              );
                            },
                          );
                        },
                        child: Text("Statistics"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MaterialApp(
                              home: Scaffold(
                                body: VideoInput(),
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'VideoInput',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    child: ElevatedButton(
                      onPressed: () async {
                        var check = await _signOut();
                        if (check == 'success') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuthWrapper(),
                            ),
                          );
                        } else {
                          print(check);
                        }
                      },
                      child: Text("Logout"),
                    ),
                  ),
                ],
              ),
              if (widget.current.isMerchant) ...[
                SizedBox(height: 20),
                Text(
                  'Videos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _videoUrls.length,
                          itemBuilder: (context, index) {
                            return VideoPlayerWidget(url: _videoUrls[index]);
                          },
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(
            () {}); // Ensure the first frame is shown after the video is initialized.
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                  _PlayPauseOverlay(controller: _controller),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _PlayPauseOverlay({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: Stack(
        children: <Widget>[
          AnimatedSwitcher(
            duration: Duration(milliseconds: 50),
            reverseDuration: Duration(milliseconds: 200),
            child: controller.value.isPlaying
                ? SizedBox.shrink()
                : Container(
                    color: Colors.black26,
                    child: Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 100.0,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
