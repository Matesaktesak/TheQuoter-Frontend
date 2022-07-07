import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'about.dart';
import 'api.dart';

import 'catalog.dart';
import 'quote_create.dart';
import 'register.dart';
import 'login.dart';
import 'main_menu.dart';

QuoterAPI api = QuoterAPI("madison.levicek.net", 8083);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final SharedPreferences settings = await SharedPreferences.getInstance();
  
  runApp(TheQuoter(sharedPreferences: settings));
}

class TheQuoter extends StatefulWidget {
  final SharedPreferences sharedPreferences;

  TheQuoter({required this.sharedPreferences, Key? key}) : super(key: key);

  @override
  State<TheQuoter> createState() => _TheQuoterState();

  final ThemeData theme = ThemeData(
    disabledColor: const Color(0xFFC6D8D3),
    shadowColor: const Color(0xFF3A3335),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFF0544F),
      onPrimary: Colors.white,
      secondary: Color(0xFFD81E58),
      onSecondary: Color(0xFFFFFFF0),
      error: Color(0xFF251351),
      onError: Colors.white,
      //background: Color(0xFFFDF0D5),
      background: Color(0xFFC6D8D3),
      onBackground: Color(0xFF3A3335),
      surface: Color(0xFFC6D8D3),
      onSurface: Color.fromARGB(255, 241, 115, 111),
    ),
    fontFamily: GoogleFonts.notoSans().fontFamily,
    textTheme: const TextTheme(
        headline1: TextStyle(fontSize: 72.0),
        caption: TextStyle(fontStyle: FontStyle.italic), // Quote text
        subtitle1: TextStyle(fontSize: 11.0)
    ),
    listTileTheme: const ListTileThemeData(
      tileColor: Colors.white,
    )
  );
}

class _TheQuoterState extends State<TheQuoter> {
  @override
  Widget build(BuildContext context) {
    if(kDebugMode) print("Existing token: ${widget.sharedPreferences.getString("token")}");

    return MaterialApp(
      title: "Hláškomat",
      theme: widget.theme,
      routes: {
        "/": (context) => MainMenu(settings: widget.sharedPreferences),
        "/login": (context) => Login(settings: widget.sharedPreferences),
        "/register": (context) => Register(settings: widget.sharedPreferences),
        "/catalog": (context) => Catalog(settings: widget.sharedPreferences),
        "/quoteCreate": (context) => QuoteCreate(settings: widget.sharedPreferences),
        "/about": (context) => AboutPage(settings: widget.sharedPreferences)
      },

      // Only show the login screen if no JWT is present
      // TODO: Validate the JWT before showing the main menu
      initialRoute: widget.sharedPreferences.getString("token") == "" || widget.sharedPreferences.getString("token") == null ? "/login" : "/",
    );
  }
}
