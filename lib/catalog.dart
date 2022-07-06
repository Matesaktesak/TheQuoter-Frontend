import 'dart:math';
import 'dart:io';

import 'package:flutter/foundation.dart';
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

  const Catalog({required this.settings, Key? key}) : super(key: key);

  @override
  State<Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  Future<List<Quote>?>? _futureQuotes;
  List<Quote>? _quotes;

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
              openFilter(context);
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
          future: _futureQuotes,
          builder: (context, AsyncSnapshot<List<Quote>?> snapshot) {
            if(snapshot.connectionState == ConnectionState.none){
              Future.microtask(() => refresh(widget.settings.getString("token")!, widget.settings.getString("role")!));
            } else if(snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              _quotes = snapshot.data!; // Assign the fetched quotes to the processed ones
        
              return ListView.separated(
                controller: defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux ? AdjustableScrollController(20) : null,
                separatorBuilder: (context, index) => const SizedBox(height: 5,),
                itemCount: _quotes!.length,
                itemBuilder: (context, index) {
                  final bool approveButton = _quotes![index].state != Status.public && widget.settings.getString("role") == "admin";
                  final bool editButton = widget.settings.getString("role") == "admin";
                  final bool deleteButton = widget.settings.getString("role") == "admin";

                  final double er = (approveButton ? 0.2 : 0) + (editButton ? 0.2 : 0) + (deleteButton ? 0.2 : 0);
                  
                  return Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    )),
                    elevation: 3,
                    child: Slidable(
                      closeOnScroll: true,
                      endActionPane: er != 0 ? ActionPane(
                        extentRatio: er,
                        motion: const DrawerMotion(),
                        children: [
                          if(approveButton) SlidableAction(
                            onPressed: (context){
                              api.setStatusQuote(
                                token: widget.settings.getString("token")!,
                                quote: _quotes![index],
                                state: Status.public,
                              ).then((e){
                                 setState(() => refresh(widget.settings.getString("token")!, widget.settings.getString("role")!));  
                              });
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.check,
                            label: "OK",
                          ),
                          if(editButton) SlidableAction(
                            onPressed: (context){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => QuoteCreate(settings: widget.settings, isEdit: _quotes![index])));
                            },
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: "Edit",
                          ),
                          if(deleteButton) SlidableAction(
                            onPressed: (context){
                              showDialog(context: context, builder: (context) => AlertDialog(
                                content: const Text("Really?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Nope"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      api.deleteQuote(
                                        token: widget.settings.getString("token")!,
                                        quote: _quotes![index]
                                      ).then((e){
                                        setState(() => _quotes!.remove(_quotes![index]));  
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text("(Thanos snaps)")
                                  )
                                ],
                              ));
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: "NOK",
                          ),
                        ],
                      ) : null,
                      child: ListTile(
                        dense: true,
                        tileColor: _quotes![index].state == Status.public ? Colors.white : const Color.fromARGB(255, 255, 169, 169),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        )),
                        contentPadding: const EdgeInsets.fromLTRB(18.0, 6, 12.0, 12.0),
                        title: Text(
                          "„${_quotes![index].text}\"",
                          style: _quoteTextTheme,
                        ),
                        subtitle: Text(
                          "- ${_quotes![index].originator.name}",
                          style: Theme.of(context).textTheme.labelSmall,
                          textAlign: TextAlign.right,
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => QuoteDisplay(settings: widget.settings, quote: _quotes![index])));
                        },
                        onLongPress: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => QuoteCreate(settings: widget.settings, isEdit: _quotes![index])));
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

  void openFilter(BuildContext context){
    // TODO: Implement
  }

  void beginSearch(){
    // TODO: Implement
  }

  void refresh(String token, String role) {
    setState(() {
      _futureQuotes =  api.getQuotesCatalog(token: token, role: role);
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