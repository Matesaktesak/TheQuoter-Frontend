import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'models/quote.dart';

import 'quote_create.dart';
import 'quote_display.dart';

class Catalog extends StatefulWidget {
  final SharedPreferences settings;

  Future<List<Quote>?>? futureQuotes;

  Catalog({required this.settings, Key? key}) : super(key: key);

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
              beginSearch();
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: (){
              openFilter();
            },
            icon: const Icon(Icons.filter_alt),
          ),
          IconButton(
            onPressed: () {
              final token = widget.settings.getString("token")!;
              refresh(token, widget.settings.getString("role")!);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: FutureBuilder(
          future: widget.futureQuotes,
          builder: (context, AsyncSnapshot<List<Quote>?> snapshot) {
            if(snapshot.connectionState == ConnectionState.none){
              Future.microtask(() => refresh(widget.settings.getString("token")!, widget.settings.getString("role")!));
            } else if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return ListView.separated(
                controller: Platform.isWindows || Platform.isLinux ? AdjustableScrollController(20) : null,
                separatorBuilder: (context, index) => const SizedBox(height: 5,),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    )),
                    elevation: 3,
                    child: Slidable(
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          if(snapshot.data![index].state != Status.public && widget.settings.getString("role") == "admin") SlidableAction(
                            onPressed: (context){
                              api.setStatusQuote(
                                token: widget.settings.getString("token")!,
                                quote: snapshot.data![index],
                                status: Status.public,
                              ).then((e){
                                 setState(() => refresh(widget.settings.getString("token")!, widget.settings.getString("role")!));  
                              });
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.check,
                            label: "Approve",
                          ),
                          if(widget.settings.getString("role") == "admin")SlidableAction(
                            onPressed: (context){
                              api.deleteQuote(
                                token: widget.settings.getString("token")!,
                                quote: snapshot.data![index]
                              );
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: "Delete",
                          ),
                        ],
                      ),
                      child: ListTile(
                        dense: true,
                        tileColor: snapshot.data![index].state == Status.public ? Colors.white : const Color.fromARGB(255, 255, 169, 169),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        )),
                        contentPadding: const EdgeInsets.fromLTRB(18.0, 6, 12.0, 12.0),
                        title: Text(
                          "„${snapshot.data![index].text}\"",
                          style: _quoteTextTheme,
                        ),
                        subtitle: Text(
                          "- ${snapshot.data![index].originator.name}",
                          style: Theme.of(context).textTheme.labelSmall,
                          textAlign: TextAlign.right,
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => QuoteDisplay(settings: widget.settings, quote: snapshot.data![index])));
                        },
                        onLongPress: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => QuoteCreate(settings: widget.settings, isEdit: snapshot.data![index])));
                        }
                     ),
                    ),
                  ); 
                },
              );
            }

            return Container();
          },
        ),
      )
    );
  }

  void openFilter(){
    // TODO: Implement
  }

  void beginSearch(){
    // TODO: Implement
  }

  void refresh(String token, String role) {
    setState(() {
      widget.futureQuotes =  api.getQuotesCatalog(token: token, role: role);
    });
  }

  final TextStyle _quoteTextTheme = const TextStyle(
    fontFamily: "Playfair Display",
    fontStyle: FontStyle.italic,
    fontSize: 25.0,
    color: Color(0xFF000000),

  );
}

class AdjustableScrollController extends ScrollController {
  AdjustableScrollController([int extraScrollSpeed = 40]) {
    super.addListener(() {
      ScrollDirection scrollDirection = super.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle) {
        double scrollEnd = super.offset +
            (scrollDirection == ScrollDirection.reverse
                ? extraScrollSpeed
                : -extraScrollSpeed);
        scrollEnd = min(super.position.maxScrollExtent,
            max(super.position.minScrollExtent, scrollEnd));
        jumpTo(scrollEnd);
      }
    });
  }
}