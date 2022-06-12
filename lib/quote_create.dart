import 'package:flutter/material.dart';
import 'package:thequoter_flutter_frontend/main.dart';
import 'package:thequoter_flutter_frontend/models/class.dart';
import 'package:thequoter_flutter_frontend/models/person.dart';
import 'package:thequoter_flutter_frontend/quote_display.dart';

class QuoteCreate extends StatefulWidget {
  Map<String, String> appData;
  Class? _class;
  String? _classId = "";
  Person? _originator;
  String? _originatorId;

  QuoteCreate(this.appData, {Key? key}) : super(key: key);

  @override
  State<QuoteCreate> createState() => _QuoteCreateState();
}

class _QuoteCreateState extends State<QuoteCreate> {
  final _quoteFormKey = GlobalKey<FormState>();

  Future<String?>? futureQuoteId;
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: AppBar(
        title: const Text("Create new Quote"),
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
                future: futureQuoteId,
                builder: (context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.none) { // If the API request has not been made yet
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton( // Show the register button
                          onPressed: () {
                            print("Create button pressed");
                            setState(() {
                              if(validate() && widget._originator != null){
                                futureQuoteId = api.createQuote(
                                  widget.appData["jwt"]!,
                                  originator: widget._originator!,
                                  text: _textController.text,
                                  context: _contextController.text,
                                  note: _noteController.text,
                                  clas: widget._class
                                );
                              }
                            });
                          },
                          child: const Text("Submit"),
                        ),
                        if (error) const Padding( // Show error message
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text("Creation failed"),
                        ), // Show an error message
                      ],
                    );
                  } else if (snapshot.connectionState == ConnectionState.waiting) { // If the API request is still loading
                    return const CircularProgressIndicator(); // Show a loading indicator
                  } else if (snapshot.connectionState == ConnectionState.done) { // If the API request has finnished
                    if (snapshot.data != "" && snapshot.data != null) {         // And a token has been returned
                      print("snapshot.data: ${snapshot.data}");
                      Future.microtask(() => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuoteDisplay(
                            quote: api.getQuote(widget.appData["jwt"]!, text: _textController.text),
                            appData: widget.appData
                          ))
                      )); // Go to the main page
                    } else { // If the token is invalid
                      Future.microtask(() => setState(() {
                        futureQuoteId = null; // Reset the future token
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
