import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thequoter_flutter_frontend/api.dart';

import 'package:thequoter_flutter_frontend/catalog.dart';
import 'package:thequoter_flutter_frontend/quote_create.dart';
import 'package:thequoter_flutter_frontend/register.dart';
import 'package:thequoter_flutter_frontend/login.dart';
import 'package:thequoter_flutter_frontend/main_menu.dart';

QuoterAPI api = QuoterAPI("madison.levicek.net", 8083);
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TheQuoter());
}

class TheQuoter extends StatefulWidget {
  Map<String, String> appData = {"username": "", "jwt": ""};

  TheQuoter({Key? key}) : super(key: key);

  @override
  State<TheQuoter> createState() => _TheQuoterState();

  ThemeData theme = ThemeData(
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
      background: Color(0xFFFDF0D5),
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
  );
}

class _TheQuoterState extends State<TheQuoter> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Hláškomat",
      theme: widget.theme,
      routes: {
        "/": (context) => MainMenu(widget.appData),
        "/login": (context) => Login(widget.appData),
        "/register": (context) => Register(widget.appData),
        "/catalog": (context) => Catalog(widget.appData),
        "/quoteCreate": (context) => QuoteCreate(widget.appData),
      },
      initialRoute: "/login",
    );
  }
}
