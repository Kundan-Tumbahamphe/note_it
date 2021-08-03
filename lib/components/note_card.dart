import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noteit/configs/configs.dart';
import 'package:noteit/models/models.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  NoteCard({@required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      color: note.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        children: <Widget>[
          note.imageUrls.isNotEmpty
              ? Container(
                  width: double.infinity,
                  height: 120.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: note.imageUrls.last,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : SizedBox.shrink(),
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  note.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Constants.noteTextColor,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  note.subtitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                  style: const TextStyle(
                    fontSize: 13.0,
                    letterSpacing: 0.2,
                    color: Constants.noteTextColor,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      DateFormat.yMMMMd().format(note.timestamp),
                      style: const TextStyle(
                        fontSize: 11.0,
                        letterSpacing: 0.2,
                        color: Constants.noteTextColor,
                      ),
                    ),
                    note.isFavourite == true
                        ? const Icon(
                            Icons.star,
                            size: 15.0,
                            color: Color(0xFF454545),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
