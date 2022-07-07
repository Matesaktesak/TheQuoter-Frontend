import 'dart:math';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hlaskomat/quoteDeleteDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'quote_create.dart';
import 'quote_display.dart';
import 'models/quote.dart';
import 'models/person.dart';

class Catalog extends StatefulWidget {
  final SharedPreferences settings;

  const Catalog({required this.settings, Key? key}) : super(key: key);

  @override
  State<Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  Future<List<Quote>?>? _futureQuotes;
  List<Quote>? _quotes;

  List<String>? _searchTerms;

  static final Map<String, int Function(Quote, Quote)> sortingFunctions = {
    "Default": <int>(a,b) => 0,
    "Alphabeticaly": (a,b) => a.text.compareTo(b.text),
    "Length": (a,b) => a.text.length.compareTo(b.text.length),
    "Originator": (a,b) => a.originator.name.compareTo(b.originator.name),
    "Random": <int>(a,b) => Random().nextInt(100) - 50,
  };

  int Function(Quote a, Quote b)? sortMethod = sortingFunctions["Default"];
  Future<List<Person>>? _teachers;
  Person? _filterTeacher;

  Widget _appBarContent = Text("Catalog");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: _appBarContent,
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
              
              List<Quote> filteredQuotes = (_filterTeacher != null ? _quotes?.where((element) => element.originator == _filterTeacher).toList() : _quotes) ?? List<Quote>.empty(growable: true);

              if(_searchTerms != null) {
                filteredQuotes = filteredQuotes.where((q) =>
                  _searchTerms!.map((t) =>
                    q.text.toLowerCase().contains(t)
                    || (q.context?.toLowerCase().contains(t) ?? false)
                    || (q.note?.toLowerCase().contains(t) ?? false)
                    || (q.id == t)
                    || (q.originator.name.toLowerCase().contains(t))
                  ).where((element) => element).isNotEmpty
                ).toList();
              }

              filteredQuotes.sort(sortMethod);


              return ListView.separated(
                controller: defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux ? AdjustableScrollController(20) : null, // Idiotic, but flutter hasn't implemeted Platform.isLinux for the web platform yet...
                separatorBuilder: (context, index) => const SizedBox(height: 5,),
                itemCount: filteredQuotes.length,
                itemBuilder: (context, index) {
                  final bool approveButton = filteredQuotes[index].state != Status.public && widget.settings.getString("role") == "admin";
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
                                quote: filteredQuotes[index],
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => QuoteCreate(settings: widget.settings, isEdit: filteredQuotes[index])));
                            },
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: "Edit",
                          ),
                          if(deleteButton) SlidableAction(
                            onPressed: (context){
                              showDialog(context: context, builder: (context) => QuoteDeleteDialog(
                                token: widget.settings.getString("token")!,
                                quote: filteredQuotes[index],
                                onDone: (e) => setState(() => _quotes?.remove(filteredQuotes[index])),
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
                        tileColor: filteredQuotes[index].state == Status.public ? Colors.white : const Color.fromARGB(255, 255, 169, 169),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        )),
                        contentPadding: const EdgeInsets.fromLTRB(18.0, 6, 12.0, 12.0),
                        title: Text(
                          "„${filteredQuotes[index].text}\"",
                          style: _quoteTextTheme,
                        ),
                        subtitle: Text(
                          "- ${filteredQuotes[index].originator.name}",
                          style: Theme.of(context).textTheme.labelSmall,
                          textAlign: TextAlign.right,
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => QuoteDisplay(settings: widget.settings, quote: filteredQuotes[index])));
                        },
                        onLongPress: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => QuoteCreate(settings: widget.settings, isEdit: filteredQuotes[index])));
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
    showModalBottomSheet(context: context, elevation: 8, builder: (context){
      _teachers = api.getTeachers();

      return StatefulBuilder(
        builder: (context, setState2) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text("Filter"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Icon(Icons.person),
                  const SizedBox(width: 16.0,),
                  FutureBuilder(
                    future: _teachers,
                    builder: (context, AsyncSnapshot<List<Person>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the API request has finnished
                        return Expanded(
                          child: DropdownButton<Person>(
                            hint: const Text("Originator"),
                            value: _filterTeacher,
                            items: [
                              const DropdownMenuItem(value: null, child: Text("Any"),),
                              ...?snapshot.data?.map((Person p) {
                                return DropdownMenuItem(
                                  value: p,
                                  child: Text(p.name),
                                );
                              }).toList()
                            ],
                            onChanged: (Person? value) { // On value changed
                              if(value != null) { // If value is not null
                                setState(() => setState2(() {
                                  _filterTeacher = value;
                                  //_filterTeacher = snapshot.data?.where((element) => element.id == value).first;
                                }));
                              }
                            },
                            //validator: (String? value) => value == null ? "Please select a class" : null,
                          ),
                        );
                      } else {
                        // If the future is still loading
                        return const Expanded(child: Center(child: CircularProgressIndicator()));
                      }
                    },
                  ),
                  TextButton(onPressed: (){ setState(()=>setState2((()=> _filterTeacher = null)));}, child: const Text("Reset")),
                ]),
            ),
            
            const Text("Sort by:"),
      
            ...sortingFunctions.entries.map((e) => ListTile(
              title: Text(e.key),
              leading: Radio<int Function(Quote, Quote)>(
                key: UniqueKey(),
                groupValue: sortMethod,
                value: e.value,
                onChanged: (f) => setState2(() => setState(() { if(f != null) sortMethod = f; })),
              ),
            )).toList(),
          ],
        ),
      );
    });
  }

  final _searchController = TextEditingController();

  void beginSearch(){
    // TODO: Implement

    setState(() {
      _appBarContent = Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        color: Colors.white,
        child: TextField(
          //cursorColor: Colors.white,
          autofocus: true,
          controller: _searchController,
          onChanged: (text){
            setState(() {
              _searchTerms = _searchController.text.toLowerCase().trim().split(" ");
            });
          },
        ),
      );
    });
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