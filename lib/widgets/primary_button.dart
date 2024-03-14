import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;

  final VoidCallback onPressed;

  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          // Set the background color of the button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Set the button shape
          ),
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10)),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.normal),
        maxLines: 1,
      ),
    );
  }
}
