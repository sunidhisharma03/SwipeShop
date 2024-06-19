import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshop_frontend/Comments/comment.dart';
import 'package:swipeshop_frontend/services/videoServices.dart';
import 'package:swipeshop_frontend/modal/comments.dart';

class Comments extends StatefulWidget {
  final String videoId;
  Comments({Key? key, required this.videoId}) : super(key: key);
  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  bool isCommentsSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color of the Scaffold
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isCommentsSelected = true;
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent, // Transparent background
                  elevation: 0, // No elevation
                ),
                child: const Text('COMMENTS'),
              ),
              const SizedBox(
                width: 10,
              ),
              Text("|", style: TextStyle(color: Colors.white)),
              const SizedBox(
                width: 10,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isCommentsSelected = false;
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent, // Transparent background
                  elevation: 0, // No elevation
                ),
                child: const Text('REVIEWS'),
              ),
            ],
          ),
          Expanded(
            child: Container(
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
              child: isCommentsSelected ? CommentsSection(videoId:widget.videoId) : ReviewsSection(),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentsSection extends StatefulWidget {
  final String videoId;
  CommentsSection({Key? key, required this.videoId}) : super(key: key);
  @override
  _CommentsSectionState createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  List<Comment> comments = [];
  bool isLoading = true;
  final TextEditingController _commentController = TextEditingController();

  void _submitComment() {
    final commentText = _commentController.text;
    print(commentText);
    if (commentText.isEmpty) {
      // Show a message or handle the empty text case
      print('Comment is empty');
      return;
    }
    var userId = FirebaseAuth.instance.currentUser!.uid;
    // Call your function to upload the comment
    commentVideo(widget.videoId,userId,commentText); // Replace with your actual function

    // Clear the text field after submitting the comment
    _commentController.clear();
  }

  @override
  void initState() {
    super.initState();
    fetchComments();
    print(comments.length);
  }

  void dispose() {
    _commentController.dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }

  Future<void> fetchComments() async {
    try {
      List<Comment> fetchedComments = await getVideoComments(widget.videoId);
      for (var fetCom in fetchedComments){
        String name = await getUserName(fetCom.userId);
        fetCom.userId = name;
      }
      setState(() {
        comments = fetchedComments;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching comments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var comment = comments[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.userId, // Replace with user's name if available
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  comment.content,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.black.withOpacity(0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8),
              TextField(
                controller: _commentController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _submitComment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // Transparent background
                  elevation: 0, // No elevation
                ),
                child: const Text('SUBMIT'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReviewsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Reviews Segment',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}