import 'package:url_launcher/url_launcher.dart';

/// Funció global per interactuar amb URLs externes
Future<void> launchCustomUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}
