import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  String id;
  String title;
  String note;
  int priority;
  DateTime dueDate;
  String category;
  List<String> tags;
  String? attachmentUrl;

  TodoModel({
    required this.id,
    required this.title,
    required this.note,
    required this.priority,
    required this.dueDate,
    required this.category,
    required this.tags,
    this.attachmentUrl,
  });

  // Firestore'dan veri çekmek için modelin bir fromJson methodu
  factory TodoModel.fromJson(Map<String, dynamic> json, String id) {
    return TodoModel(
      id: id,
      title: json['title'],
      note: json['note'],
      priority: json['priority'],
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      category: json['category'],
      tags: List<String>.from(json['tags']),
      attachmentUrl: json['attachmentUrl'],
    );
  }

  // Firestore'a veri göndermek için bir toJson methodu
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'note': note,
      'priority': priority,
      'dueDate': dueDate,
      'category': category,
      'tags': tags,
      'attachmentUrl': attachmentUrl,
    };
  }
}
