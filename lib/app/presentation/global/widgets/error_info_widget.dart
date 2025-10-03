import 'package:flutter/material.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';

import '../../../core/generated/translations.g.dart';

class ErrorInfoWidget extends StatelessWidget {
  const ErrorInfoWidget({super.key, this.text, this.color, this.icon});

  final String? text;
  final Color? color;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon ?? Icon(Icons.error, color: color),
            5.h,
            Text(
              text ?? texts.global.anErrorHasOccurred,
              style: TextStyle(fontSize: 20, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
