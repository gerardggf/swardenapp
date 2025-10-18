import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swardenapp/app/core/constants/colors.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';
import 'package:swardenapp/app/core/extensions/text_theme_extension.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';
import 'package:swardenapp/app/presentation/global/dialogs/dialogs.dart';

class InfoCardWidget extends StatefulWidget {
  const InfoCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.isPassword = false,
    this.allowCopy = true,
    this.iconColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool isPassword;
  final bool allowCopy;
  final Color? iconColor;

  @override
  State<InfoCardWidget> createState() => _InfoCardWidgetState();
}

class _InfoCardWidgetState extends State<InfoCardWidget> {
  bool _obscurePassword = true;

  Future<void> _copyToClipboard(
    BuildContext context,
    String text,
    String label,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    SwardenDialogs.snackBar(
      context,
      '$label ${texts.entries.copiedToClipboard}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (widget.iconColor ?? AppColors.primary).withAlpha(24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor ?? AppColors.primary,
                  size: 20,
                ),
              ),
              12.w,
              Expanded(
                child: Text(
                  widget.title,
                  style: context.themeTS?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              if (widget.allowCopy && widget.value.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.copy_outlined,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () =>
                      _copyToClipboard(context, widget.value, widget.title),
                  tooltip: texts.entries.copy,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              if (widget.isPassword) ...[
                4.w,
                IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  tooltip: _obscurePassword
                      ? texts.entries.show
                      : texts.entries.hide,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ],
          ),
          16.h,
          if (widget.isPassword && _obscurePassword)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.value.isEmpty
                    ? texts.entries.notSpecified
                    : '••••••••••••',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.value.isEmpty
                      ? Colors.grey.shade500
                      : Colors.grey.shade700,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SelectableText(
                widget.value.isEmpty
                    ? texts.entries.notSpecified
                    : widget.value,
                style: TextStyle(
                  fontSize: 16,
                  color: widget.value.isEmpty
                      ? Colors.grey.shade500
                      : Colors.black87,
                  fontFamily: widget.isPassword ? 'monospace' : null,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
