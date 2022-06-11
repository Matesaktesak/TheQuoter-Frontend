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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Random quote"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: quote,
          builder: (context, AsyncSnapshot<Quote> snapshot) {
            if(snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(snapshot.data?.context != null) Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        snapshot.data!.context!
                      ),
                    ),
                    Card(
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      )),
                      elevation: 3,
                      color: Theme.of(context).colorScheme.primary,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "„${snapshot.data!.text}\"",
                              style: _quoteTextTheme,
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              "- ${snapshot.data!.originator.name}",
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                            )
                          ],
                        ),
                      )
                    ),
                    if(snapshot.data?.note != null) Text(
                      snapshot.data!.note!
                    ),
                  ]
                )
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }
        ),
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

  final TextStyle _quoteTextTheme = const TextStyle(
    fontStyle: FontStyle.italic,
    fontSize: 25.0,
    color: Color(0xFFFFFFFF),

  );
}
