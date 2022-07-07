import 'package:flutter/material.dart';
import 'package:hlaskomat/quoteDeleteDialog.dart';
import 'package:hlaskomat/quote_create.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'icon_font_icons.dart';

import 'main.dart';
import 'models/quote.dart';

class QuoteDisplay extends StatelessWidget {
  final SharedPreferences settings;

  Quote? quote;
  final dynamic future;

  QuoteDisplay({required this.settings, Key? key, this.future, this.quote}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool pending = (quote?.state == Status.pending) && (settings.getString("role") == "admin");

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(quote != null ? "Quote" : "Random quote"),
        actions: [
          IconButton(
            onPressed: (){}, // TODO: Implement quote report
            icon: const Icon(Icons.flag)
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: future,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if(snapshot.connectionState == ConnectionState.none && quote != null) return QuoteBlock(quote: quote!, quoteTextTheme: _quoteTextTheme,);

            if(snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
              if(snapshot.data is List<Quote>?) quote = snapshot.data![0];
              if(snapshot.data is Quote) quote = snapshot.data;

              return QuoteBlock(quote: quote!, quoteTextTheme: _quoteTextTheme);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: FloatingActionButton.large(
          backgroundColor: pending ? const Color.fromARGB(255, 58, 233, 58) : null,
          onPressed: () {
            // TODO: Implement approve

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QuoteDisplay(
                  settings: settings,
                  future: api.getRandomQuote(settings.getString("token")!),
                )
              )
            );
          },
          child: pending ? const Icon(Icons.check) : const Icon(IconFont.perspective_dice_three),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: (settings.getString("role") == "admin") || (true /* TODO: check the quote is mine */) ? BottomAppBar(
        elevation: 5.0,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: settings.getString("role") == "admin" ? [
              Expanded(
                flex: 2,
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: "Edit",
                  onPressed: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => QuoteCreate(settings: settings, isEdit: quote,)));
                  },
                ),
              ),
              const Expanded(flex: 1, child: SizedBox(width: 5,)),
              Expanded( // Delete button
                flex: 2,
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: "Delete",
                  onPressed: (){
                    showDialog(context: context, builder: (context) => QuoteDeleteDialog(
                      token: settings.getString("token")!,
                      quote: quote!,
                      onDone: (e) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => QuoteDisplay(settings: settings))),
                    ));
                  }, // TODO: Test quote deletion
                ),
              ),
            ] : [ // If not an admin, let the user vote
              Expanded(
                flex: 2,
                child: IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: "Upvote",
                  onPressed: (){}, // TODO: Implement
                ),
              ),
              const Expanded(flex: 1, child: SizedBox(width: 5,)),
              Expanded(
                flex: 2,
                child: IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  tooltip: "Downvote",
                  onPressed: (){}, // TODO: Implement
                ),
              ),
            ]
          ),
        ),
      ) : null,
    );
  }

  final TextStyle _quoteTextTheme = const TextStyle(
    fontFamily: "Playfair Display",
    fontStyle: FontStyle.italic,
    fontSize: 25.0,
    color: Color(0xFF000000),

  );
}

class QuoteBlock extends StatelessWidget {
  const QuoteBlock({
    Key? key,
    required this.quote,
    required TextStyle quoteTextTheme,
  }) : _quoteTextTheme = quoteTextTheme, super(key: key);

  final Quote quote;
  final TextStyle _quoteTextTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
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
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF222222)),
                  )
                ],
              ),
            )
          ),
          if(quote.note != null) Text(
            quote.note!,
            textAlign: TextAlign.center,
          ),
        ]
      )
    );
  }
}
