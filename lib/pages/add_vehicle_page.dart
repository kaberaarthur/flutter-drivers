import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_tut_two/pages/menu_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({Key? key}) : super(key: key);

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _vehicleColorController = TextEditingController();
  final _brandController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _modelController = TextEditingController();
  final _vehicleCCController = TextEditingController();
  final _yearController = TextEditingController();
  File? _image;
  String? _profilePictureUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _uploadProfilePicture() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${currentUser!.uid}_$timeStamp.jpg';
    final ref = FirebaseStorage.instance
        .ref()
        .child('driver-profile-pictures')
        .child(fileName);
    final uploadTask = ref.putFile(_image!);
    await uploadTask.whenComplete(() => null);
    _profilePictureUrl = await ref.getDownloadURL();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload a profile picture'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Upload profile picture and wait for it to complete
      await _uploadProfilePicture();

      // Proceed with profile update
      final currentUser = FirebaseAuth.instance.currentUser;
      final dateRegistered = Timestamp.now();
      final data = {
        'brand': _brandController.text.trim(),
        'model': _modelController.text.trim(),
        'year': _yearController.text.trim(),
        'licensePlate': _licensePlateController.text.trim(),
        'color': _vehicleColorController.text.trim(),
        'engineCapacity': _vehicleCCController.text.trim(),
        'logbook': _profilePictureUrl,
        'dateCreated': dateRegistered,
        'approved': false,
        'owner': currentUser!.uid,
      };
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(currentUser.uid)
          .set(data);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        backgroundColor: Colors.amber[700],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: ClipOval(
                    child: Image.file(
                      _image!,
                      height: 200,
                      fit: BoxFit
                          .cover, // Ensures the image covers the clip area
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: MaterialButton(
                  onPressed: () async {
                    final pickedImage =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedImage != null) {
                      setState(() {
                        _image = File(pickedImage.path);
                      });
                    }
                  },
                  color: Colors.red[600],
                  minWidth: double.infinity,
                  child: const Text(
                    'Upload Logbook Picture',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Add Vehicle Input Text Fields
              // Vehicle Brand
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(labelText: 'Brand'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Brand (Toyota)';
                    }
                    return null;
                  },
                ),
              ),

              // Model Name
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(labelText: 'Model'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Brand (Toyota)';
                    }
                    return null;
                  },
                ),
              ),

              // Manufacture Year
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextFormField(
                  controller: _yearController,
                  decoration:
                      const InputDecoration(labelText: 'Manufacture Year'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Vehicle Manufacture Year (2020)';
                    }
                    return null;
                  },
                ),
              ),

              // Vehicle Color
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextFormField(
                  controller: _vehicleColorController,
                  decoration: const InputDecoration(labelText: 'Vehicle Color'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Vehicle Color (Silver)';
                    }
                    return null;
                  },
                ),
              ),

              // License Plate
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextFormField(
                  controller: _licensePlateController,
                  decoration:
                      const InputDecoration(labelText: 'Vehicle Registration'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Vehicle License Plate';
                    }
                    return null;
                  },
                ),
              ),

              // Vehicle CC
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextFormField(
                  controller: _vehicleCCController,
                  decoration:
                      const InputDecoration(labelText: 'Engine Capacity'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter Vehicles Engine Capacity";
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: MaterialButton(
                  onPressed: () {
                    _updateProfile();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MenuPage()), // Replace NextScreen with your screen
                    );
                  },
                  color: Colors.amber[700],
                  minWidth: double.infinity,
                  child: const Text(
                    'Add Vehicle',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
