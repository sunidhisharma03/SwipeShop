import 'package:flutter/material.dart';

class Comments extends StatefulWidget {
  const Comments({super.key});

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
              child: isCommentsSelected ? CommentsSection() : ReviewsSection(),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: 10, // Placeholder count for items
            itemBuilder: (context, index) {
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
                            '$index', // Placeholder seller name
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Comment here $index.', // Placeholder text content
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
                onPressed: () {},
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
