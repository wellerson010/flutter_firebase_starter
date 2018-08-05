import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Babe Names')),
      body: StreamBuilder(
        stream: Firestore.instance.collection('baby').snapshots(),
        builder: (context, snapshot){
          if (!snapshot.hasData){
            return Text('Loading...');
          }

          return ListView.builder(
              itemCount: snapshot.data.documents.length,
              padding: EdgeInsets.only(top: 10.0),
              itemExtent: 55.0,
              itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index]));
        }
      )
    );
  }

    Widget _buildListItem(BuildContext context, DocumentSnapshot document){
      return ListTile(
        key: ValueKey(document.documentID),
        title: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x80000000)),
            borderRadius: BorderRadius.circular(5.0)
          ),
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: Text(document['name'])
              ),
              Text(
                document['votes'].toString()
              )
            ]
          ),
        ),
        onTap: () => Firestore.instance.runTransaction((transaction) async {
          DocumentSnapshot freshSnap = await transaction.get(document.reference);
          await transaction.update(freshSnap.reference, {'votes': freshSnap['votes'] + 1});
        }),
      );
    }
}