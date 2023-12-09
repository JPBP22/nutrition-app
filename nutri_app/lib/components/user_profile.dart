import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'circle_image.dart';

class AuthorCard extends StatefulWidget {
  final ImageProvider? imageProvider;

  const AuthorCard({
    super.key,
    this.imageProvider,
  });

  @override
  AuthorCardState createState() => AuthorCardState();
}

class AuthorCardState extends State<AuthorCard> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleImage(
                imageProvider: widget.imageProvider,
                imageRadius: 28,
              ),
              const SizedBox(width: 8),
        ],
      ),
      );
  }
}