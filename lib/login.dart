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

  Future<String?>? futureToken;
  bool error = false;

  @override
  void initState(){
    super.initState();
    _usernameController.text = widget.settings.getString("username") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    widget.settings.setString("token", ""); // Clear token (log out)

    //_usernameController.text = widget.settings.getString("username") ?? "";

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
                        future: futureToken,
                        builder: (context, AsyncSnapshot<String?> snapshot) {
                          if (snapshot.connectionState == ConnectionState.none) { // If the API request has not been made yet
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  // Show the login button
                                  onPressed: () {
                                    setState(() {
                                      futureToken = api.login(
                                          _usernameController.text,
                                          _passwordController.text);
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
                            if (snapshot.data != "" && snapshot.data != null) { // And a token has been returned
                              widget.settings.setString("username", _usernameController.text); // Save the username
                              widget.settings.setString("token", snapshot.data!); // Save the token
                              Future.microtask(() => Navigator.pushReplacementNamed( context, "/")); // Go to the main page
                            } else { // If the token is invalid
                              Future.microtask(() => setState(() {
                                futureToken = null; // Reset the future token
                                error = true; // Show an error message
                              }));
                            }
                          }

                          // TODO: Fix login to accept new data

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
