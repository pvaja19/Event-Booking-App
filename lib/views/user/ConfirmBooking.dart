import 'package:flutter/material.dart';

class ConfirmBooking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text("Event Booking App", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1A1D3D),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Summer Music Festival",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                      SizedBox(width: 6),
                      Text("May 15, 2025", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white70, size: 16),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text("Neon Arena\n123 Electric Avenue, Techno City",
                            style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text("Booking ID: #EF24031542", style: TextStyle(color: Colors.white)),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Paid:", style: TextStyle(color: Colors.white)),
                      Text("₹160", style: TextStyle(color: Colors.pinkAccent, fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Date & Time:", style: TextStyle(color: Colors.white)),
                      Text("May 15, 2025   6:00 PM", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Booked Successfully !!",
              style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green[900],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.greenAccent, size: 60),
            ),
            Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[900],
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Cancel ticket logic here
              },
              icon: Icon(Icons.warning_amber_rounded, color: Colors.white),
              label: Text("Cancel Ticket", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
