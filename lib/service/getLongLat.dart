import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetLongLat extends StatelessWidget {
  final String documentId;

  GetLongLat({required this.documentId});

  @override
  Widget build(BuildContext context) {
    // get collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return FutureBuilder(
        future: users.doc(documentId).get(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Text('${data['longitude']},' + '' + '${data['latitude']}');
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }
}
