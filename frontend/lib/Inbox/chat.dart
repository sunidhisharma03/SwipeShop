import 'package:flutter/material.dart';
import 'package:swipeshop_frontend/services/videoServices.dart';

class Chat extends StatefulWidget {
  final String userId;
  final String sellerId;
  const Chat({Key? key, required this.sellerId, required this.userId})
      : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<String> messages = []; // List to store chat messages
  final TextEditingController _controller =
      TextEditingController(); // Controller for text field
  late Future<String> userNameFuture;
  var sellerNameFuture;

  @override
  void initState() {
    super.initState();
    getUN();
  }

  Future<void> getUN() async {
    var user = await getUserName(widget.sellerId);
    setState(() {
      sellerNameFuture = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(sellerNameFuture,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold))),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
            Divider(height: 1),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Enter your message...',
                      ),
                      onSubmitted: (value) {
                        sendMessage(value);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      sendMessage(_controller.text);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String message) {
    setState(() {
      messages.add(message); // Add message to the list
      _controller.clear(); // Clear the text field after sending message
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when not needed
    super.dispose();
  }
}
