import 'package:flutter/material.dart';

class Reservation {
  final String id;
  final String userId;
  final DateTime date;
  final TimeOfDay time;
  final int numberOfGuests;
  final String? specialRequests;
  final ReservationStatus status;
  final String? tableNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reservation({
    required this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.numberOfGuests,
    this.specialRequests,
    required this.status,
    this.tableNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      time: _parseTimeOfDay(json['time']),
      numberOfGuests: json['number_of_guests'],
      specialRequests: json['special_requests'],
      status: ReservationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ReservationStatus.pending,
      ),
      tableNumber: json['table_number'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'number_of_guests': numberOfGuests,
      'special_requests': specialRequests,
      'status': status.toString().split('.').last,
      'table_number': tableNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Reservation copyWith({
    String? id,
    String? userId,
    DateTime? date,
    TimeOfDay? time,
    int? numberOfGuests,
    String? specialRequests,
    ReservationStatus? status,
    String? tableNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      time: time ?? this.time,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      tableNumber: tableNumber ?? this.tableNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ReservationStatus {
  pending,
  confirmed,
  seated,
  completed,
  cancelled,
  noShow,
}
