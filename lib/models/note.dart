import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:noteit/helpers/helpers.dart';

class Note {
  final String id;
  final String title;
  final DateTime timestamp;
  final String subtitle;
  final String content;
  final Color color;
  final bool isFavourite;
  final List<dynamic> imageUrls;
  final List<dynamic> links;

  Note({
    @required this.id,
    @required this.content,
    @required this.imageUrls,
    @required this.links,
    @required this.subtitle,
    @required this.title,
    @required this.timestamp,
    @required this.color,
    @required this.isFavourite,
  });

  factory Note.fromSnapshot(DocumentSnapshot doc) {
    return Note(
      id: doc.documentID,
      subtitle: doc['subtitle'],
      title: doc['title'],
      timestamp: doc['timestamp'].toDate(),
      color: HexColor(doc['color']),
      isFavourite: doc['isFavourite'],
      imageUrls: doc['imageUrls'],
      links: doc['links'],
      content: doc['content'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'title': title,
      'timestamp': Timestamp.fromDate(timestamp),
      'subtitle': subtitle,
      'content': content,
      'color': '#${color.value.toRadixString(16)}',
      'isFavourite': isFavourite,
      'imageUrls': imageUrls,
      'links': links,
    };
  }
}
