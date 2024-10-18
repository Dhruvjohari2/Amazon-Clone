import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    _user = _auth.currentUser;

    if (_user != null) {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          _nameController.text = userData?['displayName'] ?? '';
          _emailController.text = _user!.email ?? '';
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).update({
        'displayName': _nameController.text,
      });

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person),
            ),
            const SizedBox(height: 20),
            _isEditing
                ? TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  )
                : Text(
                    _nameController.text,
                    style: const TextStyle(fontSize: 24),
                  ),
            const SizedBox(height: 10),
            Text(
              _emailController.text,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _isEditing
                ? ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    child: const Text('Edit Profile'),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
