import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'icon_font_icons.dart';
import 'capture.dart';

import 'main.dart';
import 'models/quote.dart';

class QuoteDisplay extends StatelessWidget {
  final SharedPreferences settings;

  Quote? quote;
  final dynamic future;
  final _captureKey = GlobalKey<CaptureWidgetState>();

  QuoteDisplay({Key? key, required this.settings, this.future, this.quote}) : super(key: key) {
    if(future == null && quote == null) throw Exception("At least one parameter has to be supplied!");
  }

  @override
  Widget build(BuildContext context) {
    bool pending = (quote?.state == Status.pending) && (settings.getString("role") == "admin");

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(quote != null ? "Quote" : "Random quote"),
        actions: [
          // Quote Share button
          if(defaultTargetPlatform != TargetPlatform.linux) IconButton( // Not awailable on Linux due to share_plus unimplemented .shareFiles
            onPressed: () async {
              // Make a path to save the temporary image (share_plus can't share a bytebuffer AHHHHRR)
              final path = "${ (await getTemporaryDirectory()).path }/${ quote?.id }.png";
              
              if(kDebugMode) print("Saving image to $path");
              
              final file = File(path); // Get the file

              // Make a png of the quote and render it to a file
              final image = await _captureKey.currentState?.captureImage();
              file.writeAsBytesSync(image!.data); // Would have to wait for it anyway

              // Create the share prompt
              Share.shareFiles(
                [path],
                text: "${quote?.text} -${quote?.originator.name}",
                subject: "Hláška z Hláškomatu",
                //sharePositionOrigin: // TODO: Implement for iPad users 
              );
            }, // TODO: Implement image sharing
            icon: const Icon(Icons.share)
          ),
          IconButton(
            onPressed: (){}, // TODO: Implement
            icon: const Icon(Icons.flag)
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: future,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {

            // If a future quote was supplied instead of a quote
            if(snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
              // Retrieve the quote (if it was a list (?!) take the first one)
              if(snapshot.data is List<Quote>?) quote = snapshot.data![0];
              if(snapshot.data is Quote) quote = snapshot.data;
            }

            // If no future quote was supplied a reademy-made quote must have been, so just run with it
            return quote != null ? CaptureWidget(
              key: _captureKey,
              capture: StandaloneQuoteBlock(quote: quote!, quoteTextTheme: _quoteTextTheme,), // TODO: Important: Fix wrong image size
              child: Center(child: QuoteBlock(quote: quote!, quoteTextTheme: _quoteTextTheme,)),
              //child: Transform.scale(scale: 0.75, child: StandaloneQuoteBlock(quote: quote!, quoteTextTheme: _quoteTextTheme)),
            ) : const Center(child: CircularProgressIndicator());
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
          tooltip: pending ? "Approve" : "Random quote",
          child: pending ? const Icon(Icons.check) : const Icon(IconFont.perspective_dice_three),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: settings.getString("role") == "admin" ? BottomAppBar(
        elevation: 5.0,
        shape: const CircularNotchedRectangle(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.green,
                Colors.white,
                Colors.white,
                Colors.red
              ]
            )
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
              Expanded(
                flex: 2,
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: "Edit",
                  onPressed: (){}, // TODO: Implement
                ),
              ),
              const Expanded(flex: 1, child: SizedBox(width: 5,)),
              Expanded(
                flex: 2,
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: "Delete",
                  onPressed: (){}, // TODO: Implement
                ),
              ),
            ]),
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
    String displayText = quote.text;

    // Custom word wraping after 25 characters
    int lastIndex = 0;
    for(int i = 0; i < displayText.length; i++){
      if(displayText[i] == "\n") lastIndex = i;
      if(i - lastIndex >= 23 && displayText[i] == ' ') {
        displayText = displayText.replaceRange(i, i, "\n");
        lastIndex = i;
      }
    }

    return FittedBox(
      fit: BoxFit.contain,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.start,
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
                    "„$displayText”",
                    style: _quoteTextTheme,
                    textAlign: TextAlign.left,
                    maxLines: 4,
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
          if(quote.note != null) Text("(${quote.note!})"),
        ]
      )
    );
  }
}

class StandaloneQuoteBlock extends StatelessWidget{
  final Quote quote;
  final TextStyle quoteTextTheme;

  const StandaloneQuoteBlock({Key? key, required this.quote, required this.quoteTextTheme}) : super(key: key);
  
  @override
  Widget build(BuildContext context){
    return Material(
      child: SizedBox(
        width: 1080,
        height: 1350,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            border: Border.all(color: Colors.red, )
          ),
          child: Stack(
            children: [
            const Align(
              alignment: Alignment(0.9,0.85),
              child:Text("(C)2022", style: TextStyle(
                color: Color(0x33000000),
                fontSize: 15
              ))
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    "assets/icon/icon.png",
                    width: 80,
                    opacity: const AlwaysStoppedAnimation(0.25),
                  ),
                  const Text(
                    "Hláškomat",
                    style: TextStyle(
                      shadows: [Shadow(blurRadius: 2, color: Color(0x22000000), offset: Offset(2, 2)),],
                      fontSize: 60.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(49, 167, 32, 77),
                    ),
                  ),
                ],
              ),
            ),
            Column(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child:
                  QuoteBlock(quote: quote, quoteTextTheme: quoteTextTheme,),
                ),
              ),
              QrImage(
                data: "http://${api.serverAddress}:${api.serverPort}/quotes/${quote.id}",
                gapless: true,
                size: 300,
                eyeStyle: QrEyeStyle(color: Theme.of(context).colorScheme.primary, eyeShape: QrEyeShape.square),
                dataModuleStyle: QrDataModuleStyle(color: Theme.of(context).colorScheme.onBackground, dataModuleShape: QrDataModuleShape.square),
                semanticsLabel: "Qr Code pointing to the quote on the web",
              ),
              SizedBox(width: 300, child: Text("http://${api.serverAddress}:${api.serverPort}/quotes/${quote.id}", textAlign: TextAlign.center,)),
              const SizedBox(height: 55,)
            ]),
          ]),
        ),
      ),
    );
  }

}
