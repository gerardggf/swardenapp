import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swardenapp/app/core/generated/translations.g.dart';

/// Diàleg per seleccionar l'idioma de l'aplicació
Future<AppLocale?> showLanguageDialog(BuildContext context) async {
  ListTile buildLanguageTile(String text, AppLocale locale) => ListTile(
    leading: const Icon(Icons.language),
    title: Text(text),
    onTap: () {
      context.pop(locale);
    },
  );
  return await showDialog<AppLocale?>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(texts.profile.changeLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildLanguageTile('English', AppLocale.en),
          buildLanguageTile('Català', AppLocale.ca),
          buildLanguageTile('Español', AppLocale.es),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(texts.global.cancel),
        ),
      ],
    ),
  );
}
