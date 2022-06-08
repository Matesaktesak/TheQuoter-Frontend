import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thequoter_flutter_frontend/models/person.dart';
import 'package:thequoter_flutter_frontend/models/class.dart';
import 'dart:async';

import 'package:thequoter_flutter_frontend/models/quote.dart';

class QuoterAPI {
  String serverAddress;
  int serverPort;

  QuoterAPI(this.serverAddress, this.serverPort) {
    print("QuoterAPI created");
    print(() async => await echo("The connetion to the server is working"));
  }

  Future<String> echo(String message) async {
    final response = await http.post(
        Uri(port: serverPort, host: serverAddress, path: "/echo"),
        body: {"message": message});
    return jsonDecode(response.body)["message"];
  }

  // Login request
  Future<String?> login(String username, String pwd) async {
    Uri uri = Uri(
        scheme: "http",
        port: serverPort,
        host: serverAddress,
        path: "/users/login");

    http.Response res = await http.post(uri, body: {
      "username": username,
      "password": pwd,
    });

    if (res.statusCode == 200) {
      print("Login sucessfull");
      return jsonDecode(res.body)["token"];
    } else {
      print("Login failed");
      return null;
      throw Exception("Login failed(${res.statusCode})");
    }
  }

  // Register request
  Future<String> register(
      String username, String email, String pwd, Class clas) async {
    Uri url = Uri(
        scheme: "http", port: serverPort, host: serverAddress, path: "/users");

    http.Response res = await http.post(url, body: {
      "username": username,
      "password": pwd,
      "email": email,
      "class": clas.id // TODO: Implement class
    });

    if (res.statusCode == 201) {
      print("Registered sucessfully!");
      return jsonDecode(res.body)["token"];
    } else {
      throw Exception("Registration failed(${res.statusCode})");
    }
  }

  // Get all classes
  Future<List<Class>>? getClasses() async {
    Uri url = Uri(
        scheme: "http",
        port: serverPort,
        host: serverAddress,
        path: "/classes");

    http.Response res = await http.get(url);

    if (res.statusCode == 200) {
      print("Classes fetched:");

      List<Class> fetched = (jsonDecode(res.body)["classes"] as List)
          .map<Class>((e) => Class.fromJson(e))
          .toList();

      fetched.sort((a, b) => a.name.compareTo(b.name));

      print(fetched.map((e) => e.name));
      return fetched;
    } else {
      throw Exception("Fetching classes failed(${res.statusCode})");
    }
  }

  // Get quotes by query
  Future<Quote>? getQuote(String token, {String? id, String? author}) async {
    // Prepare the query URI
    Uri uri = Uri(
      host: serverAddress,
      path: "/quotes",
      queryParameters: {
        if (id != null) "id": id,
        if (author != null) "author": author,
      },
    );

    // Send a get request to the server
    http.Response res = await http.get(
      uri,
      headers: {
        "authentication": token,
      },
    );

    Map<String, dynamic> data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      // If the request was successful
      return Quote.fromJson(data);
    } else {
      // Else throw an exception
      throw Exception("Quote query error(${res.statusCode})");
    }
  }

  // Create a new quote
  Future<String> createQuote(Quote q,
      {required Person author,
      required String text,
      String? context,
      String? note,
      required Person originator,
      Class? clas}) async {
    Uri uri = Uri(host: serverAddress, path: "/quotes");

    http.Response res = await http.post(uri, body: {
      "author": author,
      "text": text,
      "context": context ?? "",
      "note": note ?? "",
      "originator": originator,
      "class": clas ?? ""
    });

    if (res.statusCode == 201) {
      return jsonDecode(res.body)["_id"];
    } else {
      throw Exception("Quote creation error(${res.statusCode})");
    }
  }
}
