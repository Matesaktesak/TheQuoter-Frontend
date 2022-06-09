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
                  title: Text("„${snapshot.data![index].text}\"", style: Theme.of(context).textTheme.caption,),
                  subtitle: Text("- ${snapshot.data![index].originator.name}", style: Theme.of(context).textTheme.labelSmall,),
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
}
