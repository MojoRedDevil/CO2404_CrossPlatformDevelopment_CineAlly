//import statements
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

//main function
void main() {
  runApp(const MovieApp());
}

// building home page 
class MovieApp extends StatelessWidget {
  const MovieApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cineally',
      theme: ThemeData(
        primaryColor: Colors.black,
        colorScheme: ColorScheme.dark(primary: Colors.black, secondary: darkRedColor),
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.poppinsTextTheme(
          const TextTheme(
            bodyText1: TextStyle(color: Colors.white),
            bodyText2: TextStyle(color: Colors.white),
            headline6: TextStyle(color: Colors.white),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

const Color darkRedColor = Color(0xFFB71C1C);

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    const MoviesWidget(),
    const TriviaPage(),
    const UserProfile(),
    const Search(),
    const ChildFriendlyMovies(),
  ];

  // Function to handle bottom navigation item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200, 
            child: Image.asset(
              'assets/CineallyLogo.png',
              height: 150, 
            ),
          ),
          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.home, color: darkRedColor),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.info, color: darkRedColor),
                label: 'Trivia',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.user, color: darkRedColor),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.search, color: darkRedColor),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.child_friendly, color: darkRedColor), 
                label: 'Child-Friendly',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).colorScheme.secondary,
            onTap: _onItemTapped,
          ),  
        ],
      ),
    );
  }
}


class MoviesWidget extends StatefulWidget {
  const MoviesWidget();

  @override
  _MoviesWidgetState createState() => _MoviesWidgetState();
}

class _MoviesWidgetState extends State<MoviesWidget> {
  List<Map<String, dynamic>> _mostWatchedMovies = [];
  List<Map<String, dynamic>> _highlyRatedMovies = [];

  @override
  void initState() {
    super.initState();
    _fetchMostWatchedMovies();
    _fetchHighlyRatedMovies();
  }

  // Function to fetch most watched movies
  Future<void> _fetchMostWatchedMovies() async {
    final apiKey = '8df68673d254cfd9e4be9008d4055884';
    final url = 'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey';
    final response = await http.get(Uri.parse(url));
    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _mostWatchedMovies = List<Map<String, dynamic>>.from(responseData['results']);
      });
    } else {
      throw Exception('Failed to load most watched movies');
    }
  }

  // Function to fetch highly rated movies
  Future<void> _fetchHighlyRatedMovies() async {
    final apiKey = '8df68673d254cfd9e4be9008d4055884';
    final url = 'https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey';
    final response = await http.get(Uri.parse(url));
    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _highlyRatedMovies = List<Map<String, dynamic>>.from(responseData['results']);
      });
    } else {
      throw Exception('Failed to load highly rated movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _mostWatchedMovies.isEmpty || _highlyRatedMovies.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Most Watched',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mostWatchedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _mostWatchedMovies[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsScreen(movie: movie),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              movie['title'],
                              style: TextStyle(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Highly Rated',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _highlyRatedMovies.length,
                itemBuilder: (context, index) {
                  final movie = _highlyRatedMovies[index];
                  return ListTile(
                    title: Text('${index + 1}. ${movie['title']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildStarRating(movie['vote_average']),
                            const SizedBox(width: 8),
                            Text(
                              '${movie['vote_average']} / 10',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Text(
                          movie['overview'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    leading: Image.network(
                      'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                      width: 100,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailsScreen(movie: movie),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ~/ 2 ? Icons.star : Icons.star_border,
          color: Colors.amber,
        ),
      ),
    );
  }
}

class MovieDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> movie;

  const MovieDetailsScreen({Key? key, required this.movie}) : super(key: key);

 // Widget to build star rating
  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < movie['vote_average'] ~/ 2 ? Icons.star : Icons.star_border,
          color: Colors.amber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie['title']),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  height: 150,
                  width: double.infinity,
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Overview:',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 8),
              Text(
                movie['overview'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16, width: 50),
              ElevatedButton(
                onPressed: () {
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(darkRedColor),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                child: Text('Add to Watchlist'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildRating(),
                  const SizedBox(width: 8),
                  Text(
                    '${movie['vote_average']}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'User Comments:',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 8),
              Text(
                'Add your own opinion here',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TriviaPage extends StatefulWidget {
  const TriviaPage();

  @override
  _TriviaPageState createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage> {
  Map<String, dynamic>? _currentQuestion;
  String? _selectedAnswer;
  bool _isSubmitted = false;
  int _totalScore = 0;

  final List<Map<String, dynamic>> triviaQuestions = [
    {
      'question': 'Which actor portrayed the character of Captain Jack Sparrow in the "Pirates of the Caribbean" series?',
      'answer': 'Johnny Depp',
      'incorrectAnswers': ['Orlando Bloom', 'Leonardo DiCaprio', 'Brad Pitt', 'Tom Cruise']
    },
    {
      'question': 'Who directed the movie "Inception"?',
      'answer': 'Christopher Nolan',
      'incorrectAnswers': ['Quentin Tarantino', 'Steven Spielberg', 'Martin Scorsese', 'James Cameron']
    },
    {
      'question': 'Which film won the Academy Award for Best Picture in 2019?',
      'answer': 'Parasite',
      'incorrectAnswers': ['1917', 'Joker', 'Once Upon a Time in Hollywood', 'The Irishman']
    },
    {
      'question': 'In the movie "The Shawshank Redemption," who played the character Andy Dufresne?',
      'answer': 'Tim Robbins',
      'incorrectAnswers': ['Morgan Freeman', 'Tom Hanks', 'Brad Pitt', 'Leonardo DiCaprio']
    },
    {
      'question': 'Who is the voice actor for the character Elsa in the animated movie "Frozen"?',
      'answer': 'Idina Menzel',
      'incorrectAnswers': ['Kristen Bell', 'Mandy Moore', 'Emma Stone', 'Anne Hathaway']
    },
    {
      'question': 'Which actor played the role of Neo in the movie "The Matrix"?',
      'answer': 'Keanu Reeves',
      'incorrectAnswers': ['Tom Cruise', 'Will Smith', 'Brad Pitt', 'Leonardo DiCaprio']
    },
    {
      'question': 'Who directed the movie "The Godfather"?',
      'answer': 'Francis Ford Coppola',
      'incorrectAnswers': ['Martin Scorsese', 'Quentin Tarantino', 'Steven Spielberg', 'Alfred Hitchcock']
    },
    {
      'question': 'What is the name of the character played by Heath Ledger in "The Dark Knight"?',
      'answer': 'Joker',
      'incorrectAnswers': ['Batman', 'Two-Face', 'Riddler', 'Penguin']
    },
    {
      'question': 'Which movie features a character named Forrest Gump?',
      'answer': 'Forrest Gump',
      'incorrectAnswers': ['Saving Private Ryan', 'The Green Mile', 'Cast Away', 'Apollo 13']
    },
    {
      'question': 'Who directed the movie "Titanic"?',
      'answer': 'James Cameron',
      'incorrectAnswers': ['Steven Spielberg', 'Christopher Nolan', 'Martin Scorsese', 'Peter Jackson']
    },
    {
      'question': 'Which film won the first Academy Award for Best Picture?',
      'answer': 'Wings',
      'incorrectAnswers': ['Gone with the Wind', 'Casablanca', 'Rebecca', 'Citizen Kane']
    },
    {
      'question': 'Who played the character of James Bond in the movie "Skyfall"?',
      'answer': 'Daniel Craig',
      'incorrectAnswers': ['Pierce Brosnan', 'Sean Connery', 'Roger Moore', 'Timothy Dalton']
    },
    {
      'question': 'Which actor won the Academy Award for Best Actor for his role in the movie "The Revenant"?',
      'answer': 'Leonardo DiCaprio',
      'incorrectAnswers': ['Tom Hanks', 'Brad Pitt', 'Joaquin Phoenix', 'Christian Bale']
    },
    {
      'question': 'What is the highest-grossing animated film of all time?',
      'answer': 'The Lion King (2019)',
      'incorrectAnswers': ['Frozen II', 'Toy Story 4', 'Finding Dory', 'Shrek 2']
    },
    {
      'question': 'Which movie features characters named Harry, Ron, and Hermione?',
      'answer': 'Harry Potter and the Philosopher\'s Stone',
      'incorrectAnswers': ['The Chronicles of Narnia: The Lion, the Witch and the Wardrobe', 'Percy Jackson & the Olympians: The Lightning Thief', 'Eragon', 'Twilight']
    },
  ];


  int _getRandomQuestionIndex() {
    return Random().nextInt(triviaQuestions.length);
  }

  List<String> _generateAnswers(Map<String, dynamic> question) {
    List<String> answers = [question['answer']];
    answers.addAll(question['incorrectAnswers']);
    answers.shuffle();
    return answers;
  }

  Widget _buildTriviaQuestion(Map<String, dynamic> question) {
    List<String> answers = _generateAnswers(question);
    return Column(
      children: [
        Text(
          question['question'],
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Column(
          children: _buildAnswerTiles(answers),
        ),
        ElevatedButton(
          onPressed: _isSubmitted ? _nextQuestion : _checkAnswer,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey;
                }
                return darkRedColor; 
              },
            ),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          child: Text(_isSubmitted ? 'Next' : 'Submit'),
        ),
      ],
    );
  }

  List<Widget> _buildAnswerTiles(List<String> answers) {
    return answers.map((answer) {
      Color tileColor = _isSubmitted ? (_selectedAnswer == _currentQuestion!['answer'] ? Colors.green : (_selectedAnswer == answer ? Colors.red : Colors.white)) : Colors.white;
      return RadioListTile<String>(
        title: Text(answer),
        value: answer,
        groupValue: _isSubmitted ? _currentQuestion!['answer'] : _selectedAnswer,
        onChanged: _isSubmitted ? null : (String? value) {
          setState(() {
            _selectedAnswer = value;
          });
        },
        activeColor: tileColor,
      );
    }).toList();
  }

  void _checkAnswer() {
    setState(() {
      _isSubmitted = true;
      if (_selectedAnswer == _currentQuestion!['answer']) {
        _totalScore += 10;
      } else {
        _totalScore -= 10;
      }
    });
  }

  int _questionCounter = 0; // Counter for tracking the number of questions answered
  int _playCount = 0; // Counter for tracking the number of times the quiz is played

  @override
  void initState() {
    super.initState();
    _loadPlayCount();
    _nextQuestion();
  }

  void _loadPlayCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _playCount = prefs.getInt('playCount') ?? 0;
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_questionCounter < 5) {
        _currentQuestion = triviaQuestions[_getRandomQuestionIndex()];
        _selectedAnswer = null;
        _isSubmitted = false;
        _questionCounter++;
      } else {
        _showScoreDialog();
        _incrementPlayCount();
      }
    });
  }

  // Increment the play count and save it to SharedPreferences
  void _incrementPlayCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int newPlayCount = (_playCount ?? 0) + 1;
    await prefs.setInt('playCount', newPlayCount);
    setState(() {
      _playCount = newPlayCount;
    });
  }

  void _saveScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalScore', _totalScore);
  }

  void _resetQuiz() {
    setState(() {
      _questionCounter = 0;
      _totalScore = 0;
    });
    _nextQuestion();
  }

  // Show the score 
  void _showScoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Score'),
          content: Text('Your total score is: $_totalScore'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _resetQuiz();
                Navigator.of(context).pop();
              },
              child: Text('Play Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _currentQuestion == null
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTriviaQuestion(_currentQuestion!),
                  Text(
                    'Total Score: $_totalScore',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitted ? _nextQuestion : _checkAnswer,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: Text(_isSubmitted ? 'Next' : 'Submit'),
                  ),
                ],
              ),
            ),
          );
  }
}

class UserProfile extends StatefulWidget {
  const UserProfile();

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String _name = '';
  String _bio = '';
  File? _image;
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0], // Use the first camera
        ResolutionPreset.medium,
      );

      // Initialize the camera controller
      await _controller!.initialize();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller != null) {
      try {
        final XFile file = await _controller!.takePicture();

        setState(() {
          _image = File(file.path);
        });
      } catch (e) {
        print('Error taking picture: $e');
      }
    }
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? '';
      _bio = prefs.getString('bio') ?? '';
      // Load image path from SharedPreferences or cloud storage, etc.
    });
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    _nameController.text = _name;
    _bioController.text = _bio;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _bioController,
                decoration: InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _getImageFromGallery,
                    child: Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _takePicture, // Removed duplicate declaration here
                    child: Text('Take Picture', style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _name = _nameController.text;
                  _bio = _bioController.text;
                });
                await _saveProfileData();
                Navigator.of(context).pop();
              },
              child: Text('Save', style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
            ),
          ],
          backgroundColor: Colors.grey[900],
        );
      },
    );
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _name);
    await prefs.setString('bio', _bio);
    // Save image path to SharedPreferences or cloud storage, etc.
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.5), // Translucent grey color
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 100,
              backgroundColor: Colors.black, // Fallback background color
              backgroundImage: _image != null
                ? FileImage(_image!) as ImageProvider<Object>?
                : AssetImage('assets/default_profile_image.png'),
            ),
            SizedBox(height: 20),
            Text(
              'Name: $_name',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            SizedBox(height: 10),
            Text(
              'Bio: $_bio',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showEditProfileDialog(context),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: Icon(Icons.settings),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _takePicture,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: Text('Take Picture', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

void runAppWithUserProfile() {
  runApp(MaterialApp(
    home: Scaffold(
      body: UserProfile(),
    ),
  ));
}

class Search extends StatefulWidget {
  const Search();

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String _searchQuery = '';
  List<dynamic> _searchResults = [];

  Future<void> _performSearch() async {
    final apiKey = '8df68673d254cfd9e4be9008d4055884';
    final searchUrl = 'https://api.themoviedb.org/3/search/person?api_key=$apiKey&query=$_searchQuery';

    final response = await http.get(Uri.parse(searchUrl));
    final responseData = json.decode(response.body)['results'];

    setState(() {
      _searchResults = responseData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _performSearch();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            child: Text('Search'),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  title: Text(result['name']),
                  subtitle: Text(result['known_for_department']),
                  leading: result['profile_path'] != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w200${result['profile_path']}',
                          width: 50,
                        )
                      : Icon(Icons.person),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActorProfileScreen(actorId: result['id']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ActorProfileScreen extends StatelessWidget {
  final int actorId;

  const ActorProfileScreen({Key? key, required this.actorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actor Profile'),
      ),
      body: FutureBuilder(
        future: _fetchActorProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final actorProfile = snapshot.data as Map<String, dynamic>;
            return Column(
              children: [
                // Display actor picture
                actorProfile['profile_path'] != null
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w200${actorProfile['profile_path']}',
                        width: 200,
                      )
                    : Icon(Icons.person),
                SizedBox(height: 16),
                // Display list of movies
                Expanded(
                  child: ListView.builder(
                    itemCount: actorProfile['movies'].length,
                    itemBuilder: (context, index) {
                      final movie = actorProfile['movies'][index];
                      return ListTile(
                        title: Text(movie['title']),
                        subtitle: Text(movie['character']),
                        leading: movie['poster_path'] != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                                width: 50,
                              )
                            : Icon(Icons.movie),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchActorProfile() async {
    final apiKey = '8df68673d254cfd9e4be9008d4055884';
    final actorUrl = 'https://api.themoviedb.org/3/person/$actorId?api_key=$apiKey&append_to_response=movie_credits';

    final response = await http.get(Uri.parse(actorUrl));
    final responseData = json.decode(response.body);
    final movies = responseData['movie_credits']['cast'];

    return {
      'profile_path': responseData['profile_path'],
      'movies': movies,
    };
  }
}

class ChildFriendlyMovies extends StatefulWidget {
  const ChildFriendlyMovies();

  @override
  _ChildFriendlyMoviesState createState() => _ChildFriendlyMoviesState();
}

class _ChildFriendlyMoviesState extends State<ChildFriendlyMovies> {
  List<Map<String, dynamic>> _childFriendlyMovies = [];

  @override
  void initState() {
    super.initState();
    _fetchChildFriendlyMovies();
  }

  Future<void> _fetchChildFriendlyMovies() async {
    final apiKey = '8df68673d254cfd9e4be9008d4055884';
    final url = 'https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&certification_country=US&certification.lte=G&sort_by=popularity.desc';
    final response = await http.get(Uri.parse(url));
    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _childFriendlyMovies = List<Map<String, dynamic>>.from(responseData['results']);
      });
    } else {
      throw Exception('Failed to load child-friendly movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _childFriendlyMovies.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _childFriendlyMovies.length,
            itemBuilder: (context, index) {
              final movie = _childFriendlyMovies[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailsScreen(movie: movie),
                      ),
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}st', // Ranking
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 120,
                        height: 180,
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w300${movie['poster_path']}', // Increased poster size
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie['title'],
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              movie['overview'],
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}