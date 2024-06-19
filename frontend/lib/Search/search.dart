import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String _searchQuery = '';

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
              ), // Adjust the radius

              child: Column(
                children: [
                  TextField(
                    onChanged: (value){
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search for products',
                      prefixIcon: Icon(Iconsax.search_normal),
                    ),
                  ),
                  ElevatedButton(onPressed: () {
                    
                  }, child: Text('Search')),
                  
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Container(decoration: BoxDecoration(color: Colors.white),
            child:  _buildSearchResults(context),),
        )
       
      ],
    ));
  }

  Widget _buildSearchResults(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Videos')
        .where('title', isGreaterThanOrEqualTo: _searchQuery)
        .where('category', isGreaterThanOrEqualTo: _searchQuery)
        .where('title', isLessThan: _searchQuery + '\uf8ff')
        .where('category', isLessThan: _searchQuery + '\uf8ff')
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }

      var results = snapshot.data!.docs;

      return ListView.builder(
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (context, index) {
          // Build your list item UI here
          var document = results[index];
          return ListTile(
            title: Text(document['title']),
            subtitle: Text(document['description']),
            // Add more UI elements as needed
          );
        },
      );
    },
  );
}

}
