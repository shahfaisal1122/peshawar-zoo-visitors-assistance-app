import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:convert'; // For base64 decoding

class BirdsDetailsPage extends StatelessWidget {
  final String name;
  final String description;
  final String image; // This should be the local file path if offline, or a base64 string if on web

  const BirdsDetailsPage({
    Key? key,
    required this.name,
    required this.description,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 34, 86, 159),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 34, 86, 159),
              Color.fromARGB(255, 58, 61, 77),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display image from local file or base64 encoded string
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: _displayImage(image),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                description.isNotEmpty
                    ? description
                    : 'No description available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Display image based on platform and format
  Widget _displayImage(String image) {
    if (kIsWeb) {
      // For web, assume the image is a base64 string
      try {
        Uint8List bytes = base64Decode(image);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (e) {
        return Icon(Icons.image, size: 50, color: Colors.grey);
      }
    } else {
      // For non-web platforms, use the file path
      if (File(image).existsSync()) {
        return Image.file(
          File(image),
          fit: BoxFit.cover,
        );
      } else {
        return Icon(Icons.image, size: 50, color: Colors.grey);
      }
    }
  }
}
