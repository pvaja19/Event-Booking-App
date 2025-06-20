import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/views/user/MyBookingPage.dart';
import 'package:event_booking/views/user/PaymentPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventDetailPage({Key? key, required this.eventData}) : super(key: key);

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  String _selectedPaymentMethod = 'Debit Card';
  int _selectedTicketCount = 1;
  double _selectedTotalPrice = 0.0;

  final List<String> _paymentMethods = ['Debit Card', 'COD'];

  @override
  Widget build(BuildContext context) {
    String formattedDate = 'No Date';
    String formattedTime = 'No Time';

    if (widget.eventData['date'] != null) {
      try {
        DateTime dateTime = widget.eventData['date'] is String
            ? DateTime.parse(widget.eventData['date'])
            : (widget.eventData['date'] as Timestamp).toDate();
        formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
      } catch (e) {
        formattedDate = widget.eventData['date'].toString();
      }
    }

    if (widget.eventData['time'] != null) {
      try {
        DateTime timeValue = widget.eventData['time'] is String
            ? DateTime.parse(widget.eventData['time'])
            : (widget.eventData['time'] as Timestamp).toDate();
        formattedTime = DateFormat('hh:mm a').format(timeValue);
      } catch (e) {
        formattedTime = widget.eventData['time'].toString();
      }
    }

    String location = widget.eventData['location'] as String? ?? 'No Location';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if (widget.eventData['imageUrl'] != null &&
            //     (widget.eventData['imageUrl'] as String).isNotEmpty)
            //   Image(
            //     image: widget.eventData['imageUrl'] != null &&
            //             (widget.eventData['imageUrl'] as String).isNotEmpty
            //         ? NetworkImage(widget.eventData['imageUrl'])
            //         : const AssetImage('assets/music.jpeg') as ImageProvider,
            //     height: 250,
            //     width: double.infinity,
            //     fit: BoxFit.cover,
            //   )
            // else
            //   const SizedBox(
            //     height: 250,
            //     child: Center(
            //       child:
            //           Text("No Image", style: TextStyle(color: Colors.white70)),
            //     ),
            //   ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.eventData['title'] as String? ?? 'No Title',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRowDateTime(
                      Icons.calendar_today, formattedDate, formattedTime),
                  const SizedBox(height: 8),
                  _buildInfoRowSingle(Icons.location_on, location),
                  const SizedBox(height: 16),
                  const Text(
                    'About Event',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.eventData['description'] as String? ??
                        'No description available',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  BookingCard(
                    price: (widget.eventData['price'] != null)
                        ? (widget.eventData['price'] as num).toDouble()
                        : 80.0,
                    onValueChanged: (count, totalPrice) {
                      _selectedTicketCount = count;
                      _selectedTotalPrice = totalPrice;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10131F),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: const Color(0xFF4F8FFF), width: 2),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedPaymentMethod,
                      dropdownColor: const Color(0xFF10131F),
                      isExpanded: true,
                      underline: const SizedBox(),
                      iconEnabledColor: Colors.white70,
                      style: const TextStyle(color: Colors.white),
                      items: _paymentMethods.map((method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        final eventName =
                            widget.eventData['title'] ?? 'No Title';
                        final eventTime = '$formattedDate $formattedTime';
                        final price =
                            (widget.eventData['price'] ?? 0).toDouble();
                        final totalPrice = price * _selectedTicketCount;

                        if (_selectedPaymentMethod == 'COD') {
                          await FirebaseFirestore.instance
                              .collection('bookings')
                              .add({
                            'eventName': eventName,
                            'eventTime': eventTime,
                            'price': price,
                            'ticketCount': _selectedTicketCount,
                            'totalPrice': totalPrice,
                            'paymentMethod': 'COD',
                            'location': location,
                            'timestamp': FieldValue.serverTimestamp(),
                            'userName': user?.displayName ?? 'Guest',
                            'userEmail': user?.email ?? 'No Email',
                            'userId': user?.uid ?? '',
                          });

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Booking Confirmed"),
                              content: const Text(
                                  "Your booking has been confirmed via COD."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MyBookingPage(),
                                      ),
                                    );
                                  },
                                  child: const Text("OK"),
                                )
                              ],
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentPage(
                                eventName: eventName,
                                eventTime: eventTime,
                                price: price,
                                ticketCount: _selectedTicketCount,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F8FFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowSingle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowDateTime(IconData icon, String date, String time) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Text(date, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(width: 10),
        if (time.isNotEmpty) ...[
          const Icon(Icons.access_time, color: Colors.white70, size: 16),
          const SizedBox(width: 4),
          Text(time,
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ],
    );
  }
}

class BookingCard extends StatefulWidget {
  final double price;
  final Function(int count, double totalPrice) onValueChanged;

  const BookingCard(
      {Key? key, required this.price, required this.onValueChanged})
      : super(key: key);

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  int _count = 1;

  double get _totalPrice => widget.price * _count;

  void _update() {
    widget.onValueChanged(_count, _totalPrice);
  }

  @override
  void initState() {
    super.initState();
    _update();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181B2A),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text('₹ ',
                  style: TextStyle(color: Colors.white70, fontSize: 18)),
              Text(
                widget.price % 1 == 0
                    ? widget.price.toInt().toString()
                    : widget.price.toStringAsFixed(2),
                style: const TextStyle(
                  color: Color(0xFFB6FF6A),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text('per person',
                  style: TextStyle(color: Colors.white54, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF10131F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4F8FFF), width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white, size: 28),
                  onPressed: () {
                    if (_count > 1) {
                      setState(() {
                        _count--;
                      });
                      _update();
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('$_count',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 24)),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 28),
                  onPressed: () {
                    setState(() {
                      _count++;
                    });
                    _update();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Total: ₹ ${_totalPrice.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Color(0xFFB6FF6A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
