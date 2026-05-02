import 'package:flutter/material.dart';

enum CmsFieldType { text, richText, number, boolean, date, image, reference, select }

class CmsField {
  final String id;
  String name;
  String apiId;
  CmsFieldType type;
  bool required;
  List<String> selectOptions;

  CmsField({
    required this.id,
    required this.name,
    required this.apiId,
    required this.type,
    this.required = false,
    this.selectOptions = const [],
  });
}

class CmsContentType {
  final String id;
  String name;
  String apiId;
  String description;
  IconData icon;
  Color color;
  List<CmsField> fields;
  int entryCount;
  DateTime createdAt;

  CmsContentType({
    required this.id,
    required this.name,
    required this.apiId,
    this.description = '',
    this.icon = Icons.article_outlined,
    this.color = const Color(0xFF6C63FF),
    this.fields = const [],
    this.entryCount = 0,
    required this.createdAt,
  });
}
