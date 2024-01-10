import 'package:ecocharge/Common/Toast.dart';
import 'package:ecocharge/Common/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String fullName = '';
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Navigate to different pages based on the selected index
      switch (_selectedIndex) {
        case 0:
        // Home
          break;
        case 1:
        // Navigate to Map
          Navigator.popAndPushNamed(context, "/map");
          showToast(message: "Map screen loading");
          break;
        case 2:
        // Navigate to Profile
          Navigator.pushNamed(context, "/profile");
          break;
        default:
          break;
      }
    });
  }

  Future<void> _fetchUserInfo() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      setState(() {
        fullName = userSnapshot['fullname'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("HomePage"),
        backgroundColor: Colors.red,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Center(
            child: Text(
              'Welcome $fullName!',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
