import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeshop_frontend/Profile/merchantStatistics.dart';
import 'package:swipeshop_frontend/modal/user.dart';
import 'package:swipeshop_frontend/signIn/authwrapper.dart';
import 'package:swipeshop_frontend/signIn/firebase_signIn.dart';
import 'package:swipeshop_frontend/vidUpload/vidUpload.dart';


class Profile extends StatelessWidget {
  final Users current;
  // final Firebase _firebase = Firebase();
  const Profile({Key? key, required this.current}) : super(key: key);

  Future<String?> _signOut() async{
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
              current.isMerchant ? SizedBox(height: 80) : SizedBox(height: 0),
              CircleAvatar(
                radius: 50,
                backgroundImage: current.url.isNotEmpty
                    ? NetworkImage(current.url)
                    : NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQH4skylfJs-mOf6lz4pGDuTMvX6zqPc4LppQ&s'),
              ),
              SizedBox(height: 20),
              Text(
                current.name,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              // SizedBox(height: 10),
              // Text(
              //   location,
              //   style: TextStyle(fontSize: 18, color: Colors.white70),
              // ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (current.isMerchant) ...[
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
                          TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MaterialApp(
                                                                          home: Scaffold(
                                                                            body: VideoInput(),
                                                                            ) ,
                                                                            )),
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
                  onPressed: () {
                    var check = _signOut();
                    if (check == 'success') {
                      // Navigator.pushNamed(context, '/wrapper');
                      Navigator.push(
                    context,
                      MaterialPageRoute(
                        builder: (context) => AuthWrapper(
                        )));
                    } else {
                      print(check);
                    }
                  },
                  child: Text("Logout"),
                )),
              ]),
              if (current.isMerchant) ...[
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
