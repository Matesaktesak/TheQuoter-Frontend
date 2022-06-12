import 'package:flutter/material.dart';
import 'package:thequoter_flutter_frontend/icon_font_icons.dart';
import 'package:thequoter_flutter_frontend/main.dart';
import 'package:thequoter_flutter_frontend/models/quote.dart';

class QuoteDisplay extends StatelessWidget {
  late Quote quote;
  late dynamic future;
  final Map<String, String> appData;

  QuoteDisplay({Key? key, dynamic quote, required this.appData}) : super(key: key) {future = quote;}

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
          future: future,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if(snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
              if(snapshot.data is List<Quote>?) quote = snapshot.data![0];
              if(snapshot.data is Quote) quote = snapshot.data;

              return Expanded(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(quote.context != null) Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          quote.context!
                        ),
                      ),
                      Card(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        )),
                        elevation: 3,
                        color: const Color(0xFFFFFFFF),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "„${quote.text}”",
                                style: _quoteTextTheme,
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                "- ${quote.originator.name}",
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Color(0xFF222222)),
                              )
                            ],
                          ),
                        )
                      ),
                      if(quote.note != null) Text(
                        quote.note!
                      ),
                    ]
                  )
                ),
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
    fontFamily: "Playfair Display",
    fontStyle: FontStyle.italic,
    fontSize: 25.0,
    color: Color(0xFF000000),

  );
}
