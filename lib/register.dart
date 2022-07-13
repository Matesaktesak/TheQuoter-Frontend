import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'models/class.dart';
import 'models/responses.dart';

class Register extends StatefulWidget {
  final SharedPreferences settings;

  const Register({required this.settings, Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? _classId;
  final _registerFormKey = GlobalKey<FormState>();

  Future<UserStateResponse?>? futureUser;
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28.0, 16.0, 42.0, 16.0),
        child: Form(
          key: _registerFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: "Username*",
                        helperText: "Enter your desired user name",
                      ),
                      autofocus: true,
                      controller: _usernameController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: FutureBuilder(
                      future: api.getClasses(),
                      builder: (context, AsyncSnapshot<List<Class>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          // If the API request has finnished
                          return DropdownButton(
                            hint: const Text("Class"),
                            value: _classId,
                            items: snapshot.data?.map((Class c) {
                              return DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              );
                            }).toList(),
                            onChanged: (String? value) { // On value changed
                              if(value != null) { // If value is not null
                                setState(() {
                                  _classId = value;
                                });
                              }
                            },
                            //validator: (String? value) => value == null ? "Please select a class" : null,
                          );
                        } else {
                          // If the future is still loading
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12.0,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  hintText: "Email*",
                  helperText: "Enter your current email address",
                ),
                controller: _emailController,
                validator: (String? value) {
                  return value!.contains("@") ? null : "Email address has to contain a '@'";
                },
              ),
              const SizedBox(
                height: 12.0,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.key),
                  hintText: "Password",
                ),
                obscureText: true,
                controller: _passwordController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.key),
                  hintText: "Password again",
                  helperText: "Enter your password",
                ),
                obscureText: true,
                controller: _passwordController2,
                onChanged: (t) => validate,
                validator: (String? val) {
                  return (val != _passwordController.text) ? "The passwords don't match" : null;
                },
              ),
              const SizedBox(
                height: 18.0,
              ),
              FutureBuilder(
                future: futureUser,
                builder: (context, AsyncSnapshot<UserStateResponse?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.none) { // If the API request has not been made yet
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton( // Show the register button
                          onPressed: () {
                            if(kDebugMode) print("Register button pressed");
                            setState(() {
                              if(validate() && _classId != null) futureUser = api.register(_usernameController.text, _emailController.text, _passwordController.text, Class(id: _classId!));
                            });
                          },
                          child: const Text("Register"),
                        ),
                        if (error) const Padding( // Show error message
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text("Registration failed"),
                        ), // Show an error message
                      ],
                    );
                  } else if (snapshot.connectionState == ConnectionState.waiting) { // If the API request is still loading
                    return const CircularProgressIndicator(); // Show a loading indicator
                  } else if (snapshot.connectionState == ConnectionState.done) { // If the API request has finnished
                    if (snapshot.data != null) {         // And a token has been returned
                      if(kDebugMode) print("snapshot.data: ${snapshot.data}");

                      // Save the password // TODO: Switch to secure storage
                      widget.settings.setString("password", _passwordController.text);

                      widget.settings.setString("token", snapshot.data!.token);       // Save the token
                      widget.settings.setString("username", snapshot.data!.username); // Save the username
                      widget.settings.setString("email", snapshot.data!.email);       // Save the email
                      widget.settings.setString("id", snapshot.data!.id);             // Save the id
                      //widget.settings.setString("class", snapshot.data!.clas.id);     // Save the class
                      widget.settings.setString("role", snapshot.data!.role);    // Save the role

                      Future.microtask(() => Navigator.pushReplacementNamed(context, "/")); // Go to the main page
                    } else { // If the token is invalid
                      Future.microtask(() => setState(() {
                        futureUser = null; // Reset the future token
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

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();

  bool validate() {
    return _registerFormKey.currentState!.validate();

    // TODO: Fix validation
  }
}
