import 'package:flutter/material.dart';
import 'package:thequoter_flutter_frontend/icon_font_icons.dart';
import 'package:thequoter_flutter_frontend/main.dart';
import 'package:thequoter_flutter_frontend/models/quote.dart';

class QuoteDisplay extends StatelessWidget {
  final Future<Quote>? quote;
  final Map<String, String> appData;

  const QuoteDisplay({Key? key, required this.quote, required this.appData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Random quote"),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.secondary,
            child: FutureBuilder(
              future: quote,
              builder: (context, AsyncSnapshot<Quote> snapshot) {
                if(snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    children: [
                      Text(
                        snapshot.data!.text,
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Text(
                        snapshot.data!.originator.name,
                        style: Theme.of(context).textTheme.labelSmall,
                      )
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuoteDisplay(
              appData: appData,
              quote: api.getRandomQuote(appData["jwt"]!),
            )
          )
        ),
        child: const Icon(IconFont.perspective_dice_three),
      ),
    );
  }
}
