import 'dart:convert'; // For handling JSON data
import 'dart:typed_data'; // For handling byte data
import 'dart:io'; // For non-web platforms
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // For cross-platform audio support
import 'package:shared_preferences/shared_preferences.dart';
import 'Animaldetailspage.dart'; // Import your animal details page

class FireAnimalsImagePage extends StatefulWidget {
  const FireAnimalsImagePage({
    Key? key,
  }) : super(key: key);

  @override
  State<FireAnimalsImagePage> createState() => _FireAnimalsImagePageState();
}

class _FireAnimalsImagePageState extends State<FireAnimalsImagePage> {
  List<Map<String, dynamic>> animals = [];
  List<Map<String, dynamic>> filteredAnimals = [];
  AudioPlayer? _audioPlayer;
  bool isPlaying = false;
  String? currentSoundUrl;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadAnimalData(); // Load animal data from local storage when the app starts
    _searchController.addListener(_filterAnimals);
  }

  // Load animal data from local storage
  Future<void> _loadAnimalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? animalDataString = prefs.getString('animalData');

    if (animalDataString != null) {
      List<dynamic> animalDataList = json.decode(animalDataString);
      setState(() {
        animals = animalDataList
            .map((animal) => animal as Map<String, dynamic>)
            .toList();
        filteredAnimals = animals; // Initially show all animals
      });
    } else {
      print('No animal data available locally.');
    }
  }

  void _filterAnimals() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredAnimals = animals
          .where((animal) =>
              (animal['name'] ?? '').toString().toLowerCase().contains(query))
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
            // Handle base64 sound data for web
            String base64Sound = base64Encode(base64Decode(soundData));
            String dataUri = 'data:audio/wav;base64,$base64Sound';
            await _audioPlayer?.setUrl(dataUri);
          } else {
            // Use file path for non-web platforms
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

  // Navigate to the AnimalDetailsPage with the animal's details
  void _showAnimalDetails(String name, String description, String image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalDetails(
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
      appBar: AppBar(
        title: Text(
          'Animal List',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 7, 87, 153), Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
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
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search Animals',
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredAnimals.isEmpty
                  ? Center(child: Text('No animals found.'))
                  : ListView.builder(
                      itemCount: filteredAnimals.length,
                      itemBuilder: (context, index) {
                        final animal = filteredAnimals[index];
                        final name = animal['name'] ?? 'No name';
                        final image = animal['image'];
                        final description =
                            animal['description'] ?? 'No description';
                        final soundData = animal['sound'] ?? '';

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
                                        _showAnimalDetails(
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
    _searchController.dispose();
    super.dispose();
  }
}
