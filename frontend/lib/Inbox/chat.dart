import 'package:flutter/material.dart';
import 'package:swipeshop_frontend/services/videoServices.dart'; // Import your ChatService
import 'package:cloud_firestore/cloud_firestore.dart';

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
    fetchMessages();
  }

  Future<void> getUN() async {
    try {
      var user = await getUserName(widget.sellerId);
      setState(() {
        sellerNameFuture = user;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchMessages() async {
    try {
      var fetchedMessages =
          await getChat(userId: widget.userId, sellerId: widget.sellerId);
      print(
          "fakljsldkfjalsjflkasjdfkljsalfkjasdlkfjasdklfjaslkfjhjaskfhsdkljflksdjflakdsjfklsadjf");
      print(fetchedMessages);
      setState(() {
        messages.addAll(fetchedMessages);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendMessage(String message) async {
    try {
      await FirebaseFirestore.instance.collection('Chats').add({
        'senderID': widget.userId,
        'receiverID': widget.sellerId,
        'content': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        messages.insert(0, message); // Add message to the list at the beginning
        _controller.clear(); // Clear the text field after sending message
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(sellerNameFuture ?? '',
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
                reverse: true, // Start from the bottom
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      margin: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        messages[index],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
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
                        if (value.isNotEmpty) {
                          sendMessage(value);
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        sendMessage(_controller.text);
                      }
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

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when not needed
    super.dispose();
  }
}
