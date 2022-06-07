import 'package:flutter/material.dart';

class Register extends StatelessWidget {
  final _registerFormKey = GlobalKey<FormState>();
  
  Register({Key? key}) : super(key: key);

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
                onPressed: register,
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

  void register() {
    // TODO: Register functionality
    validate();
    print("Register clicked!");
  }

  void validate() {
    _registerFormKey.currentState!.validate();

    // TODO: Fix validation
  }
}
