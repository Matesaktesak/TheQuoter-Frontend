import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget{
  final SharedPreferences settings;
  const AboutPage({Key? key, required this.settings}): super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("About"),
      ),
      body: Column(
        children: [
          Image.asset("assets/icon/icon.png", width: 300,),
          Text("Hláškomat", style: Theme.of(context).textTheme.headline1,),
          const Text("by"),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground, decoration: TextDecoration.underline, fontSize: 20),
              children: [
                TextSpan(text: "Maxim Stanař ", recognizer: TapGestureRecognizer()..onTap =() => launchUrl(Uri.parse("https://github.com/MaximMaximS/"))),
                TextSpan(text: "(backend)\n", recognizer: TapGestureRecognizer()..onTap =() => launchUrl(Uri.parse("https://github.com/MaximMaximS/TheQuoter"))),
                TextSpan(text: "Matyáš Levíček ", recognizer: TapGestureRecognizer()..onTap =() => launchUrl(Uri.parse("https://github.com/Matesaktesak/"))),
                TextSpan(text: "(frontend)", recognizer: TapGestureRecognizer()..onTap =() => launchUrl(Uri.parse("https://github.com/Matesaktesak/the_quoter_frontend/"))),
          ])),
          const Text("(C)2022"),
          const Text("Toho času v Berouně..."),
          const Divider(),
          const Text("Shared under MIT license 'as is'."),
          ElevatedButton.icon(
            onPressed: () => launchUrl(Uri.parse("mailto:matyas.levicek@levicek.net?subject=Bug report")),
            label: const Text("Report a bug"),
            icon: const Icon(Icons.bug_report)
          )
        ],
      ),
    );
  }
}