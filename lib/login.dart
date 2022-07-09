import 'package:TheQuoter/models/responses.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'main.dart';

class Login extends StatefulWidget {
  final SharedPreferences settings;

  Login({required this.settings, Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _loginFormKey = GlobalKey<FormState>();

  Future<LoginResponse?>? futureLogin;
  bool error = false;

  @override
  Widget build(BuildContext context) {
    widget.settings.remove("token"); // Clear token (log out)

    _usernameController.text = widget.settings.getString("username") ?? "";

    if(widget.settings.getString("password") != null) {
      futureLogin = api.login(
        username: widget.settings.getString("username")!,
        password: widget.settings.getString("password")!,
      );
    }

    return Scaffold(
      primary: true,
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28.0, 16.0, 42.0, 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Form(
                  key: _loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          hintText: "Username",
                          helperText: "Enter your email or user name",
                        ),
                        controller: _usernameController,
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.key),
                          hintText: "Password",
                          helperText: "Enter your password",
                        ),
                        obscureText: true,
                        controller: _passwordController,
                      ),
                      const SizedBox(
                        height: 18.0,
                      ),
                      FutureBuilder(
                        future: futureLogin,
                        builder: (context, AsyncSnapshot<LoginResponse?> snapshot) {
                          if (snapshot.connectionState == ConnectionState.none) { // If the API request has not been made yet
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  // Show the login button
                                  onPressed: () {
                                    setState(() {
                                      futureLogin = api.login(
                                        username: _usernameController.text,
                                        password: _passwordController.text
                                      );
                                    });
                                  },
                                  child: const Text("Login"),
                                ),
                                if (error) const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text("Invalid username or password"),
                                ), // Show an error message
                              ],
                            );
                          } else if (snapshot.connectionState == ConnectionState.waiting) { // If the API request is still loading
                            return const CircularProgressIndicator(); // Show a loading indicator
                          } else if (snapshot.connectionState == ConnectionState.done) { // If the API request has finnished
                            if (snapshot.data != null) { // And a token has been returned
                              // Save the password // TODO: Switch to secure storage
                              widget.settings.setString("password", _passwordController.text);

                              widget.settings.setString("token", snapshot.data!.token);       // Save the token
                              widget.settings.setString("username", snapshot.data!.username); // Save the username
                              widget.settings.setString("email", snapshot.data!.email);       // Save the email
                              widget.settings.setString("id", snapshot.data!.id);             // Save the id
                              widget.settings.setString("class", snapshot.data!.clas.id);     // Save the class
                              widget.settings.setString("role", snapshot.data!.role.name);    // Save the role

                              Future.microtask(() => Navigator.pushReplacementNamed( context, "/")); // Go to the main page
                            } else { // If the token is invalid
                              Future.microtask(() => setState(() {
                                futureLogin = null; // Reset the future token
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
                  )),
            ),
            const SizedBox(
              height: 30.0,
            ), // Spacer
            SizedBox(
              height: 30.0,
              child: TextButton(
                onPressed: () => register(context),
                child: const Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void register(BuildContext context) {
    Navigator.pushNamed(context, "/register");
  }
}
