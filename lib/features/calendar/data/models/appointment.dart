import 'package:flutter/material.dart';

enum AppointmentType { clinic, grooming, vaccination, other }

class Appointment {
  final String id;
  final AppointmentType type;
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final String petId;
  final String? notes;

  const Appointment({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.time,
    required this.petId,
    this.notes,
  });
}
