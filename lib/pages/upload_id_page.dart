import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_tut_two/pages/documents_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadIDPage extends StatefulWidget {
  const UploadIDPage({Key? key}) : super(key: key);

  @override
  State<UploadIDPage> createState() => _UploadIDPageState();
}

class _UploadIDPageState extends State<UploadIDPage> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
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
      final data = {
        'downloadURL': _profilePictureUrl,
        'dateUploaded': Timestamp.now(),
        'approved': false,
        'authID': currentUser!.uid,
        'IDNumber': _nameController.text.trim(),
        'birthday': _phoneController.text.trim(),
      };
      await FirebaseFirestore.instance
          .collection('nationalIDS')
          .doc(currentUser.uid)
          .set(data);

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DocumentsPage()),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver ID successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload ID'),
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
                      height: 200, // Specifies the size of the circle
                      width:
                          200, // Match the width to the height to create a perfect circle
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
                  color: Colors.red[700],
                  minWidth: double.infinity,
                  child: const Text(
                    'Upload ID Picture',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ID Number',
                    hintText: '32931800',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your ID Number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Birthday',
                    hintText: '01-01-1997',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your birth date';
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
                  },
                  color: Colors.amber[700],
                  minWidth: double.infinity,
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
