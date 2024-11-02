import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:abbasweatherapp/Birdsdetailpage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';

class FireBirdsImagePage extends StatefulWidget {
  const FireBirdsImagePage({Key? key}) : super(key: key);

  @override
  State<FireBirdsImagePage> createState() => _FireBirdsImagePageState();
}

class _FireBirdsImagePageState extends State<FireBirdsImagePage> {
  List<Map<String, dynamic>> birds = [];
  List<Map<String, dynamic>> filteredBirds = [];
  AudioPlayer? _audioPlayer;
  bool isPlaying = false;
  String? currentSoundUrl;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadBirdData();
  }

  Future<void> _loadBirdData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? birdDataString = prefs.getString('birdData');

    if (birdDataString != null) {
      List<dynamic> birdDataList = json.decode(birdDataString);
      setState(() {
        birds =
            birdDataList.map((bird) => bird as Map<String, dynamic>).toList();
        filteredBirds = birds;
      });
    } else {
      print('No bird data available locally.');
    }
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      filteredBirds = birds
          .where((bird) => bird['name']
              .toString()
              .toLowerCase()
              .contains(newQuery.toLowerCase()))
          .toList();
    });
  }

  Future<void> toggleSound(String soundData) async {
    try {
      if (isPlaying && currentSoundUrl == soundData) {
        await _audioPlayer?.pause();
        setState(() {
          isPlaying = false;
        });
      } else {
        if (currentSoundUrl != soundData) {
          await _audioPlayer?.stop();
          if (kIsWeb) {
            String base64Sound = base64Encode(base64Decode(soundData));
            String dataUri = 'data:audio/wav;base64,$base64Sound';
            await _audioPlayer?.setUrl(dataUri);
          } else {
            await _audioPlayer?.setUrl(soundData);
          }
          await _audioPlayer?.play();
        } else {
          await _audioPlayer?.play();
        }
        setState(() {
          isPlaying = true;
          currentSoundUrl = soundData;
        });
      }
    } catch (e) {
      print('Error toggling sound: $e');
    }
  }

  void _showBirdDetails(String name, String description, String image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BirdsDetailsPage(
          name: name,
          description: description,
          image: image,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 7, 87, 153), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            'Bird List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 7, 87, 153), Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  onChanged: updateSearchQuery,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search birds by name',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            Expanded(
              child: filteredBirds.isEmpty
                  ? Center(child: Text('No birds found.'))
                  : ListView.builder(
                      itemCount: filteredBirds.length,
                      itemBuilder: (context, index) {
                        final bird = filteredBirds[index];
                        final name = bird['name'] ?? 'No name';
                        final image = bird['image'];
                        final description =
                            bird['description'] ?? 'No description';
                        final soundData = bird['sound'] ?? '';

                        return Card(
                          margin: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 7, 87, 153),
                                  Colors.black
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            if (soundData.isNotEmpty) {
                                              toggleSound(soundData);
                                            } else {
                                              print('No sound data available');
                                            }
                                          },
                                          icon: Icon(
                                            isPlaying &&
                                                    currentSoundUrl == soundData
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                          ),
                                          label: Text(
                                            isPlaying &&
                                                    currentSoundUrl == soundData
                                                ? 'Pause Sound'
                                                : 'Play Sound',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        _showBirdDetails(
                                            name, description, image);
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        child: AspectRatio(
                                          aspectRatio: 4 / 3,
                                          child: _displayImage(image),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayImage(dynamic image) {
    if (kIsWeb && image is String) {
      try {
        Uint8List bytes = base64Decode(image);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (e) {
        return Icon(Icons.image, size: 50, color: Colors.grey);
      }
    } else if (image is String) {
      return Image.file(
        File(image),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.image, size: 50, color: Colors.grey),
      );
    } else {
      return Icon(Icons.image, size: 50, color: Colors.grey);
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }
}
