import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeshop_frontend/signIn/firebase_signIn.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swipeshop_frontend/modal/video.dart';
import 'package:swipeshop_frontend/services/videoServices.dart';
import 'package:firebase_core/firebase_core.dart' as fb;
import 'package:swipeshop_frontend/firebase_options.dart';
import 'package:video_player/video_player.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await fb.Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: VideoInput(),
      ) ,
    );
  }
}



class VideoInput extends StatefulWidget {
  const VideoInput({super.key});

  @override
  State<VideoInput> createState() => _VideoInputState();
}

class _VideoInputState extends State<VideoInput> {
  final _titleController = TextEditingController();
  final _desController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  VideoPlayerController? _controller;
  XFile? _image;
  String videoUrl = "";
  String videLocal ="";

  final Firebase _firebase = Firebase();

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer(){
  _controller = VideoPlayerController.file(File(videLocal))..initialize().then((_) {
    setState(() {
    });
    _controller!.play();
  });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: SingleChildScrollView(
      child :Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  "Upload a",
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: Text(
                "Video",
                style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.blue.shade800),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Video Title",
                  suffixIcon: IconButton(
                    onPressed: () {
                      _titleController.clear();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
              ),
            ),
            TextField(
              controller: _desController,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "Description",
                suffixIcon: IconButton(
                  onPressed: () {
                    _desController.clear();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ElevatedButton(
                onPressed: selectImages,
                child: const Text("The Video"),
              ),
            ),
            _videoPreview(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_image == null) return;
                  //getting reference to storage root
                  Reference referenceRoot =
                      FirebaseStorage.instance.ref();
                  Reference referenceDirVideos =
                      referenceRoot.child('videos');

                  //reference for the images to be stored
                  String uniqueFileName =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  Reference referenceVideoToUpload =
                      referenceDirVideos.child(uniqueFileName);

                  //Store the file
                  try {
                    await referenceVideoToUpload
                        .putFile(File(_image!.path));

                    //get the url of the image
                    videoUrl =
                        await referenceVideoToUpload.getDownloadURL();

                    String? uid = await _firebase.getCurrentUser();

                    Video _video = Video(
                      title: _titleController.text,
                      description: _desController.text,
                      url: videoUrl,
                      ownerID: uid!,
                      timestamp: DateTime.now(),
                      likeCount: 0,
                      commentCount: 0,
                      shareCount: 0,
                    );

                    await addToFirestore(_video);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Successfully uploaded"),
                        duration: Duration(seconds: 3),
                      ),
                      
                    );
                    Navigator.pop(context); // Close the modal after successful submission
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to Upload Image :$error"),
                      ),
                    );
                  }
                },
                child: const Text("Submit"),
              ),
            )
          ],
        ),
      ),
    ));
  }

  void selectImages() async {
    final XFile? selectedImages =
        await _imagePicker.pickVideo(source: ImageSource.gallery);

    if (selectedImages != null) {
      setState(() {
        _image = selectedImages;
        videLocal = selectedImages.path;
        _initializeVideoPlayer();
      });
    }
  }
  

  Widget _videoPreview(){
    if(_controller != null){
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
        );
    }
    else{
      return const CircularProgressIndicator();
    }
  }

  Widget _buildImagePreview() {
    return _image == null
        ? Container()
        : Column(
            children: [
              Image.file(
                File(_image!.path),
                fit: BoxFit.cover,
              )
            ],
          );
  }
}

