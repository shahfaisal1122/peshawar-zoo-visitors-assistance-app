import 'dart:async';
import 'dart:convert'; // For handling JSON data
import 'package:abbasweatherapp/scan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:shared_preferences/shared_preferences.dart'; // For saving data locally
import 'package:intl/intl.dart'; // For formatting the selected date

import 'package:abbasweatherapp/Fireimagepage.dart';
import 'package:abbasweatherapp/firebirdimagepage.dart';
import 'package:abbasweatherapp/camerapage.dart';
import 'package:abbasweatherapp/loginPage.dart';
import 'package:abbasweatherapp/Admindashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 2),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      child: Image.asset(
        'lib/assets/zoo.jpg',
        fit: BoxFit.fill,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    FireBirdsImagePage(),
    ScanPage(),
    FireAnimalsImagePage(),
  ];
  final TextEditingController _feedbackController = TextEditingController();

  // Weather information variables
  Map<String, dynamic>? _weatherData;
  String _location = 'Peshawar';
  bool _loading = true;
  String _error = '';

  // Calendar variables
  DateTime? _selectedDate;
  String _formattedDate = 'Select Date'; // Default text for date selection

  @override
  void initState() {
    super.initState();
    fetchWeather(_location); // Fetch weather data when the app starts
    _loadSavedDate(); // Load saved date from SharedPreferences
  }

  // Load the saved date from SharedPreferences
  Future<void> _loadSavedDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedDate = prefs.getString('selectedDate');
    if (savedDate != null) {
      setState(() {
        _selectedDate = DateTime.parse(savedDate);
        _formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  // Save the selected date to SharedPreferences
  Future<void> _saveSelectedDate(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDate', date.toIso8601String());
  }

  // Fetch weather data from OpenWeatherMap API
  Future<void> fetchWeather(String location) async {
    final apiKey =
        '8b66541a8c2fa4a8c4088f1a527b9e04'; // Replace with your API key
    final response = await http.get(
      Uri.parse(
          'http://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _weatherData = json.decode(response.body);
        _loading = false;
        _error = '';
      });
    } else {
      setState(() {
        _loading = false;
        _error = 'Failed to load weather data';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    // Ensure the initial date is on or after the first date
    final DateTime initialDate =
        _selectedDate != null && _selectedDate!.isAfter(now)
            ? _selectedDate!
            : now;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
        _saveSelectedDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 34, 86, 159),
                Color.fromARGB(255, 58, 61, 77)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(height: 100),
              ListTile(
                leading: Icon(Icons.cloud, color: Colors.white),
                title: _loading
                    ? CircularProgressIndicator()
                    : Text(
                        _weatherData != null
                            ? 'Weather: ${_weatherData!['weather'][0]['description']}'
                            : 'Weather: $_error',
                        style: TextStyle(color: Colors.white),
                      ),
                subtitle: _weatherData != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Temperature: ${_weatherData!['main']['temp']}°C',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Humidity: ${_weatherData!['main']['humidity']}%',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            'Wind: ${_weatherData!['wind']['speed']} m/s',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    : Text(''),
                trailing: IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () async {
                    final result = await showSearch(
                      context: context,
                      delegate: LocationSearch(fetchWeather),
                    );
                    if (result != null) {
                      setState(() {
                        _location = result;
                        _loading = true;
                        fetchWeather(_location);
                      });
                    }
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.date_range, color: Colors.white),
                title: Text('Choose a Visit Date',
                    style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  _formattedDate,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _selectDate(context); // Open the date picker when tapped
                },
              ),
              ListTile(
                leading: Icon(Icons.dashboard_sharp, color: Colors.white),
                title: Text('Admin Dashboard',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.feed_outlined, color: Colors.white),
                title: Text('Submit Feedback',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  _showFeedbackDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.map, color: Colors.white),
                title: Text('Zoo Map', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ZooMapPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.white),
                title: Text('Take a Picture',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Zoo App',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 34, 86, 159),
                Color.fromARGB(255, 30, 55, 72)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 16, 91, 152),
              const Color.fromARGB(255, 22, 108, 179),
              const Color.fromARGB(255, 16, 82, 137)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          items: [
            BottomNavigationBarItem(
              backgroundColor: const Color.fromARGB(255, 35, 63, 86),
              icon: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.pets_rounded, color: Colors.black),
              ),
              label: 'Birds',
            ),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.qr_code, color: Colors.black),
              ),
              label: 'Scanner',
            ),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.image, color: Colors.black),
              ),
              label: 'Animals',
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Submit Feedback'),
          content: TextField(
            controller: _feedbackController,
            decoration: InputDecoration(hintText: 'Enter your feedback'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _submitFeedback();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitFeedback() async {
    String feedback = _feedbackController.text.trim();
    if (feedback.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> feedbackList = prefs.getStringList('feedbackList') ?? [];
      feedbackList.add(feedback);
      await prefs.setStringList('feedbackList', feedbackList);
      _feedbackController.clear();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback submitted successfully')),
      );
    }
  }
}

// New page to display the Zoo Map
// Updated ZooMapPage to include a search bar and display multiple images.
class ZooMapPage extends StatefulWidget {
  @override
  _ZooMapPageState createState() => _ZooMapPageState();
}

class _ZooMapPageState extends State<ZooMapPage> {
  final List<Map<String, String>> _zooImages = [
    {'name': 'Zoo Map', 'path': 'lib/assets/zoo_map.jpg'},
    {'name': 'children Park', 'path': 'lib/assets/map2.jpg'},
    {'name': 'Deer', 'path': 'lib/assets/map3.jpg'},
    {'name': 'Bighorn sheep', 'path': 'lib/assets/map4.jpg'},
    {'name': 'Lion', 'path': 'lib/assets/map5.jpg'},
    {'name': 'Birds', 'path': 'lib/assets/map6 .jpg'},
    {'name': 'cheetah', 'path': 'lib/assets/map7.jpg'},
    {'name': 'Bears', 'path': 'lib/assets/map8.jpg'},
  ];

  List<Map<String, String>> _filteredImages = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredImages = _zooImages; // Initially show all images
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _filteredImages = _zooImages
          .where((image) =>
              image['name']!.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "GUIDE MAP OF THE ZOO",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 34, 86, 159),
                Color.fromARGB(255, 30, 55, 72),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 34, 86, 159),
              Color.fromARGB(255, 30, 55, 72),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for an image...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: _updateSearchQuery,
              ),
            ),
            Expanded(
              child: _filteredImages.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: Column(
                              children: [
                                Text(
                                  _filteredImages[index]['name']!,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                InteractiveViewer(
                                  panEnabled: true,
                                  boundaryMargin: EdgeInsets.all(80),
                                  minScale: 0.5,
                                  maxScale: 4.0,
                                  child: Image.asset(
                                    _filteredImages[index]['path']!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'No images found',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationSearch extends SearchDelegate<String> {
  final Function fetchWeather;

  LocationSearch(this.fetchWeather);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    fetchWeather(query);
    close(context, query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListTile(
      title: Text(query.isEmpty ? 'Enter a location' : query),
    );
  }
}
