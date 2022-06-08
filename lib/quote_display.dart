import 'package:flutter/material.dart';

class QuoteDisplay extends StatelessWidget {
  Map<String, String> appData;

  String quote = "";
  String author = "";

  QuoteDisplay(this.appData, {String? quote, String? author, Key? key}) : super(key: key){
    this.quote = quote ?? "No quote here ¯\\_(ツ)_/¯";
    this.author = author?? "No author";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // TODO: Make the main menu (probably refactor into Statefull widget)
        body: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.secondary,
              child: Column(
                children: [
                  Text(
                    quote,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    author,
                    style: Theme.of(context).textTheme.labelSmall,
                  )
                ],
              ),
            )
          ],
        ),
    );
  }
}
