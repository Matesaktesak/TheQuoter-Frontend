import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  Map<String, String> appData;
  MainMenu(this.appData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        elevation: 8.0,
        child: Column(
          children: [
            TextButton(
                onPressed: () => logout(context), child: const Text("Logout"))
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton(
                onPressed: () => "", child: const Text("Quote NOW!")),
          )
        ],
      ),
      // TODO: Make the main menu (probably refactor into Statefull widget)
    );
  }

  void logout(BuildContext context) {
    Navigator.of(context).pushReplacementNamed("/login");
  }
}
