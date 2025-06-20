import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_booking/models/EventModel.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEvent(EventModel event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  Stream<List<EventModel>> getAllEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data()))
          .toList();
    });
  }
}
