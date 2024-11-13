import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class CustomIconButton extends StatefulWidget {
  const CustomIconButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap,
      required this.isLiked});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLiked;

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Container(
            decoration: BoxDecoration(
              color: widget.isLiked ? kSecondaryDark : kPrimaryLighterDark,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: widget.isLiked ? kPrimaryLighterDark : kSecondaryDark,
                size: 50,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
