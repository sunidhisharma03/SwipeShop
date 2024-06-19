import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeshop_frontend/Profile/merchantStatistics.dart';

class Profile extends StatelessWidget {
  final bool isMerchant;
  const Profile({Key? key, required this.isMerchant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = 'John Doe'; // Example name
    final String profilePictureUrl =
        'https://www.example.com/profile.jpg'; // Example profile picture URL
    final String location = 'New York, NY'; // Example location

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
              isMerchant ? SizedBox(height: 80) : SizedBox(height: 0),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profilePictureUrl),
              ),
              SizedBox(height: 20),
              Text(
                name,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                location,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (isMerchant) ...[
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
                          child: Text("Statistics"))),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                      child: ElevatedButton(
                    onPressed: () {},
                    child: Text("Logout"),
                  )),
                ],
              ]),
              if (isMerchant) ...[
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
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 10, // Example number of videos
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.video_collection,
                                size: 50,
                                color: Colors.grey.shade700,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Video $index',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Description for video $index',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
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
