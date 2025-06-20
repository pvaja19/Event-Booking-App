import 'package:event_booking/views/admin/AdminDashboard.dart';
import 'package:event_booking/views/admin/AdminManageBooking.dart';
import 'package:event_booking/views/admin/AdminManageEvent.dart';
import 'package:event_booking/views/admin/AdminProfile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Firestore import
import 'package:firebase_core/firebase_core.dart'; // ✅ Firebase core import

class AdminManageUser extends StatefulWidget {
  const AdminManageUser({Key? key}) : super(key: key);

  @override
  _AdminManageUserState createState() => _AdminManageUserState();
}

class _AdminManageUserState extends State<AdminManageUser> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    await Firebase.initializeApp(); // ✅ Ensures Firebase is initialized
    setState(() {
      _usersFuture = fetchUsersFromFirestore();
    });
  }

  Future<List<Map<String, dynamic>>> fetchUsersFromFirestore() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        // Add a flag to indicate if the user is deleted
        data['isDeleted'] = false;
        return data;
      }).toList();
    } catch (e) {
      print("Firestore fetch error: $e");
      rethrow;
    }
  }

  void onTapNavBar(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()));
    } else if (index == 1) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const AdminManageEvent()));
    } else if (index == 2) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => AdminManageBooking()));
    } else if (index == 3) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const AdminManageUser()));
    } else if (index == 4) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AdminProfile()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4C5DAA), Color(0xFFF687FF)],
          ).createShader(bounds),
          child: const Text(
            'Manage Users',
            style: TextStyle(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print("Snapshot error: ${snapshot.error}"); // ✅ Debug log
                  return const Center(
                      child: Text("Error loading users",
                          style: TextStyle(color: Colors.white)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No users found",
                          style: TextStyle(color: Colors.white)));
                }

                final users = snapshot.data!;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserCard(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1C1C2E),
        selectedItemColor: const Color(0xFF4F8FFF),
        unselectedItemColor: const Color(0xFF8E8E9D),
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        onTap: (index) => onTapNavBar(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(
              icon: Icon(Icons.book_online), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    // If user is deleted, show a different style
    if (user['isDeleted'] == true) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              child: const Icon(Icons.person_off, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? 'No Name',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user['email'] ?? 'No Email',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Deleted",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: user['photoUrl'] != null
                    ? NetworkImage(user['photoUrl'])
                    : const AssetImage('assets/profile.jpeg') as ImageProvider,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'] ?? 'No Name',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user['email'] ?? 'No Email',
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user['phone'] ?? 'No Phone',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color:
                          user['isActive'] == true ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      user['isActive'] == true ? "Active" : "Inactive",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Show confirmation dialog
                      final bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.grey.shade900,
                            title: const Text(
                              'Delete User',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Are you sure you want to delete this user? This action cannot be undone.',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        try {
                          // Mark user as deleted in Firestore instead of actually deleting
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user['uid'])
                              .update({'isDeleted': true});

                          // Show success message
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("User deleted successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }

                          // Refresh the user list
                          setState(() {
                            _usersFuture = fetchUsersFromFirestore();
                          });
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error deleting user: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text("Status",
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const Spacer(),
              Switch(
                value: user['isActive'] ?? false,
                onChanged: (bool value) async {
                  try {
                    // Update user status in Firestore
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user['uid'])
                        .update({'isActive': value});

                    // Show success message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "User ${value ? 'activated' : 'deactivated'} successfully"),
                          backgroundColor: value ? Colors.green : Colors.red,
                        ),
                      );
                    }

                    // Refresh the user list
                    setState(() {
                      _usersFuture = fetchUsersFromFirestore();
                    });
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error updating user status: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
