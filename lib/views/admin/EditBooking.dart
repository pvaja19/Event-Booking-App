import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditBooking extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic>? booking;

  const EditBooking({
    Key? key,
    required this.bookingId,
    this.booking,
  }) : super(key: key);

  @override
  State<EditBooking> createState() => _EditBookingState();
}

class _EditBookingState extends State<EditBooking> {
  // ValueNotifiers to manage mutable values
  late ValueNotifier<int> seats;
  late ValueNotifier<String> paymentStatus;
  late ValueNotifier<String> eventStatus;
  final double pricePerSeat = 100.0;

  final List<String> paymentStatusOptions = ['Paid', 'Pending'];
  final List<String> eventStatusOptions = ['Confirmed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    // Initialize with booking data if available
    seats = ValueNotifier<int>(widget.booking?['ticketCount'] ?? 2);
    paymentStatus =
        ValueNotifier<String>(widget.booking?['paymentStatus'] ?? 'Paid');
    eventStatus =
        ValueNotifier<String>(widget.booking?['status'] ?? 'Confirmed');
  }

  @override
  void dispose() {
    seats.dispose();
    paymentStatus.dispose();
    eventStatus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF4C5DAA),
              Color(0xFFF687FF),
            ],
          ).createShader(bounds),
          child: const Text(
            'Edit Booking',
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildBookedByCard(),
            const SizedBox(height: 20),
            _buildSeatsSection(),
            const SizedBox(height: 20),
            _buildDropdown(
                "Payment Status", paymentStatusOptions, paymentStatus),
            const SizedBox(height: 20),
            _buildDropdown("Event Status", eventStatusOptions, eventStatus),
            const SizedBox(height: 30),
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              widget.booking?['eventName'] ?? "Event Name",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: Colors.blueAccent, size: 18),
              const SizedBox(width: 5),
              Text(widget.booking?['eventTime'] ?? "Date",
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blueAccent, size: 18),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  widget.booking?['location'] ?? "Location",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookedByCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Booked By",
            style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            widget.booking?['userEmail'] ?? "user@email.com",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatsSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // <<< left align
        children: [
          const Text(
            "Number of Seats Booked", // <<< NEW TEXT
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ValueListenableBuilder<int>(
            valueListenable: seats,
            builder: (context, value, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.white),
                    onPressed: () {
                      if (value > 1) {
                        seats.value--;
                      }
                    },
                  ),
                  Text(
                    "$value",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.white),
                    onPressed: () {
                      seats.value++;
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<int>(
            valueListenable: seats,
            builder: (context, value, child) {
              double totalPrice = value * pricePerSeat;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.currency_rupee, color: Colors.blueAccent),
                    const SizedBox(width: 10),
                    Text(
                      totalPrice.toStringAsFixed(2),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      String title, List<String> options, ValueNotifier<String> selectedValue) {
    return ValueListenableBuilder<String>(
      valueListenable: selectedValue,
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButtonFormField<String>(
            dropdownColor: Colors.grey.shade900,
            decoration: InputDecoration(
              labelText: title,
              labelStyle: const TextStyle(color: Colors.blueAccent),
              border: InputBorder.none,
            ),
            value: value,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.white),
            onChanged: (val) {
              if (val != null) {
                selectedValue.value = val;
              }
            },
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () async {
          try {
            // Update booking in Firestore
            await FirebaseFirestore.instance
                .collection('bookings')
                .doc(widget.bookingId)
                .update({
              'ticketCount': seats.value,
              'totalPrice': seats.value * pricePerSeat,
              'paymentStatus': paymentStatus.value,
              'status': eventStatus.value,
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Booking Updated Successfully")),
              );
              Navigator.pop(context);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error updating booking: $e")),
              );
            }
          }
        },
        child: const Text(
          'Save Changes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
