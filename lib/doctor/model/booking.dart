import 'package:intl/intl.dart';

class Booking {
  final String date;
  final String description;
  final String id;
  final String receiver;
  final String sender;
  final String status;
  final String time;

  Booking({
    required this.date,
    required this.description,
    required this.id,
    required this.receiver,
    required this.sender,
    required this.status,
    required this.time,
  });

  factory Booking.fromMap(Map<String, dynamic> data) {
    return Booking(
      date: data['date'] ?? '',
      description: data['description'] ?? '',
      id: data['id'] ?? '',
      receiver: data['receiver'] ?? '',
      sender: data['sender'] ?? '',
      status: data['status'] ?? 'pending',
      time: data['time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'description': description,
      'id': id,
      'receiver': receiver,
      'sender': sender,
      'status': status,
      'time': time,
    };
  }
  DateTime get appointmentDateTime {
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    final timeFormat = DateFormat('HH:mm');
    return DateTime(
      dateFormat.parse(date).year,
      dateFormat.parse(date).month,
      dateFormat.parse(date).day,
      timeFormat.parse(time).hour,
      timeFormat.parse(time).minute,
    );
  }
}