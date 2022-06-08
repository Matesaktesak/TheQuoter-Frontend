import 'package:flutter/material.dart';
import 'package:thequoter_flutter_frontend/api.dart';
import 'package:thequoter_flutter_frontend/main.dart';

class Login extends StatelessWidget {
  Map<String, String> appData;

  Login(this.appData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                TextField(
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
                ElevatedButton(
                  onPressed: () {
                    login(appData);
                    Navigator.popAndPushNamed(context, "/");
                  },
                  child: const Text("Login"),
                ),
              ],
            )),
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

  void login(appData) async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    debugPrint("username: $username, password: $password");

    String token = await api.login(username, password);
    appData.appData["username"] = username;
    appData.appData["jwt"] = token;

    debugPrint("token retrieved: $token");
  }
}
