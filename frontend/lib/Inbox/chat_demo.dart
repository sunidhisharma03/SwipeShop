import 'package:flutter/material.dart';

// Message model class
class Message {
  final String senderName;
  final String messageBody;
  final DateTime timestamp;

  Message({
    required this.senderName,
    required this.messageBody,
    required this.timestamp,
  });
}

class ChatDemo extends StatefulWidget {
  @override
  _ChatDemoState createState() => _ChatDemoState();
}

class _ChatDemoState extends State<ChatDemo> {
  // Dummy list of messages (placeholders)
  List<Message> messages = [
    Message(
      senderName: 'Ash',
      messageBody: 'Hello!',
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
    ),
    Message(
      senderName: 'Sunidhi',
      messageBody: 'Hello',
      timestamp: DateTime.now().subtract(Duration(minutes: 3)),
    ),
    Message(
      senderName: 'Ash',
      messageBody: 'I wanted to buy the shoe you showed',
      timestamp: DateTime.now().subtract(Duration(minutes: 2)),
    ),
  ];

  TextEditingController _replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(1),
              Colors.grey.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          reverse: true, // Start scrolling from the bottom
          child: Column(
            children: [
              Column(
                children: messages.map((message) {
                  final isAsh = message.senderName == 'Ash';

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: isAsh
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isAsh ? Colors.grey[300] : Colors.grey[400],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.senderName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(message.messageBody),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Reply',
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Add new message to the list
                        if (_replyController.text.isNotEmpty) {
                          setState(() {
                            messages.add(Message(
                              senderName: 'Ash',
                              messageBody: _replyController.text,
                              timestamp: DateTime.now(),
                            ));
                            // Sort messages based on timestamp (oldest to newest)
                            messages.sort(
                                (a, b) => a.timestamp.compareTo(b.timestamp));
                            // Clear reply text field
                            _replyController.clear();
                          });
                        }
                      },
                      child: Text("Reply"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ChatDemo(),
  ));
}
