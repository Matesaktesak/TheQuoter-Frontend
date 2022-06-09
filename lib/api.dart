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
    try{
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
        print("Token: " + jsonDecode(res.body)["token"]);
        return jsonDecode(res.body)["token"];
      } else {
        print("Login failed");
        return null;
        throw Exception("Login failed(${res.statusCode})");
      }
    } catch (e) {
      print("Login failed");
      return null;
    }
  }

  // Register request
  Future<String?> register(String username, String email, String pwd, Class clas) async {
      Uri url = Uri(
      scheme: "http",
      port: serverPort,
      host: serverAddress, 
      path: "/users"
    );

    print("Sending register request");

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
      print("Registration failed");
      return null;
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
      print("Classes fetched");

      List<Class> fetched = (jsonDecode(res.body)["classes"] as List)
          .map<Class>((e) => Class.fromJson(e))
          .toList();

      fetched.sort((a, b) => a.name.compareTo(b.name));

      //print(fetched.map((e) => e.name));
      return fetched;
    } else {
      throw Exception("Fetching classes failed(${res.statusCode})");
    }
  }

  // Get quotes by query
  Future<List<Quote>?>? getQuote(String token, {String? text, Person? originator, Class? clas}) async {
    // Prepare the query URI
    Uri uri = Uri(
      scheme: "http",
      port: serverPort,
      host: serverAddress,
      path: "/quotes",
      queryParameters: {
        if(text != null) "text": text,
        if(originator != null) "originator": originator.id,
        if(clas != null) "class": clas.id,
        "state": "public",
      },
    );

    // Send a get request to the server
    http.Response res = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      // If the request was successful
      print("Quotes fetched");

      List<Quote>? fetched = (jsonDecode(res.body)["quotes"] as List)
          .map<Quote>((e) => Quote.fromJson(e))
          .toList();

      //print("${fetched.map((e) => e.id)}: ${fetched.map((e) => e.text)}");

      return fetched;
    } else {
      // Else throw an exception
      throw Exception("Quote query error(${res.statusCode})");
    }
  }

  // Get a random quote
  Future<Quote>? getRandomQuote(String token) async {
    Uri uri = Uri(
      scheme: "http",
      port: serverPort,
      host: serverAddress,
      path: "/quotes/random",
    );

    http.Response res = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      // If the request was successful
      print("Random quote fetched");

      Quote fetched = Quote.fromJson(jsonDecode(res.body));

      return fetched;
    } else {
      // Else throw an exception
      throw Exception("Random quote query error(${res.statusCode})");
    }
  }

  Future<List<Quote>?>? getQuotesCatalog(String token) async {
    return getQuote(token, ); // TODO: Implement proper catalog fetching
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
