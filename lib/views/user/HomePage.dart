import 'package:event_booking/views/user/EventDetailPage.dart';
import 'package:event_booking/views/user/EventPage.dart';
import 'package:event_booking/views/user/MyBookingPage.dart';
import 'package:event_booking/views/user/ProfilePage.dart';
import 'package:event_booking/views/user/NotificationPage.dart';
import 'package:event_booking/views/user/WishlistPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _eventList = [];
  List<Map<String, dynamic>> _filteredEventList = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterEvents(String query) {
    setState(() {
      _filteredEventList = _eventList.where((event) {
        final title = event['title']?.toString().toLowerCase() ?? '';
        final location = event['location']?.toString().toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return title.contains(searchLower) || location.contains(searchLower);
      }).toList();
    });
  }

  void fetchEvents() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('events').get();
      List<Map<String, dynamic>> temp = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();

      setState(() {
        _eventList = temp;
        _filteredEventList = temp;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        _eventList = [];
        _filteredEventList = [];
        _isLoading = false;
      });
    }
  }

  void onTapNavBar(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EventPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyBookingPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  void _addToWishlist(Map<String, dynamic> event) async {
    final user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must be logged in to add to wishlist.")),
      );
      return;
    }

    try {
      await _firestore
          .collection('wishlist')
          .doc('${user.uid}_${event['id']}')
          .set({
        'userId': user.uid,
        'eventId': event['id'],
        'title': event['title'],
        'location': event['location'],
        'date': event['date'],
        'imageUrl': event['imageUrl'],
        'category': event['category'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to wishlist!")),
      );

      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const WishlistPage()));
    } catch (e) {
      print("Error adding to wishlist: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add to wishlist.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedEvents = _filteredEventList.where((event) {
      return _selectedCategory == 'All' ||
          (event['category'] != null &&
              event['category'].toString().toLowerCase() ==
                  _selectedCategory.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1F),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1C1C2E),
        selectedItemColor: const Color(0xFF4F8FFF),
        unselectedItemColor: const Color(0xFF8E8E9D),
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) => onTapNavBar(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchField(),
              const SizedBox(height: 16),
              _buildCategoryChips(),
              const SizedBox(height: 16),
              _buildPromoBanner(),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (displayedEvents.isEmpty)
                const Center(
                  child: Text(
                    "No events found",
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              else
                ...displayedEvents.map((event) => _buildEventCard(
                      context: context,
                      event: event,
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF4C5DAA), Color(0xFFF687FF)],
              ).createShader(bounds),
              child: const Text(
                'Event Booking App',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Find your next experience',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterEvents,
        style: const TextStyle(color: Colors.white70),
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.white),
          hintText: 'Search events',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildCategoryChip("All", _selectedCategory == "All"),
        _buildCategoryChip("Music", _selectedCategory == "Music"),
        _buildCategoryChip("Tech", _selectedCategory == "Tech"),
        _buildCategoryChip("Sports", _selectedCategory == "Sports"),
        _buildCategoryChip("Art", _selectedCategory == "Art"),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF687FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.card_giftcard, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '20% OFF on your first booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Use Code WELCOME20',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
          _searchController.clear();
          _filteredEventList = _eventList;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F8FFF) : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required BuildContext context,
    required Map<String, dynamic> event,
  }) {
    String formattedDate = '';
    String formattedTime = '';

    if (event['date'] is Timestamp) {
      DateTime dateTime = (event['date'] as Timestamp).toDate();
      formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
      formattedTime = DateFormat('hh:mm a').format(dateTime);
    } else if (event['date'] is String) {
      formattedDate = event['date'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: event['imageUrl'] != null &&
                    event['imageUrl'].toString().startsWith('http')
                ? Image.network(
                    event['imageUrl'],
                    fit: BoxFit.cover,
                    height: 150,
                    width: double.infinity,
                  )
                : Image.asset(
                    'assets/tech.jpeg',
                    fit: BoxFit.cover,
                    height: 150,
                    width: double.infinity,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? 'No Title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on,
                        color: Colors.white70, size: 16),
                    Text(
                      event['location'] ?? 'No Location',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailPage(eventData: event),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F8FFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _addToWishlist(event),
                      child: const Icon(Icons.favorite_border,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
