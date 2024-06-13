import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.black,
                Colors.grey.shade900,
                Colors.black,
                Colors.grey.shade900,
              ], stops: const [
                0,
                0.25,
                0.7,
                1
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            )),
        Padding(
          padding: EdgeInsets.all((16)),
          child: Padding(
            padding: EdgeInsets.only(top: 70),
            child: Container(
              width: double.infinity, // Adjust the width as needed
              height: 45, // Adjust the height as needed
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30.0), // Adjust the radius
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search for products',
                  prefixIcon: Icon(Iconsax.search_normal),
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
