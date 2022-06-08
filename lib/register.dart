import 'package:flutter/material.dart';
import 'package:thequoter_flutter_frontend/main.dart';

class Register extends StatelessWidget {
  Map<String, String> appData;
  final _registerFormKey = GlobalKey<FormState>();
  
  Register(this.appData, {Key? key}) : super(key: key);

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
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: "Username*",
                  helperText: "Enter your desired user name",
                ),
                autofocus: true,
                controller: _usernameController,
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
              ElevatedButton(
                onPressed: () {
                  //setState() {
                    register(appData);
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

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordController2 = TextEditingController();

  void register(appData) async {
    print("Register clicked!");
    // TODO: Register functionality
    validate();

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    String token = await api.register(username, email, password);

    appData["username"] = username;
    appData["jwt"] = token;

    print("username: $username, email: $email, password: $password");
  }

  void validate() {
    _registerFormKey.currentState!.validate();

    // TODO: Fix validation
  }
}
