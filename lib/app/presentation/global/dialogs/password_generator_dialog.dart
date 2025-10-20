import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:swardenapp/app/core/constants/colors.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';

Future<String?> showPasswordGeneratorDialog(
  BuildContext context, {
  bool copyPswdOption = false,
}) async {
  final generatedPassword = await showDialog<String>(
    context: context,
    builder: (context) =>
        PasswordGeneratorDialog(copyPswdOption: copyPswdOption),
  );

  return generatedPassword;
}

class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({super.key, required this.copyPswdOption});

  final bool copyPswdOption;

  @override
  State<PasswordGeneratorDialog> createState() =>
      _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  String _generatedPassword = '';
  int _length = 16;
  bool _useUppercase = true;
  bool _useLowercase = true;
  bool _useNumbers = true;
  bool _useSymbols = true;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (_useUppercase) chars += uppercase;
    if (_useLowercase) chars += lowercase;
    if (_useNumbers) chars += numbers;
    if (_useSymbols) chars += symbols;

    if (chars.isEmpty) {
      chars = lowercase;
    }

    final random = Random.secure();
    _generatedPassword = List.generate(
      _length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: FittedBox(
        alignment: AlignmentGeometry.centerLeft,
        fit: BoxFit.scaleDown,
        child: Text(texts.entries.passwordGenerator),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      _generatedPassword,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _generatePassword,
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            24.h,
            Text(
              '${texts.entries.length}: $_length',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _length.toDouble(),
              min: 8,
              max: 32,
              divisions: 24,
              label: _length.toString(),
              onChanged: (value) {
                setState(() {
                  _length = value.toInt();
                });
                _generatePassword();
              },
            ),
            const Divider(),
            CheckboxListTile(
              title: Text(texts.entries.uppercaseLetters),
              value: _useUppercase,
              onChanged: (value) {
                setState(() {
                  _useUppercase = value ?? true;
                });
                _generatePassword();
              },
            ),
            CheckboxListTile(
              title: Text(texts.entries.lowercaseLetters),
              value: _useLowercase,
              onChanged: (value) {
                setState(() {
                  _useLowercase = value ?? true;
                });
                _generatePassword();
              },
            ),
            CheckboxListTile(
              title: Text(texts.entries.numbers),
              value: _useNumbers,
              onChanged: (value) {
                setState(() {
                  _useNumbers = value ?? true;
                });
                _generatePassword();
              },
            ),
            CheckboxListTile(
              title: Text(texts.entries.symbols),
              value: _useSymbols,
              onChanged: (value) {
                setState(() {
                  _useSymbols = value ?? true;
                });
                _generatePassword();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(texts.global.cancel),
        ),
        if (widget.copyPswdOption)
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _generatedPassword));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(texts.entries.copy),
          )
        else
          ElevatedButton(
            onPressed: () => context.pop(_generatedPassword),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(texts.entries.usePassword),
          ),
      ],
    );
  }
}
