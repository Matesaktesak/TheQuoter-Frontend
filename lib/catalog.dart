import 'package:flutter/material.dart';
import 'package:thequoter_flutter_frontend/main.dart';
import 'package:thequoter_flutter_frontend/models/quote.dart';

class Catalog extends StatefulWidget {
  Map<String, String> appData;
  Future<List<Quote>?>? futureQuotes;

  Catalog(this.appData, {Key? key}) : super(key: key);

  @override
  State<Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Catalog"),
        actions: [
          IconButton(
            onPressed: (){
              refresh(widget.appData["jwt"]!);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: widget.futureQuotes,
        builder: (context, AsyncSnapshot<List<Quote>?> snapshot) {
          if(snapshot.connectionState == ConnectionState.none){
            Future.microtask(() => refresh(widget.appData["jwt"]!));
          } else if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.fromLTRB(18.0, 6, 12.0, 12.0),
                  title: Text(
                    "„${snapshot.data![index].text}\"",
                    style: _quoteTextTheme,
                  ),
                  subtitle: Text(
                    "- ${snapshot.data![index].originator.name}",
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.right,
                  ),
                );
              },
            );
          }

          return Container();
        },
      )
    );
  }

  void refresh(String token) {
    setState(() {
      widget.futureQuotes =  api.getQuotesCatalog(token);
    });
  }

  final TextStyle _quoteTextTheme = const TextStyle(
    fontFamily: "Playfair Display",
    fontStyle: FontStyle.italic,
    fontSize: 25.0,
    color: Color(0xFF000000),

  );
}
