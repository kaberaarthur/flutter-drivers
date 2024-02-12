import 'package:flutter_tut_two/pages/messages_page.dart';
import 'package:flutter_tut_two/pages/home_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // For Clipboard.setData
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class RidesListPage extends StatefulWidget {
  const RidesListPage({super.key});

  @override
  State<RidesListPage> createState() => _RidesListPageState();
}

class _RidesListPageState extends State<RidesListPage> {
  String? currentUserId;
  DocumentSnapshot<Map<String, dynamic>>? driverData;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      getDriverData();
    }
  }

  Future<void> getDriverData() async {
    try {
      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(currentUserId)
          .get();
      if (driverDoc.exists) {
        setState(() {
          driverData = driverDoc;
        });
      }
    } catch (e) {
      _showSnackbar('Failed to load driver data');
      debugPrint('No Driver Data Found');
    }
  }

  Future<void> _acceptRide(String documentId) async {
    if (driverData == null || !driverData!.exists) {
      _showSnackbar('Driver data is not available');
      return;
    }

    try {
      final rideDoc = await FirebaseFirestore.instance
          .collection('rides')
          .doc(documentId)
          .get();

      // Extract needed data from rideDoc
      final riderName = rideDoc.data()!['riderName'];
      final riderPhone = rideDoc.data()!['riderPhone'];

      await FirebaseFirestore.instance
          .collection('rides')
          .doc(documentId)
          .update({
        'rideStatus': '2',
        'driverName': driverData!.data()!['name'],
        'driverPhone': driverData!.data()!['phone'],
        'driverId': documentId,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RiderContactPage(
            documentId: documentId,
            riderName: riderName,
            riderPhone: riderPhone,
            // ... (pass other extracted data)
          ),
        ),
      );
    } catch (e) {
      _showSnackbar('Failed to accept ride');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
            title: Text("Rides List"), backgroundColor: Colors.amber[700]),
        body: Center(child: Text("You are not logged in.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Rides List"),
        backgroundColor: Colors.amber[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .where('rideStatus', isEqualTo: '1')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No rides available."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String riderInitial = data['riderName'][0].toUpperCase();
              String riderName = data['riderName'];
              String documentId = document.id;

              return Card(
                child: Row(
                  children: [
                    // Profile picture or initial
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircleAvatar(
                        radius: 40.0,
                        backgroundColor: Colors.amber[700],
                        child: data['riderProfilePicture'] != null
                            ? ClipOval(
                                child: Image.network(
                                    data['riderProfilePicture'],
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100))
                            : Text(riderInitial,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.grey[900])),
                      ),
                    ),
                    // Rider name and accept button
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(riderName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _acceptRide(documentId),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[900],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0))),
                            child: Text("Accept Ride"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Rider Contact Page
class RiderContactPage extends StatelessWidget {
  final String documentId;
  final String riderName;
  final String riderPhone;

  const RiderContactPage({
    Key? key,
    required this.documentId,
    required this.riderName,
    required this.riderPhone,
  }) : super(key: key);

  Future<void> _copyToClipboard(String text, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to Clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _cancelRide(BuildContext context) async {
    try {
      // Get a reference to the document
      final docRef =
          FirebaseFirestore.instance.collection('rides').doc(documentId);

      // Update the rideStatus field to '1' (canceled)
      await docRef.update({'rideStatus': '1'});

      // Show a success message and navigate to HomePage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ride canceled successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (error) {
      // Handle any potential errors
      print('Error canceling ride: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error canceling ride. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rider Contact"),
        backgroundColor: Colors.amber[700],
      ),
      body: Center(
        child: Card(
          elevation: 4.0,
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment
                  .stretch, // Makes child widgets stretch to fill the card width
              children: <Widget>[
                SizedBox(height: 16),
                Text(
                  'Rider Name',
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text(
                  riderName,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                SizedBox(height: 16),
                Text(
                  'Rider Phone',
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text(
                  riderPhone,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    debugPrint('Go to Pickup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      // Setting the shape
                      borderRadius: BorderRadius.circular(
                          4), // Rounded corners with a radius of 4
                    ),
                  ),
                  child: const Text('GO TO PICKUP'),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceEvenly, // Distributes the icons evenly across the row
                  children: [
                    _iconButton(
                      context,
                      Icons.phone,
                      'Call',
                      () => _copyToClipboard(riderPhone, context),
                    ),
                    _iconButton(
                      context,
                      Icons.message,
                      'Message',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagesPage(
                              rideId: documentId,
                            ),
                          ),
                        );
                      },
                    ),
                    _iconButton(
                      context,
                      Icons.delete_sharp,
                      'Cancel',
                      () => _cancelRide(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: Colors.grey[900],
          ),
          color: Theme.of(context).primaryColor,
          onPressed: onTap,
        ),
        Text(label),
      ],
    );
  }
}
