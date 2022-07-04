import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'icon_font_icons.dart';
import 'main.dart';
import 'quote_display.dart';

class MainMenu extends StatelessWidget {
  final SharedPreferences settings;

  const MainMenu({required this.settings, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Hláškomat"),
      ),
      drawer: Drawer(
        elevation: 8.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                child: Column(
                  children: [
                    Text(settings.getString("username")!,
                      style: Theme.of(context).textTheme.headline5
                    ),
                    Text(settings.getString("email")!),
                    const SizedBox(height: 8.0,),
                    Text(settings.getString("role")!)
                  ],
                ),
              ),
              Expanded( // Go to catalog
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/catalog");
                  },
                  child: const Text("Catalog"),
                )
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  primary: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(40.0),
                  backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () => logout(context),
                label: const Text("Logout"),
                icon: const Icon(Icons.logout),
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MenuButton(
              text: "Quote NOW!",
              icon: IconFont.perspective_dice_three,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuoteDisplay(
                      settings: settings,
                      future: api.getRandomQuote(settings.getString("token")!),
                    )
                  )
                );
              }
            ),
            MenuButton(text: "Quote of the day", icon: Icons.format_quote, onPressed: () => ""),
            MenuButton(text: "Catalog", icon: IconFont.inbox, onPressed: () => Navigator.pushNamed(context, "/catalog")),
            const SizedBox(height: 40), // TODO: remove
            MenuButton(
              text: "Create quote",
              icon: Icons.add,
              onPressed: () => Navigator.pushNamed(context, "/quoteCreate", )
            )
          ],
        ),
      ),
      // TODO: Make the main menu (probably refactor into Statefull widget)
    );
  }

  void logout(BuildContext context) {
    Navigator.of(context).pushReplacementNamed("/login");
  }
}

class MenuButton extends StatelessWidget{
  final String text;
  final void Function()? onPressed;
  final IconData? icon;

  const MenuButton({this.onPressed, Key? key, required this.text, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context){
    if(icon != null) {
      return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(60.0),
        ),
        onPressed: onPressed,
        label: Text(text)
      ),
    );
    } else {
      return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(60.0),
        ),
        onPressed: onPressed,
        child: Text(text)
      ),
    );
    }
    
  }
}
