import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/views/admin/AdminManageEvent.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddNewEvent extends StatefulWidget {
  const AddNewEvent({Key? key}) : super(key: key);

  @override
  State<AddNewEvent> createState() => _AddNewEventState();
}

class _AddNewEventState extends State<AddNewEvent> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController =
      TextEditingController(); // ✅ New

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  File? _selectedImage;
  String? _base64Image;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImage = File(picked.path);
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_eventNameController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _locationController.text.isEmpty ||
        _ticketPriceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _categoryController.text.isEmpty || // ✅ New
        _base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all fields and select image")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('events').add({
        'title': _eventNameController.text,
        'date': Timestamp.fromDate(_selectedDate!),
        'time': _selectedTime!.format(context),
        'location': _locationController.text,
        'description': _descriptionController.text,
        'category': _categoryController.text, // ✅ New
        'price': double.parse(_ticketPriceController.text),
        'imageUrl': _base64Image,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event added successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminManageEvent()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F1F),
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4C5DAA), Color(0xFFF687FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            "Add New Event",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField(
                    controller: _eventNameController,
                    hint: "Enter Event Name",
                    icon: Icons.edit,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() => _selectedDate = pickedDate);
                            }
                          },
                          child: AbsorbPointer(
                            child: _buildInputField(
                              hint: _selectedDate == null
                                  ? "Select Date"
                                  : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                              icon: Icons.date_range,
                              readOnly: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() => _selectedTime = pickedTime);
                            }
                          },
                          child: AbsorbPointer(
                            child: _buildInputField(
                              hint: _selectedTime == null
                                  ? "Select Time"
                                  : _selectedTime!.format(context),
                              icon: Icons.access_time,
                              readOnly: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    controller: _locationController,
                    hint: "Enter Location",
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    controller: _ticketPriceController,
                    hint: "Enter Price",
                    icon: Icons.attach_money,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    controller: _categoryController, // ✅ New
                    hint: "Enter Category",
                    icon: Icons.category,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    controller: _descriptionController,
                    hint: "Describe your event...",
                    icon: Icons.description,
                    maxLines: 3,
                    borderColor: Colors.purpleAccent,
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: _selectedImage == null
                          ? const Center(
                              child: Text(
                                "Tap to select image",
                                style: TextStyle(color: Colors.white60),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F8FFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 100),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _saveEvent,
                      child: const Text(
                        "Save Event",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInputField({
    TextEditingController? controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    Color borderColor = Colors.blueAccent,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: borderColor),
        filled: true,
        fillColor: Colors.grey[850],
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
