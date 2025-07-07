import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class JWTService {
  static Future<String> getAccessToken() async {
    final serviceAccount = jsonDecode(await rootBundle.loadString("assets/service-account.json"));

    final String privateKey = (serviceAccount["private_key"] as String)
        .replaceAll(r"\n", "\n"); // Ensure correct private key format

    final String clientEmail = serviceAccount["client_email"];
    final String tokenUri = serviceAccount["token_uri"];

    final now = DateTime.now();
    final expiry = now.add(Duration(hours: 1));

    final jwt = JWT(
      {
        "iss": clientEmail,
        "scope": "https://www.googleapis.com/auth/firebase.messaging",
        "aud": tokenUri,
        "iat": now.millisecondsSinceEpoch ~/ 1000,
        "exp": expiry.millisecondsSinceEpoch ~/ 1000,
      },
    );

    final String signedJwt = jwt.sign(RSAPrivateKey(privateKey), algorithm: JWTAlgorithm.RS256);

    // Exchange JWT for an access token
    final response = await http.post(
      Uri.parse(tokenUri),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "assertion": signedJwt,
      }),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return responseData["access_token"];
    } else {
      throw Exception("Error getting access token: ${response.body}");
    }
  }
}
