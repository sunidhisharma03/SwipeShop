import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final String name;
  final String profilePictureUrl;
  final String location;

  const Profile({
    Key? key,
    required this.name,
    required this.profilePictureUrl,
    required this.location,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(widget.profilePictureUrl),
            ),
            SizedBox(height: 20),
            Text(
              widget.name.isNotEmpty ? widget.name : 'John Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              widget.location.isNotEmpty ? widget.location : 'New York, NY',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
