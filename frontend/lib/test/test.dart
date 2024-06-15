import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirebase extends StatefulWidget {
  const TestFirebase({super.key});

  @override
  State<TestFirebase> createState() => _TestFirebaseState();
}

class _TestFirebaseState extends State<TestFirebase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Firebase"),
        centerTitle: true,
      ),
      body: StreamBuilder(stream: FirebaseFirestore.instance.collection("Users").snapshots(),
      builder: (context,snapshot){
        if (snapshot.connectionState==ConnectionState.active){
          if (snapshot.hasData){
            return ListView.builder(itemBuilder: (context,index){
              return ListTile(
                leading: CircleAvatar(
                  child: Text("${index+1}"),
                ),
                title: Text("${snapshot.data!.docs[index]["name"]}"),
                subtitle: Text("${snapshot.data!.docs[index]["email"]}"),
              );
            });
          }
          else if (snapshot.hasError){
            return Center(child: Text("${snapshot.hasError.toString()}"),);
          }
          else{
            return Center(child: Text("No data found."),);
          }
        }
        else{
          return Center(child: CircularProgressIndicator(),);
        }
      },
    ));
  }
}