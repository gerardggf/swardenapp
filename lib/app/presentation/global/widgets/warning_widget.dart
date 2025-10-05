import 'package:flutter/material.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';

class WarningWidget extends StatelessWidget {
  const WarningWidget({
    super.key,
    this.title,
    required this.content,
    this.color,
    this.bgColor,
    required this.icon,
  });

  final String? title;
  final String content;
  final Color? color;
  final Color? bgColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.orange.shade50,
        border: Border.all(
          color: color?.withAlpha(120) ?? Colors.orange.shade300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color?.withAlpha(60) ?? Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color ?? Colors.orange.shade700, size: 20),
          ),
          10.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      color: color ?? Colors.orange.shade700,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                Text(
                  content,
                  style: TextStyle(
                    color: color ?? Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
