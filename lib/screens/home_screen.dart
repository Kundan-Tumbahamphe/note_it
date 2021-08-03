import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:noteit/changeNotifiers/theme_change_notifier.dart';
import 'package:noteit/components/note_card.dart';
import 'package:noteit/configs/configs.dart';
import 'package:noteit/models/models.dart';
import 'package:noteit/screens/screens.dart';
import 'package:noteit/services/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

//test
class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _searchController = TextEditingController();
  stt.SpeechToText _speechToText;
  bool _isListening = false;

  List<Note> _allNotes = [];
  List<Note> _searchedNotes = [];
  bool _isLoading = false;
  bool _errorOccured = false;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _searchController.addListener(_onSearchChanged);
    _setNotes();
  }

  Future<void> _setNotes() async {
    try {
      setState(() => _isLoading = true);

      final databaseService =
          Provider.of<DatabaseService>(context, listen: false);
      List<Note> notes = await databaseService.notes();
      setState(() {
        _allNotes = notes;
        _searchedNotes = notes;
      });
    } on PlatformException {
      setState(() => _errorOccured = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    List<Note> result = [];

    if (_searchController.text != '') {
      for (Note note in _allNotes) {
        if (note.title
            .trim()
            .toLowerCase()
            .contains(_searchController.text.trim().toLowerCase())) {
          result.add(note);
        }
      }
    } else {
      result = List.from(_allNotes);
    }

    setState(() => _searchedNotes = result);
  }

  Future<void> _listenSpeech() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();

      if (available) {
        setState(() => _isListening = true);

        _speechToText.listen(
          listenFor: const Duration(seconds: 30),
          onResult: (value) => setState(() {
            final recognizedWord = value.recognizedWords;

            _searchController.value = TextEditingValue(
              text: recognizedWord,
              selection: TextSelection.fromPosition(
                TextPosition(offset: recognizedWord.length),
              ),
            );
          }),
        );
      } else {
        final snackBar = SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Row(
            children: <Widget>[
              const Icon(Icons.error_outline, size: 22.0),
              const SizedBox(width: 5.0),
              Text('speech recognization service not avialable'),
            ],
          ),
        );

        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final themeNotifier =
        Provider.of<ThemeChangeNotifier>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: const Icon(
          MdiIcons.accountCircleOutline,
          size: 28.0,
        ),
        elevation: 0.0,
        title: TweenAnimationBuilder(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              user.name ?? '',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ),
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          builder: (_, value, child) {
            return Opacity(
              opacity: value,
              child: Padding(
                padding: EdgeInsets.only(top: value * 20),
                child: child,
              ),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Theme.of(context).brightness == Brightness.dark
                ? const Icon(Icons.brightness_7)
                : const Icon(Icons.brightness_4),
            onPressed: () {
              themeNotifier.switchTheme();
            },
          ),
          IconButton(
            icon: const Icon(MdiIcons.logout),
            onPressed: () => authService.logOut(),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Theme(
                data: Theme.of(context).copyWith(
                  primaryColor: Colors.black,
                  accentColor: Colors.white,
                ),
                child: TextField(
                  controller: _searchController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        width: 0.3,
                        color: Constants.mainDesignColor,
                      ),
                    ),
                    hintText: 'Search your notes...',
                    prefixIcon: const Icon(Icons.search, size: 30.0),
                    suffixIcon: AvatarGlow(
                      glowColor: Constants.mainDesignColor,
                      animate: _isListening,
                      endRadius: 20.0,
                      duration: const Duration(milliseconds: 2000),
                      repeatPauseDuration: const Duration(milliseconds: 100),
                      repeat: true,
                      child: IconButton(
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                        onPressed: _listenSpeech,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _displayData(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NoteDetailScreen.create(context: context),
            ),
          );
        },
        child: const Icon(Icons.create, size: 25.0),
        backgroundColor: Constants.mainDesignColor,
        foregroundColor: Colors.black87,
      ),
    );
  }

  _displayData() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_errorOccured) {
      return _buildEmptyContent(
        icon: Icons.error_outline,
        content: 'Something went wrong',
      );
    } else if (_searchedNotes.isEmpty) {
      return _buildEmptyContent(
        icon: Icons.hourglass_empty,
        content: 'Nothing here',
      );
    } else {
      return StaggeredGridView.countBuilder(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
        crossAxisCount: 4,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        itemCount: _searchedNotes.length,
        itemBuilder: (_, index) {
          final Note note = _searchedNotes[index];

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(_createRoute(
                  NoteDetailScreen.create(context: context, note: note)));
            },
            child: NoteCard(note: note),
          );
        },
        staggeredTileBuilder: (_) => StaggeredTile.fit(2),
      );
    }
  }

  _buildEmptyContent({@required String content, @required IconData icon}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 50.0),
        SizedBox(height: 12.0),
        Text(
          content,
          style: const TextStyle(fontSize: 24.0),
        ),
      ],
    );
  }

  _createRoute(page) {
    return PageRouteBuilder(
      pageBuilder: (conext, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero);

        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _speechToText.stop();
    super.dispose();
  }
}
