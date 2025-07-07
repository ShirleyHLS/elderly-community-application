import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openGoogleMaps(String address) async {
    String encodedAddress = Uri.encodeComponent(address);
    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$encodedAddress";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      print('😁😁😁 URL can be launched');
      await launchUrl(Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication);
    } else {
      print('😢😢😢 URL cannot be launched');
      throw "Could not open Google Maps";
    }
  }
}
