import 'package:flutter/material.dart';

enum AnnouncementPriority { normal, high, urgent }

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final AnnouncementPriority priority;
  final bool isRead;
  final DateTime? createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.priority = AnnouncementPriority.normal,
    this.isRead = false,
    this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    AnnouncementPriority parsePriority(String? prio) {
      switch (prio?.toLowerCase()) {
        case 'urgent':
          return AnnouncementPriority.urgent;
        case 'high':
        case 'important':
          return AnnouncementPriority.high;
        default:
          return AnnouncementPriority.normal;
      }
    }

    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      priority: parsePriority(json['priority']?.toString()),
      isRead: json['isRead'] == true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority.name,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    AnnouncementPriority? priority,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Color get priorityColor {
    switch (priority) {
      case AnnouncementPriority.urgent:
        return const Color(0xFFEF4444);
      case AnnouncementPriority.high:
        return const Color(0xFFF59E0B);
      case AnnouncementPriority.normal:
        return const Color(0xFF3B82F6);
    }
  }

  Color get priorityBgColor {
    switch (priority) {
      case AnnouncementPriority.urgent:
        return const Color(0xFFFEF2F2);
      case AnnouncementPriority.high:
        return const Color(0xFFFFFBEB);
      case AnnouncementPriority.normal:
        return const Color(0xFFEFF6FF);
    }
  }

  String get priorityLabel {
    switch (priority) {
      case AnnouncementPriority.urgent:
        return 'URGENT';
      case AnnouncementPriority.high:
        return 'IMPORTANT';
      case AnnouncementPriority.normal:
        return 'UPDATE';
    }
  }
}

