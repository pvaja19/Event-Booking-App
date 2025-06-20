import 'package:event_booking/views/admin/AddNewEvent.dart';
import 'package:event_booking/views/admin/AdminDashboard.dart';
import 'package:event_booking/views/admin/AdminManageBooking.dart';
import 'package:event_booking/views/admin/AdminManageUser.dart';
import 'package:event_booking/views/admin/AdminProfile.dart';
import 'package:event_booking/views/admin/EditEvent.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminManageEvent extends StatefulWidget {
  const AdminManageEvent({Key? key}) : super(key: key);

  @override
  State<AdminManageEvent> createState() => _AdminManageEventState();
}

class _AdminManageEventState extends State<AdminManageEvent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _eventList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('events').get();
      final tempList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();

      setState(() {
        _eventList = tempList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        _eventList = [];
        _isLoading = false;
      });
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _firestore.collection('events').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: Colors.redAccent),
      );
      fetchEvents();
    } catch (e) {
      print('Error deleting event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to delete event'),
            backgroundColor: Colors.orange),
      );
    }
  }

  Future<void> updateEventStatus(String id, bool isActive) async {
    try {
      await _firestore
          .collection('events')
          .doc(id)
          .update({'isActive': isActive});
      fetchEvents();
    } catch (e) {
      print('Error updating event status: $e');
    }
  }

  Future<void> sendNotification(Map<String, dynamic> event) async {
    try {
      await _firestore.collection('notifications').add({
        'title': 'Upcoming Event: ${event['title']}',
        'description':
            '${event['title']} is scheduled on ${_formatDate(event['date'])} at ${event['time']} in ${event['location']}.',
        'eventId': event['id'],
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': event['imageUrl'] ?? '',
        'price': event['price'] ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification sent to users!')),
      );
    } catch (e) {
      print('Error sending notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send notification')),
      );
    }
  }

  void onTapNavBar(BuildContext context, int index) {
    final pages = [
      const AdminDashboard(),
      const AdminManageEvent(),
      AdminManageBooking(),
      AdminManageUser(),
      const AdminProfile()
    ];
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => pages[index]));
  }

  String _formatDate(dynamic dateField) {
    if (dateField is Timestamp) {
      return DateFormat('yyyy-MM-dd').format(dateField.toDate());
    } else if (dateField is String) {
      return dateField;
    } else {
      return '';
    }
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final formattedDate = _formatDate(event['date']);
    final formattedTime = event['time'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent, width: 1),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: (event['imageUrl'] != null &&
                    event['imageUrl'].toString().isNotEmpty)
                ? Image.network(
                    event['imageUrl'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/event1.jpg',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/event1.jpg',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.white54),
                    const SizedBox(width: 5),
                    Text(formattedDate,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    const SizedBox(width: 10),
                    const Icon(Icons.access_time,
                        size: 14, color: Colors.white54),
                    const SizedBox(width: 5),
                    Text(formattedTime,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.white54),
                    const SizedBox(width: 5),
                    Text(event['location'] ?? '',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    const SizedBox(width: 10),
                    const Icon(Icons.currency_rupee,
                        size: 14, color: Colors.white54),
                    Text(
                      event['price']?.toString() ?? '-',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          (event['isActive'] ?? false) ? 'Active' : 'Cancelled',
                          style: TextStyle(
                            color: (event['isActive'] ?? false)
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: event['isActive'] ?? false,
                          onChanged: (val) =>
                              updateEventStatus(event['id'], val),
                          activeColor: Colors.greenAccent,
                          inactiveThumbColor: Colors.redAccent,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: Colors.greenAccent),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EditEvent(eventData: event)),
                            ).then((_) => fetchEvents());
                          },
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => deleteEvent(event['id']),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => sendNotification(event),
                    child: const Text('Send Notification',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1F),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1C1C2E),
        selectedItemColor: const Color(0xFF4F8FFF),
        unselectedItemColor: const Color(0xFF8E8E9D),
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Manage Events',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [
                                Color(0xFF4C5DAA),
                                Color(0xFFF687FF),
                              ],
                            ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddNewEvent()),
                          ).then((_) => fetchEvents());
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('+ Add New Event',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: _eventList.isEmpty
                          ? const Center(
                              child: Text('No events available',
                                  style: TextStyle(color: Colors.white)))
                          : ListView.builder(
                              itemCount: _eventList.length,
                              itemBuilder: (_, i) =>
                                  _buildEventCard(_eventList[i]),
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
