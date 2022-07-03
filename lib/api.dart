import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'models/person.dart';
import 'models/class.dart';
import 'models/quote.dart';


class QuoterAPI {
  String serverAddress;
  int serverPort;

  QuoterAPI(this.serverAddress, this.serverPort) {
    print("QuoterAPI created");
    echo("The connetion to the server is working").then((value) => print(value));
  }

  Future<String> echo(String message) async {
    print("Echoing $message");
    final response = await http.get(Uri(
      scheme: "http",
      port: serverPort,
      host: serverAddress,
      path: "/echo",
      queryParameters: {"message": message},
    ));
    if(response.body == "Not Found") return "Echo failed - the server is probably running in production enviroment and doesn't inlude /echo";
    return jsonDecode(response.body)["message"];
  }

  // Login request
  Future<UserStateResponse?> login(String username, String pwd) async {
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
        print("Token: ${jsonDecode(res.body)["token"]}");

        Map<String, dynamic> data = jsonDecode(res.body);

        return UserStateResponse(
          token: data["token"],
          id: data["user"]["_id"],
          username: data["user"]["username"],
          email: data["user"]["email"],
          role: data["user"]["role"]
        );
      } else {
        print("Login failed");
        return null;
        throw Exception("Login failed(${res.statusCode})");
      }
    } catch (e) {
      print("Login failed, $e");
      return null;
    }
  }

  // Register request
  Future<String?> register(String username, String email, String pwd, Class clas) async {
    // TODO: Refactor into UserStateResponse type
    
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

      List<Class> fetched = (jsonDecode(res.body) as List)
          .map<Class>((e) => Class.fromJson(e))
          .toList();

      fetched.sort((a, b) => a.name.compareTo(b.name));

      //print(fetched.map((e) => e.name));
      return fetched;
    } else {
      throw Exception("Fetching classes failed(${res.statusCode})");
    }
  }

  // Get all classes
  Future<List<Person>>? getTeachers() async {
    Uri url = Uri(
        scheme: "http",
        port: serverPort,
        host: serverAddress,
        path: "/people",
        queryParameters: {
          "type": "teacher",
        }
      );

    http.Response res = await http.get(url);

    if (res.statusCode == 200) {
      print("Teachers fetched");

      List<Person> fetched = (jsonDecode(res.body) as List)
          .map<Person>((e) => Person.fromJson(e))
          .toList();

      fetched.sort((a, b) => a.name.compareTo(b.name));

      //print(fetched.map((e) => e.name));
      return fetched;
    } else {
      throw Exception("Fetching teachers failed(${res.statusCode})");
    }
  }


  // Get quotes by query
  Future<List<Quote>?>? getQuote(String token, {String? id, String? text, Person? originator, Class? clas, Status? state}) async {
    // Prepare the query URI
    Uri uri = Uri(
      scheme: "http",
      port: serverPort,
      host: serverAddress,
      path: "/quotes${id != null ? "/$id" : ""}",
      queryParameters: id == null ? {
        if(text != null) "text": text,
        if(originator != null) "originator": originator.id,
        if(clas != null) "class": clas.id,
        if(state != null) "state": state.name else "state": "public",
      } : null,
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

      List<Quote>? fetched;
      // If we are featching multiple potential quotes, the server wraps the quotes in "quotes" field
      if(jsonDecode(res.body) != null && id == null){
        fetched = (jsonDecode(res.body) as List)
          .map<Quote>((e) => Quote.fromJson(e))
          .toList();
      } else if(jsonDecode(res.body) != null && id != null){ // in case it was a single quote
        fetched = [Quote.fromJson(jsonDecode(res.body))];
      }
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

  Future<List<Quote>?>? getQuotesCatalog({required String token, required String role}) async {
    List<Quote> catalog = List<Quote>.empty(
      growable: true
    );

    List<Quote>? pending;
    if(role == "admin") pending = await getQuote(token, state: Status.pending);
    if(role == "admin" && pending != null) catalog.addAll(pending);
    
    List<Quote>? public = await getQuote(token, state: Status.public);
    if(public != null) catalog.addAll(public);

    return catalog; // TODO: Implement proper catalog fetching
  }

  // Create a new quote
  Future<QuoteActionResponse> createQuote({required String token,
    required String text,
    String? context,
    String? note,
    required Person originator,
    Class? clas
  }) async {
    Uri uri = Uri(
      scheme: "http",
      port: serverPort,
      host: serverAddress,
      path: "/quotes"
    );

    http.Response res = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
      },
      body: {
        "text": text,
        if(context != null) "context": context,
        if(note != null) "note": note,
        "originator": originator.id,
        if(clas != null) "class": clas.id
      }
    );

    if (res.statusCode == 201 || res.statusCode == 202) {
      return QuoteActionResponse(jsonDecode(res.body)["_id"], res.statusCode);
    } else {
      return QuoteActionResponse(null, res.statusCode);
      throw Exception("Quote creation error(${res.statusCode})");
    }
  }

  // Edit a quote
  Future<QuoteActionResponse> editQuote({required String token,
    required Quote quote}) async {
    Uri uri = Uri(
      scheme: "http",
      port: serverPort,
      host: serverAddress,
      path: "/quotes/${quote.id}"
    );

    http.Response res = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
      },
      body: {
        "text": quote.text,
        if(quote.context != null) "context": quote.context,
        if(quote.note != null) "note": quote.note,
        "originator": quote.originator.id,
        if(quote.clas != null) "class": quote.clas?.id
      }
    );

    if (res.statusCode == 204) {
      return QuoteActionResponse(quote.id, res.statusCode);
    } else {
      return QuoteActionResponse(null, res.statusCode);
      throw Exception("Quote editing error(${res.statusCode})");
    }
  }

  // Edit quote status
  Future<QuoteActionResponse> setStatusQuote({required String token, required Quote quote, required Status status,}) async {
    Uri uri = Uri(
      scheme: "http",
      port: serverPort,
      host: serverAddress,
      path: "/quotes/${quote.id}/state"
    );

    http.Response res = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token"
      },
      body: {
        "state": status.name
      }
    );

    if(res.statusCode == 204){
      print("State changed.");
      return QuoteActionResponse(quote.id, res.statusCode);
    } else {
      print("Status ${res.statusCode}");
      throw Exception("Server refused update");
    }
  }

  // Delete a quote
  Future<QuoteActionResponse> deleteQuote({required String token,
    required Quote quote}) async {
    Uri uri = Uri(
      scheme: "http",
      port: serverPort,
      host: serverAddress,
      path: "/quotes/${quote.id}"
    );

    print(uri);

    http.Response res = await http.delete(
      uri,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 204) {
      print("Deletion sucessfull");
      return QuoteActionResponse(null, res.statusCode);
    } else {
      print("Deletion refused: ${res.statusCode}");
        return QuoteActionResponse(null, res.statusCode);
      throw Exception("Quote editing error(${res.statusCode})");
    }
  }

}

// Created quote object
class QuoteActionResponse{
  final String? id;
  final int statusCode;

  QuoteActionResponse(this.id, this.statusCode);
}

class UserStateResponse{
  final String token;
  final String id;
  final String username;
  final String email;
  final String role;

  UserStateResponse({
    required this.token,
    required this.id,
    required this.username,
    required this.role,
    required this.email
  });
}
