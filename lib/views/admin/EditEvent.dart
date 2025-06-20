import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/views/admin/AdminManageEvent.dart';

class EditEvent extends StatefulWidget {
  final Map<String, dynamic> eventData;
  const EditEvent({Key? key, required this.eventData}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEvent> {
  late TextEditingController eventNameController;
  late TextEditingController locationController;
  late TextEditingController categoryController;
  late TextEditingController ticketPriceController;
  late TextEditingController descriptionController;

  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late bool isActive;

  @override
  void initState() {
    super.initState();
    final data = widget.eventData;
    eventNameController = TextEditingController(text: data['title'] ?? "");
    locationController = TextEditingController(text: data['location'] ?? "");
    categoryController = TextEditingController(text: data['category'] ?? "");
    ticketPriceController =
        TextEditingController(text: data['price']?.toString() ?? "");
    descriptionController =
        TextEditingController(text: data['description'] ?? "");

    // Date
    if (data['date'] != null) {
      if (data['date'] is DateTime) {
        selectedDate = data['date'];
      } else if (data['date'] is String) {
        selectedDate = DateTime.tryParse(data['date']) ?? DateTime.now();
      } else {
        selectedDate =
            (data['date'] as dynamic).toDate?.call() ?? DateTime.now();
      }
    } else {
      selectedDate = DateTime.now();
    }

    // Time
    if (data['time'] != null) {
      if (data['time'] is String) {
        final timeParts = data['time'].split(":");
        int hour = int.tryParse(timeParts[0]) ?? 0;
        int minute = 0;
        if (timeParts.length > 1) {
          minute = int.tryParse(timeParts[1].split(' ')[0]) ?? 0;
        }
        selectedTime = TimeOfDay(hour: hour, minute: minute);
      } else {
        selectedTime = TimeOfDay.now();
      }
    } else {
      selectedTime = TimeOfDay.now();
    }

    isActive = data['isActive'] ?? true;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF2A2A40),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B2F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B2F),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF4C5DAA),
              Color(0xFFF687FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Edit Event',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Banner Section
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent, width: 1),
              ),
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  // Change banner logic here
                },
                child: const Text("Change Banner"),
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField("Event Name", Icons.event, eventNameController),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: _buildTextField(
                        "Date",
                        Icons.calendar_today,
                        TextEditingController(
                            text: "${selectedDate.toLocal()}".split(' ')[0]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: AbsorbPointer(
                      child: _buildTextField(
                        "Time",
                        Icons.access_time,
                        TextEditingController(
                            text: selectedTime.format(context)),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            _buildTextField("Location", Icons.location_on, locationController),
            _buildTextField("Category", Icons.category, categoryController),
            _buildTextField(
                "Ticket Price", Icons.currency_rupee, ticketPriceController),
            _buildTextField(
                "Description", Icons.description, descriptionController,
                maxLines: 3),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Status",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                Switch(
                  value: isActive,
                  activeColor: Colors.green,
                  onChanged: (value) => setState(() => isActive = value),
                )
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final docId = widget.eventData['id'];
                if (docId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Event ID not found!")),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('events')
                      .doc(docId)
                      .update({
                    'title': eventNameController.text,
                    'location': locationController.text,
                    'category': categoryController.text,
                    'price': double.tryParse(ticketPriceController.text) ?? 0,
                    'description': descriptionController.text,
                    'date': selectedDate,
                    'time': selectedTime.format(context),
                    'isActive': isActive,
                  });

                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminManageEvent()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Edited event successfully")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Save Event", style: TextStyle(fontSize: 16)),
            ),
            TextButton.icon(
              onPressed: () {
                // Delete event logic here
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text("Delete Event",
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
