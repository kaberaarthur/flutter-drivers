import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Notifications"),
          backgroundColor: Colors.red[700],
        ),
        body: const Center(child: Text("You are not logged in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.amber[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('driverNotifications')
            .where('authID', isEqualTo: currentUserId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No notifications found."));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic>? data =
                  document.data() as Map<String, dynamic>?;
              if (data != null) {
                // Checks if the document data is not null
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.notifications, color: Colors.red[700]),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(data['title'] ?? 'No Title',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 1),
                        Text(data['message'] ?? 'No Message'),
                        SizedBox(height: 1),
                        Text(
                          // Inline conversion of Timestamp to formatted String
                          data['time'] != null
                              ? DateFormat('yyyy-MM-dd – kk:mm')
                                  .format((data['time'] as Timestamp).toDate())
                              : 'No Time',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[850]),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return SizedBox
                    .shrink(); // Returns an empty widget for null document data
              }
            }).toList(),
          );
        },
      ),
    );
  }
}
