import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tut_two/pages/upload_id_page.dart';
import 'package:flutter_tut_two/pages/upload_dl_page.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({Key? key}) : super(key: key);

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _idDataStream;

  @override
  void initState() {
    super.initState();
    _idDataStream = FirebaseFirestore.instance // Access Firestore
        .collection('nationalIDS')
        .doc(FirebaseAuth.instance.currentUser!.uid) // Use current user ID
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[700],
        title: const Text('Documents'), // Set your desired title here
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _idDataStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!.data();
            final imageUrl =
                data?['downloadURL']; // Check if downloadURL exists

            return _buildCard(context, imageUrl); // Pass context here
          } else if (snapshot.hasError) {
            // Handle error
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            ); // Loading indicator
          }
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, String? imageUrl) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: 200,
                  )
                : const Text('No Driver\'s ID Uploaded'),
            const SizedBox(height: 16.0),
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadIDPage()),
                );
              },
              color: Colors.amber[700],
              minWidth: double.infinity,
              child: const Text(
                'Upload ID Picture',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            // Upload DL
            const SizedBox(height: 16.0),
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadDLPage()),
                );
              },
              color: Colors.amber[700],
              minWidth: double.infinity,
              child: const Text(
                'Upload DL Picture',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
