import 'package:flutter/material.dart';
import 'package:thequoter_flutter_frontend/main.dart';
import 'package:thequoter_flutter_frontend/models/class.dart';

class Register extends StatefulWidget {
  Map<String, String> appData;
  String? _classId;

  Register(this.appData, {Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _registerFormKey = GlobalKey<FormState>();

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
                            hint: Text("Class"),
                            value: widget._classId,
                            items: snapshot.data?.map((Class c) {
                              return DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              );
                            }).toList(),
                            onChanged: (String? value) { // On value changed
                              if(value != null) { // If value is not null
                                setState(() {
                                  widget._classId = value;
                                });
                              }
                            },
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
                  return value!.contains("@")
                      ? null
                      : "Email address has to contain a '@'";
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
              ElevatedButton(
                onPressed: () {
                  //setState() {
                  if(widget._classId != null) register(widget.appData, Class(id: widget._classId!));
                  //}
                  //Navigator.pop(context);
                },
                child: const Text("Register"),
              ),
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

  void register(appData, Class clas) async {
    print("Register clicked!");
    // TODO: Register functionality
    if (!validate()) return;

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    String token = await api.register(username, email, password, clas);

    appData["username"] = username;
    appData["jwt"] = token;

    print("username: $username, email: $email, password: $password");
  }

  bool validate() {
    return _registerFormKey.currentState!.validate();

    // TODO: Fix validation
  }
}
