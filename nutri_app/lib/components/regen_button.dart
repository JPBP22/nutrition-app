import 'package:flutter/material.dart';

class RegenButton extends StatelessWidget {
  final VoidCallback onRegenerate;

  const RegenButton({Key? key, required this.onRegenerate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onRegenerate,
      child: Text('Regenerate'),
    );
  }
}
