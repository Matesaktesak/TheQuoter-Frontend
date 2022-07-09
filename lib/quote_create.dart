import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'main.dart';
import 'models/class.dart';
import 'models/person.dart';
import 'models/responses.dart';
import 'quote_display.dart';

import 'models/quote.dart';

class QuoteCreate extends StatefulWidget {
  final SharedPreferences settings;

  Class? _class;
  String? _classId = "";
  Person? _originator;
  String? _originatorId;

  Quote? isEdit;

  QuoteCreate({required this.settings, this.isEdit, Key? key}) : super(key: key);

  @override
  State<QuoteCreate> createState() => _QuoteCreateState();
}

class _QuoteCreateState extends State<QuoteCreate> {
  final _quoteFormKey = GlobalKey<FormState>();

  Future<QuoteResponse>? futureQuote;
  bool error = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.isEdit != null){
      _textController.text = widget.isEdit?.text ?? "";
      _contextController.text = widget.isEdit?.context ?? "";
      _noteController.text = widget.isEdit?.note ?? "";

      widget._class = widget.isEdit?.clas;
      widget._classId = widget.isEdit?.clas?.id;

      widget._originator = widget.isEdit?.originator;
      widget._originatorId = widget.isEdit?.originator.id;
    }
  }

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
                decoration: const InputDecoration(
                  icon: Icon(Icons.textsms),
                  labelText: "Quote text*",
                  hintText: "He said she said",
                  helperText: "Enter what the person said",
                  //counterText: // TODO: Make the counter
                ),
                autofocus: true,
                controller: _textController,
                validator: (val) => val!.isEmpty ? "This field is required" : null,
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
                    future: api.getTeachers(),
                    builder: (context, AsyncSnapshot<List<Person>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the API request has finnished
                        return Expanded(
                          child: DropdownButton(
                            hint: const Text("Originator*"),
                            value: widget._originatorId,
                            items: snapshot.data?.map((Person p) {
                              return DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name),
                              );
                            }).toList(),
                            onChanged: (String? value) { // On value changed
                              if(value != null) { // If value is not null
                                setState(() {
                                  widget._originatorId = value;
                                  widget._originator = snapshot.data?.where((element) => element.id == value).first;
                                });
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
                    future: api.getClasses(),
                    builder: (context, AsyncSnapshot<List<Class>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the API request has finnished

                        //print(snapshot.data?.where((element) => element == widget._class));
                        return Expanded(
                          child: DropdownButton(
                            hint: const Text("Class"),
                            value: widget._classId,
                            items:[
                              const DropdownMenuItem(value: "", child: Text("No Class"),),
                              ...?snapshot.data?.map((Class c) {
                                return DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (String? value) { // On value changed
                              if(value != null) { // If value is not null
                                setState(() {
                                  widget._classId = value;
                                  widget._class = value != "" ? snapshot.data?.where((element) => element.id == value).first : null;
                                });
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
                builder: (context, AsyncSnapshot<QuoteResponse?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.none) { // If the API request has not been made yet
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton( // Show the register button
                          onPressed: () async {
                            final token = (await SharedPreferences.getInstance()).getString("token");

                            //print("Create button pressed");
                            setState(() {
                              if(validate() && widget._originator != null){
                                if(widget.isEdit == null) {
                                  futureQuote = api.createQuote(
                                  token: token!,
                                  originator: widget._originator!,
                                  text: _textController.text,
                                  context: _contextController.text,
                                  note: _noteController.text,
                                  clas: widget._class
                                );
                                }

                                if(widget.isEdit != null) {
                                  futureQuote = api.editQuote(
                                  token: token!,
                                  quote: Quote(
                                    id: widget.isEdit!.id,
                                    originator: widget._originator!,
                                    text: _textController.text,
                                    context: _contextController.text,
                                    note: _noteController.text,
                                    clas: widget._class
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
                        //print("snapshot.data: ${snapshot.data}");
                       
                        Future.microtask(() {
                          _textController.clear();                                 // Clear the text field
                          _contextController.clear();                              // Clear the context field
                          _noteController.clear();                                 // Clear the note field

                          /* setState(() {
                            widget._originatorId = null;                            // Clear the originator field
                            widget._originator = null;
                            widget._classId = null;                                 // Clear the class field
                            widget._class = null;                                   // Clear the class field
                          }); */

                          //print(snapshot.data!.id);

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


                        }); // Go to the main page
                      } else if(snapshot.data!.statusCode == 202) {
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
