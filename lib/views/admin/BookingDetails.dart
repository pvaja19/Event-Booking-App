import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingDetails extends StatefulWidget {
  final String bookingId;

  const BookingDetails({super.key, required this.bookingId});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  Map<String, dynamic>? bookingDetails;
  bool isLoading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    fetchBookingDetails();
  }

  Future<void> fetchBookingDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        final eventTime = (data["eventTime"] ?? "").split(" ");
        final date =
            eventTime.length >= 3 ? eventTime.sublist(0, 3).join(" ") : "N/A";
        final time =
            eventTime.length > 3 ? eventTime.sublist(3).join(" ") : "N/A";

        setState(() {
          bookingDetails = {
            "eventName": data["eventName"] ?? "N/A",
            "bookingId": doc.id,
            "userEmail": data["userEmail"] ?? "N/A",
            "date": date,
            "time": time, // Optional
            "location": data["location"] ?? "N/A",
            "seats": data["ticketCount"]?.toString() ?? "0",
            "amount": data["totalPrice"]?.toString() ?? "0",
            "paymentStatus":
                data["paymentMethod"] == "COD" ? "Pending" : "Paid",
          };
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Booking not found.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error fetching data: $e";
        isLoading = false;
      });
    }
  }

  Widget _buildDetailItem(IconData icon, String title, String value,
      {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$title\n",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  TextSpan(
                    text: value.isNotEmpty ? value : "N/A",
                    style: TextStyle(
                      color: isLink ? Colors.blueAccent : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: isLink
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(error, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final isPaid = bookingDetails!["paymentStatus"] == "Paid";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF4C5DAA),
              Color(0xFFF687FF),
            ],
          ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
          child: const Text(
            "Booking Details",
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        bookingDetails!["eventName"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailItem(Icons.confirmation_number, "Booking ID",
                        bookingDetails!["bookingId"]),
                    _buildDetailItem(
                        Icons.email, "Email", bookingDetails!["userEmail"],
                        isLink: true),
                    _buildDetailItem(
                        Icons.calendar_today, "Date", bookingDetails!["date"]),
                    _buildDetailItem(
                        Icons.access_time, "Time", bookingDetails!["time"]),
                    _buildDetailItem(Icons.location_on, "Location",
                        bookingDetails!["location"]),
                    _buildDetailItem(Icons.event_seat, "Seats Booked",
                        bookingDetails!["seats"]),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.payments, color: Colors.greenAccent),
                        const SizedBox(width: 10),
                        Text(
                          "₹ ${bookingDetails!["amount"]}",
                          style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            border: Border.all(
                                color: isPaid ? Colors.green : Colors.red),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPaid ? "Paid" : "Pending",
                            style: TextStyle(
                              color: isPaid
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
