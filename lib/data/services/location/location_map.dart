import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationMap extends StatelessWidget {
  final String address;
  final double latitude;
  final double longitude;

  const LocationMap({
    super.key,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  void openGoogleMaps() async {
    String encodedAddress = Uri.encodeComponent(address);
    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$encodedAddress";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      print('URL can be launched');
      await launchUrl(Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication);
    } else {
      print('URL cannot be launched');
      throw "Could not open Google Maps";
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = dotenv.env['GOOGLE_MAP_API_KEY'];
    String mapUrl =
        "https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=15&size=600x300&maptype=roadmap&markers=color:red%7C$latitude,$longitude&key=$api";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: openGoogleMaps,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              mapUrl,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                print(error);
                return Center(child: Text("Map could not be loaded"));
              },
            ),
          ),
        ),
      ],
    );
  }
}
