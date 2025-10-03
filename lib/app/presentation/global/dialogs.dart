import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';

class SwardenDialogs {
  SwardenDialogs._();

  /// Barra de notificació inferior
  static void snackBar({
    required BuildContext context,
    required String text,
    Color? color,
    int milliseconds = 3000,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.fixed,
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color,
            border: color != null
                ? null
                : Border.all(width: 1, color: Colors.white),
          ),
          child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        duration: Duration(milliseconds: milliseconds),
      ),
    );
  }

  /// Diàleg genèric
  static Future<bool?> dialog({
    required BuildContext context,
    required String title,
    required Widget content,
    bool showConfirmButton = true,
  }) async {
    return await showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(title),
          content: content,
          actions: [
            TextButton(
              onPressed: () {
                context.pop(false);
              },
              child: Text(texts.global.cancel),
            ),
            if (showConfirmButton)
              TextButton(
                onPressed: () {
                  context.pop(true);
                },
                child: Text(texts.global.confirm),
              ),
          ],
        );
      },
    );
  }

  static Future<String?> textFieldDialog({
    required BuildContext context,
    required String text,
    required String hintText,
    String? currentText,
  }) async {
    final TextEditingController textController = TextEditingController();
    if (currentText != null) {
      textController.text = currentText;
    }
    return await showDialog(
      context: context,
      builder: (_) => EnterTextDialog(
        text: text,
        hintText: hintText,
        currentText: currentText,
      ),
    );
  }
}

class EnterTextDialog extends StatefulWidget {
  const EnterTextDialog({
    super.key,
    required this.text,
    required this.hintText,
    this.currentText,
  });

  final String text, hintText;

  final String? currentText;

  @override
  State<EnterTextDialog> createState() => _EnterTextDialogState();
}

class _EnterTextDialogState extends State<EnterTextDialog> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentText != null) {
      textController.text = widget.currentText!;
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      title: Text(widget.text),
      content: TextField(
        onTapOutside: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        controller: textController,
        decoration: InputDecoration(hintText: widget.hintText),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(texts.global.cancel),
        ),
        TextButton(
          onPressed: () {
            context.pop(textController.text);
          },
          child: Text(texts.global.confirm),
        ),
      ],
    );
  }
}
