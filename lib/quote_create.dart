import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'main.dart';
import 'models/class.dart';
import 'models/person.dart';
import 'quote_display.dart';

import 'models/quote.dart';

class QuoteCreate extends StatefulWidget {
  final SharedPreferences settings;

  final Quote? isEdit;

  const QuoteCreate({required this.settings, this.isEdit, Key? key}) : super(key: key);

  @override
  State<QuoteCreate> createState() => _QuoteCreateState();
}

class _QuoteCreateState extends State<QuoteCreate> {
  final _quoteFormKey = GlobalKey<FormState>();

  Class? _class;
  Person? _originator;

  Future<QuoteActionResponse>? futureQuote;
  Future<List<Person>>? _teachers;
  Future<List<Class>>? _classes;
  bool error = false;

  @override
  void initState() {
    super.initState();

    if(widget.isEdit != null){
      _textController.text = widget.isEdit?.text ?? "";
      _contextController.text = widget.isEdit?.context ?? "";
      _noteController.text = widget.isEdit?.note ?? "";

      _class = widget.isEdit?.clas;
      _originator = widget.isEdit?.originator;
    }

    _teachers = api.getTeachers();
    _classes = api.getClasses();
  }

  num _textCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: AppBar(
        title: widget.isEdit == null ? const Text("Create new Quote") : const Text("Edit Quote"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28.0, 16.0, 42.0, 16.0),
        child: Form(
          key: _quoteFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                maxLines: 10,
                minLines: 3,
                //expands: true,
                decoration: InputDecoration(
                  icon: const Icon(Icons.textsms),
                  labelText: "Quote text*",
                  hintText: "He said she said",
                  helperText: "Enter what the person said",
                  counterText: "$_textCounter / 400"
                ),
                autofocus: true,
                controller: _textController,
                validator: (val) {
                  if(val!.isEmpty) return "This field is required";
                  if(val.length > 400) return "Text too long - max 400";
                  return null; 
                },
                onChanged: (val){
                  setState(() {
                    _textCounter = _textController.text.length;
                  });
                },
              ),
              const SizedBox(height:18.0), // Spacer
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.link),
                  labelText: "Context",
                  hintText: "In this context:",
                  helperText: "In what context was the quote was said (should end with ':')",
                ),
                controller: _contextController,
                validator: (val) {
                  return val!.isNotEmpty && !val.endsWith(":") ? "Context has to end with ':'" : null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.more_horiz),
                  labelText: "Note",
                ),
                controller: _noteController,
              ),
              const SizedBox(height:18.0), // Spacer
              Row(
                children: [
                  const Icon(Icons.person),
                  const SizedBox(width: 16.0,),
                  FutureBuilder(
                    future: _teachers,
                    builder: (context, AsyncSnapshot<List<Person>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the API request has finnished
                        return Expanded(
                          child: DropdownButton(
                            hint: const Text("Originator*"),
                            value: _originator,
                            items: snapshot.data?.map((Person p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text(p.name),
                              );
                            }).toList(),
                            onChanged: (Person? value) { // On value changed
                              if(value != null) { // If value is not null
                                setState(() => _originator = value);
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
              ]),
              Row(
                children: [
                  const Icon(Icons.group),
                  const SizedBox(width: 16.0,),
                  FutureBuilder(
                    future: _classes,
                    builder: (context, AsyncSnapshot<List<Class>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the API request has finnished
                        //print(snapshot.data?.where((element) => element == widget._class));
                        return Expanded(
                          child: DropdownButton<Class>(
                            hint: const Text("Class"),
                            value: _class,
                            items:[
                              const DropdownMenuItem(value: null, child: Text("No Class"),),
                              ...?snapshot.data?.map((Class c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(c.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (Class? value) { // On value changed
                              if(value != null) { // If value is not null
                                setState(() =>_class = value);
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
              ]),

              const SizedBox(
                height: 18.0,
              ),
              FutureBuilder(
                future: futureQuote,
                builder: (context, AsyncSnapshot<QuoteActionResponse?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.none) { // If the API request has not been made yet
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton( // Show the register button
                          onPressed: () async {
                            if(kDebugMode) print("Create button pressed");

                            final token = widget.settings.getString("token");

                            setState(() {
                              if(validate() && _originator != null){
                                if(widget.isEdit == null) {
                                  if(kDebugMode) print("Sending create request");
                                  futureQuote = api.createQuote(
                                    token: token!,
                                    originator: _originator!,
                                    text: _textController.text,
                                    context: _contextController.text,
                                    note: _noteController.text,
                                    clas: _class
                                  );
                                }

                                if(widget.isEdit != null) {
                                  if(kDebugMode) print("Sending edit request");
                                  futureQuote = api.editQuote(
                                    token: token!,
                                    quote: Quote(
                                      id: widget.isEdit!.id,
                                      originator: _originator!,
                                      text: _textController.text,
                                      context: _contextController.text,
                                      note: _noteController.text,
                                      clas: _class
                                    ),
                                );
                                }
                              }
                            });
                          },
                          child: widget.isEdit == null ? const  Text("Submit") : const Text("Update"),
                        ),
                        if (error) const Padding( // Show error message
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text("Creation failed"),
                        ), // Show an error message
                      ],
                    );
                  } else if (snapshot.connectionState == ConnectionState.waiting) { // If the API request is still loading
                    return const CircularProgressIndicator();                     // Show a loading indicator
                  } else if (snapshot.connectionState == ConnectionState.done) { // If the API request has finnished
                    if (snapshot.data != null) {
                      if(snapshot.data!.statusCode == 201 || snapshot.data!.statusCode == 204){  // And a response has been received
                        if(kDebugMode) print("The action has been sucesfull");
                       
                        Future.microtask(() {
                          setState(() {
                            _textController.clear();                                 // Clear the text field
                            _contextController.clear();                              // Clear the context field
                            _noteController.clear();         // Clear the note field
                            futureQuote = null;
                          });

                          if(widget.isEdit == null) {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuoteDisplay(
                                future: api.getQuote(widget.settings.getString("token")!, id: snapshot.data!.id),
                                settings: widget.settings,
                              ))
                            );
                          } else {
                            Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuoteDisplay(
                                future: api.getQuote(widget.settings.getString("token")!, id: snapshot.data!.id),
                                settings: widget.settings,
                              ))
                            );
                          }
                        });
                      } else if(snapshot.data!.statusCode == 202) {
                        if(kDebugMode) print("The action has been sucesfull, but is pending for approval...");
                        
                        return Column(
                          children: [
                            const Text("The quote has been accepted and is pending approval"),
                            ElevatedButton(
                              onPressed: () => Navigator.pushReplacementNamed(context, "/quoteCreate"),
                              child: const Text("Create another quote"),
                            ),
                          ],
                        );
                      }
                      if(kDebugMode) print("This should never happen");
                    } else { // If the token is invalid
                      Future.microtask(() => setState(() {
                        futureQuote = null; // Reset the future token
                        error = true; // Show an error message
                      }));
                    }
                  }

                  if (snapshot.hasError) {
                    return Text(
                      "Error: ${snapshot.error}",
                      style: Theme.of(context).textTheme.headline6,
                    );
                  }

                  if(kDebugMode) print("This should never happen");
                  return Container();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool validate() {
    return _quoteFormKey.currentState!.validate();

    // TODO: Fix validation
  }
}
