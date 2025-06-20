import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlist = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWishlist();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'No Date';
    if (date is Timestamp) {
      return DateFormat('MMM dd, yyyy').format(date.toDate());
    } else if (date is String) {
      return date;
    }
    return 'No Date';
  }

  Future<void> loadWishlist() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('wishlist')
        .where('userId', isEqualTo: userId)
        .get();

    setState(() {
      wishlist = snapshot.docs.map((doc) => doc.data()).toList();
      isLoading = false;
    });
  }

  Future<void> _removeFromWishlist(String eventId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('wishlist')
          .doc('${userId}_$eventId')
          .delete();

      setState(() {
        wishlist.removeWhere((item) => item['eventId'] == eventId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed from wishlist'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Error removing from wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove from wishlist'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text(
          'My Wishlist',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xFF4C5DAA), Color(0xFFF687FF)],
              ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : wishlist.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("No items in wishlist",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16)),
                      SizedBox(height: 10),
                      Text("Add some events to your wishlist!",
                          style:
                              TextStyle(color: Colors.white54, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: wishlist.length,
                  itemBuilder: (context, index) {
                    final item = wishlist[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      color: Colors.grey[900],
                      child: ListTile(
                        leading: item['imageUrl'] != null
                            ? Image.network(
                                item['imageUrl'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/event2.jpeg',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/event2.jpeg',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                        title: Text(
                          item['title'] ?? 'No Title',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          item['location'] ?? 'No Location',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatDate(item['date']),
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () =>
                                  _removeFromWishlist(item['eventId']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
