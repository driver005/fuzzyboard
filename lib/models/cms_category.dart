import 'package:flutter/material.dart';

class CmsCategory {
  final String id;
  String name;
  String slug;
  String description;
  Color color;
  int entryCount;
  String? parentId;
  DateTime createdAt;

  CmsCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.color = const Color(0xFF6C63FF),
    this.entryCount = 0,
    this.parentId,
    required this.createdAt,
  });
}
