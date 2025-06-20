import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String name;
  final DateTime date;
  final String time;
  final String location;
  final String description;
  final double price;

  EventModel({
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': Timestamp.fromDate(date),
      'time': time,
      'location': location,
      'description': description,
      'price': price,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      name: map['name'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      time: map['time'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
    );
  }
}
