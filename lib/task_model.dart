import 'package:cloud_firestore/cloud_firestore.dart';


class Task {
  String id;
  String title;
  bool completed;
  String? imageBase64;
  Timestamp createdAt;
  String ownerId;
  String ownerEmail;
  bool shared;
  String? completedBy;

  Task({
    required this.id,
    required this.title,
    required this.completed,
    this.imageBase64,
    required this.createdAt,
    required this.ownerId,
    required this.ownerEmail,
    required this.shared,
    this.completedBy,
  });

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      title: data['title'] ?? '',
      completed: data['completed'] ?? false,
      imageBase64: data['imageBase64'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      ownerId: data['ownerId'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      shared: data['shared'] ?? false,
      completedBy: data['completedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'completed': completed,
      'imageBase64': imageBase64,
      'createdAt': createdAt,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'shared': shared,
      'completedBy': completedBy,
    };
  }
}
