import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rider Contact"),
        backgroundColor: Colors.amber[700],
      ),
      body: Center(
        // Centering the card in the middle of the screen
        child: Card(
          elevation: 4.0, // Adds a slight shadow to the card for depth
          margin: const EdgeInsets.all(20.0), // Adds margin around the card
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Padding inside the card
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Minimizes the card size to wrap its content
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Aligns content to the start of the card
              children: <Widget>[
                Text(
                  'Rider Name:',
                  style: Theme.of(context)
                      .textTheme
                      .headline6, // Larger text for the label
                ),
                Text(
                  riderName,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1, // Slightly smaller text for the name
                ),
                SizedBox(height: 16), // Adds spacing between name and phone
                Text(
                  'Rider Phone:',
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text(
                  riderPhone,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
