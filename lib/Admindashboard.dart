import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Animal fields
  final _animalNameController = TextEditingController();
  final _animalDescriptionController = TextEditingController();
  final _deleteAnimalController = TextEditingController();
  File? _selectedAnimalImage;
  Uint8List? _selectedAnimalImageBytes;
  File? _selectedAnimalSound;
  Uint8List? _selectedAnimalSoundBytes;
  String? _selectedAnimalSoundName;

  // Bird fields
  final _birdNameController = TextEditingController();
  final _birdDescriptionController = TextEditingController();
  final _deleteBirdController = TextEditingController();
  File? _selectedBirdImage;
  Uint8List? _selectedBirdImageBytes;
  File? _selectedBirdSound;
  Uint8List? _selectedBirdSoundBytes;
  String? _selectedBirdSoundName;

  // Feedback fields
  final _feedbackController = TextEditingController();
  List<String> feedbackList = [];

  List<Map<String, dynamic>> animalList = [];
  List<Map<String, dynamic>> birdList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadFeedbackData(); // Load feedback data when the app starts
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? animalData = prefs.getString('animalData');
      final String? birdData = prefs.getString('birdData');

      if (mounted) {
        setState(() {
          if (animalData != null) {
            animalList = List<Map<String, dynamic>>.from(json
                .decode(animalData)
                .map((item) => Map<String, dynamic>.from(item)));
          }
          if (birdData != null) {
            birdList = List<Map<String, dynamic>>.from(json
                .decode(birdData)
                .map((item) => Map<String, dynamic>.from(item)));
          }
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  // Load feedback data from SharedPreferences
  Future<void> _loadFeedbackData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      feedbackList = prefs.getStringList('feedbackList') ?? [];
    });
  }

  // Save feedback data to SharedPreferences
  Future<void> _saveFeedbackData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('feedbackList', feedbackList);
  }

  // Method to add feedback and update the list
  Future<void> _addFeedback() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      _showErrorDialog("Please enter feedback.");
      return;
    }

    setState(() {
      feedbackList.add(feedback); // Add the feedback to the list
    });

    await _saveFeedbackData(); // Save the feedback to SharedPreferences
    _feedbackController.clear();
    print("Feedback added successfully.");
  }

  Future<void> _addAnimal() async {
    try {
      FocusScope.of(context).unfocus();
      final name = _animalNameController.text.trim();
      final description = _animalDescriptionController.text.trim();

      if (name.isEmpty) {
        _showErrorDialog("Please enter an animal name.");
        return;
      }
      if (description.isEmpty) {
        _showErrorDialog("Please enter an animal description.");
        return;
      }
      if (_selectedAnimalImage == null && _selectedAnimalImageBytes == null) {
        _showErrorDialog("Please select an animal image.");
        return;
      }
      if (_selectedAnimalSound == null && _selectedAnimalSoundBytes == null) {
        _showErrorDialog("Please select an animal sound.");
        return;
      }

      String imageData;
      String soundData;
      if (kIsWeb) {
        if (_selectedAnimalImageBytes == null ||
            _selectedAnimalSoundBytes == null) {
          _showErrorDialog("Unable to process the selected image or sound.");
          return;
        }
        imageData = base64Encode(_selectedAnimalImageBytes!);
        soundData = base64Encode(_selectedAnimalSoundBytes!);
      } else {
        if (_selectedAnimalImage == null || _selectedAnimalSound == null) {
          _showErrorDialog("Unable to process the selected image or sound.");
          return;
        }
        imageData = _selectedAnimalImage!.path;
        soundData = _selectedAnimalSound!.path;
      }

      final newAnimal = {
        'name': name,
        'image': imageData,
        'description': description,
        'sound': soundData,
      };

      setState(() {
        animalList.add(newAnimal);
      });

      await _saveAnimalData();

      _animalNameController.clear();
      _animalDescriptionController.clear();
      _selectedAnimalImage = null;
      _selectedAnimalImageBytes = null;
      _selectedAnimalSound = null;
      _selectedAnimalSoundBytes = null;

      print("Animal added successfully.");
    } catch (e) {
      print('Error adding animal: $e');
      _showErrorDialog("An error occurred while adding the animal: $e");
    }
  }

  Future<void> _addBird() async {
    try {
      FocusScope.of(context).unfocus();
      final name = _birdNameController.text.trim();
      final description = _birdDescriptionController.text.trim();

      if (name.isEmpty) {
        _showErrorDialog("Please enter a bird name.");
        return;
      }
      if (description.isEmpty) {
        _showErrorDialog("Please enter a bird description.");
        return;
      }
      if (_selectedBirdImage == null && _selectedBirdImageBytes == null) {
        _showErrorDialog("Please select a bird image.");
        return;
      }
      if (_selectedBirdSound == null && _selectedBirdSoundBytes == null) {
        _showErrorDialog("Please select a bird sound.");
        return;
      }

      String imageData;
      String soundData;
      if (kIsWeb) {
        if (_selectedBirdImageBytes == null ||
            _selectedBirdSoundBytes == null) {
          _showErrorDialog("Unable to process the selected image or sound.");
          return;
        }
        imageData = base64Encode(_selectedBirdImageBytes!);
        soundData = base64Encode(_selectedBirdSoundBytes!);
      } else {
        if (_selectedBirdImage == null || _selectedBirdSound == null) {
          _showErrorDialog("Unable to process the selected image or sound.");
          return;
        }
        imageData = _selectedBirdImage!.path;
        soundData = _selectedBirdSound!.path;
      }

      final newBird = {
        'name': name,
        'image': imageData,
        'description': description,
        'sound': soundData,
      };

      setState(() {
        birdList.add(newBird);
      });

      await _saveBirdData();

      _birdNameController.clear();
      _birdDescriptionController.clear();
      _selectedBirdImage = null;
      _selectedBirdImageBytes = null;
      _selectedBirdSound = null;
      _selectedBirdSoundBytes = null;

      print("Bird added successfully.");
    } catch (e) {
      print('Error adding bird: $e');
      _showErrorDialog("An error occurred while adding the bird: $e");
    }
  }

  Future<void> _deleteAnimal() async {
    final name = _deleteAnimalController.text.trim();
    if (name.isEmpty) {
      _showErrorDialog("Please enter the animal name to delete.");
      return;
    }

    setState(() {
      animalList.removeWhere((animal) => animal['name'] == name);
    });

    await _saveAnimalData();
    _deleteAnimalController.clear();
    print("Animal deleted successfully.");
  }

  Future<void> _deleteBird() async {
    final name = _deleteBirdController.text.trim();
    if (name.isEmpty) {
      _showErrorDialog("Please enter the bird name to delete.");
      return;
    }

    setState(() {
      birdList.removeWhere((bird) => bird['name'] == name);
    });

    await _saveBirdData();
    _deleteBirdController.clear();
    print("Bird deleted successfully.");
  }

  Future<void> _pickImage(bool isAnimal) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          if (isAnimal) {
            _selectedAnimalImageBytes = bytes;
          } else {
            _selectedBirdImageBytes = bytes;
          }
        });
      } else {
        setState(() {
          if (isAnimal) {
            _selectedAnimalImage = File(pickedFile.path);
          } else {
            _selectedBirdImage = File(pickedFile.path);
          }
        });
      }
    }
  }

  Future<void> _pickSound(bool isAnimal) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        final name = result.files.single.name;

        if (bytes != null) {
          setState(() {
            if (isAnimal) {
              _selectedAnimalSoundBytes = bytes;
              _selectedAnimalSoundName = name;
            } else {
              _selectedBirdSoundBytes = bytes;
              _selectedBirdSoundName = name;
            }
          });
        }
      } else {
        final filePath = result.files.single.path;
        final name = result.files.single.name;

        if (filePath != null) {
          setState(() {
            if (isAnimal) {
              _selectedAnimalSound = File(filePath);
              _selectedAnimalSoundName = name;
            } else {
              _selectedBirdSound = File(filePath);
              _selectedBirdSoundName = name;
            }
          });
        }
      }
    } else {
      print('No sound file selected.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAnimalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String animalDataString = json.encode(animalList);
    await prefs.setString('animalData', animalDataString);
  }

  Future<void> _saveBirdData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String birdDataString = json.encode(birdList);
    await prefs.setString('birdData', birdDataString);
  }

  @override
  void dispose() {
    _animalNameController.dispose();
    _animalDescriptionController.dispose();
    _birdNameController.dispose();
    _birdDescriptionController.dispose();
    _deleteAnimalController.dispose();
    _deleteBirdController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 23, 103, 169), Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 23, 103, 169), Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                // Animal Section
                _buildSectionTitle('Add Animal'),
                _buildTextField(_animalNameController, 'Animal Name'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _pickImage(true),
                  child: Text(
                    'Select Animal Image',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                _selectedAnimalImageBytes != null ||
                        _selectedAnimalImage != null
                    ? _displayImage(true)
                    : Container(),
                SizedBox(height: 16),
                _buildTextField(
                    _animalDescriptionController, 'Animal Description'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _pickSound(true),
                  child: Text('Select Animal Sound'),
                ),
                _selectedAnimalSoundName != null
                    ? Text('Sound Selected: $_selectedAnimalSoundName')
                    : Container(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addAnimal,
                  child: Text('Add Animal'),
                ),
                _buildTextField(
                    _deleteAnimalController, 'Animal Name to Delete'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _deleteAnimal,
                  child: Text('Delete Animal'),
                ),
                Divider(height: 40, thickness: 2),
                // Bird Section
                _buildSectionTitle('Add Bird'),
                _buildTextField(_birdNameController, 'Bird Name'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _pickImage(false),
                  child: Text('Select Bird Image'),
                ),
                _selectedBirdImageBytes != null || _selectedBirdImage != null
                    ? _displayImage(false)
                    : Container(),
                SizedBox(height: 16),
                _buildTextField(_birdDescriptionController, 'Bird Description'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _pickSound(false),
                  child: Text('Select Bird Sound'),
                ),
                _selectedBirdSoundName != null
                    ? Text('Sound Selected: $_selectedBirdSoundName')
                    : Container(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addBird,
                  child: Text('Add Bird'),
                ),
                _buildTextField(_deleteBirdController, 'Bird Name to Delete'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _deleteBird,
                  child: Text('Delete Bird'),
                ),
                Divider(height: 40, thickness: 2),
                // Feedback Section
                _buildSectionTitle('User Feedback'),

                SizedBox(height: 20),
                ...feedbackList.map((feedback) => ListTile(
                      title: Text(
                        feedback,
                        style: TextStyle(color: Colors.white),
                      ),
                      tileColor: Colors.white,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _displayImage(bool isAnimal) {
    if (kIsWeb) {
      final bytes =
          isAnimal ? _selectedAnimalImageBytes : _selectedBirdImageBytes;
      return Image.memory(bytes!, height: 150);
    } else {
      final file = isAnimal ? _selectedAnimalImage : _selectedBirdImage;
      return Image.file(file!, height: 150);
    }
  }
}
