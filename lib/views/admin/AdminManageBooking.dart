import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/views/admin/AdminDashboard.dart';
import 'package:event_booking/views/admin/AdminManageEvent.dart';
import 'package:event_booking/views/admin/AdminManageUser.dart';
import 'package:event_booking/views/admin/AdminProfile.dart';
import 'package:event_booking/views/admin/BookingDetails.dart';
import 'package:event_booking/views/admin/EditBooking.dart';
import 'package:flutter/material.dart';

class AdminManageBooking extends StatelessWidget {
  AdminManageBooking({Key? key}) : super(key: key);

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
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AdminManageUser()));
    } else if (index == 4) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AdminProfile()));
    }
  }

  Widget _buildStatusCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Map<String, dynamic> booking) {
    Color statusColor =
        booking["status"] == "Confirmed" ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking["eventName"] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.email, size: 16, color: Colors.white70),
              const SizedBox(width: 5),
              Text(booking["userEmail"] ?? '',
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
              const SizedBox(width: 5),
              Text(booking["eventTime"] ?? '',
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${booking["ticketCount"] ?? 0} Tickets",
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "₹ ${booking["totalPrice"] ?? 0}.00",
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  border: Border.all(color: statusColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking["status"] ?? 'Pending',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetails(
                        bookingId: booking['id'],
                      ),
                    ),
                  );
                },
                icon:
                    const Icon(Icons.remove_red_eye, color: Colors.blueAccent),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditBooking(
                        bookingId: booking['id'],
                        booking: booking,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.greenAccent),
              ),
              IconButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.black,
                      title: const Text(
                        'Confirm Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Are you sure you want to delete this booking?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        TextButton(
                          child: const Text('Delete'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final bookingsRef =
                        FirebaseFirestore.instance.collection('bookings');
                    await bookingsRef.doc(booking['id']).delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Booking deleted')),
                    );
                  }
                },
                icon: const Icon(Icons.delete, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference bookingsRef =
        FirebaseFirestore.instance.collection('bookings');

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1C1C2E),
        selectedItemColor: const Color(0xFF4F8FFF),
        unselectedItemColor: const Color(0xFF8E8E9D),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        currentIndex: 2,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Manage Bookings',
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
                        const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                      ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: bookingsRef.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final bookings = snapshot.data!.docs;
                    final confirmed = bookings
                        .where((doc) =>
                            (doc.data() as Map<String, dynamic>)['status'] ==
                            'Confirmed')
                        .length;
                    final cancelled = bookings
                        .where((doc) =>
                            (doc.data() as Map<String, dynamic>)['status'] ==
                            'Cancelled')
                        .length;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatusCard("Total Bookings",
                                bookings.length.toString(), Colors.blue),
                            _buildStatusCard(
                                "Confirmed", "$confirmed", Colors.green),
                            _buildStatusCard(
                                "Cancelled", "$cancelled", Colors.red),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final doc = bookings[index];
                              final booking =
                                  doc.data() as Map<String, dynamic>;
                              booking['id'] = doc.id;
                              return _buildBookingCard(context, booking);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
