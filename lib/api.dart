// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models/person.dart';
import 'models/class.dart';
import 'models/quote.dart';


class QuoterAPI {
  String serverAddress;
  int serverPort;

  QuoterAPI(this.serverAddress, this.serverPort) {
    if(kDebugMode) print("QuoterAPI created");
    // ignore: avoid_print
    if(kDebugMode) echo("The connetion to the server is working").then((value) => print(value));
  }

  // Echo test
  Future<String> echo(String message) async {
    if(kDebugMode) print("Echoing $message");
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
          path: "/users/login"
        );

      http.Response res = await http.post(uri, body: {
        "username": username,
        "password": pwd,
      });

      if (res.statusCode == 200) {
        if(kDebugMode) print("Login sucessfull");

        Map<String, dynamic> data = jsonDecode(res.body);

        if(kDebugMode) print("Token: ${data["token"]}");

        return UserStateResponse(
          token: data["token"],
          id: data["user"]["_id"],
          username: data["user"]["username"],
          email: data["user"]["email"],
          role: data["user"]["role"]
        );
      } else {
        if(kDebugMode) print("Login failed: ${res.statusCode}");
        return null;
        //throw Exception("Login failed(${res.statusCode})");
      }
    } catch (e) {
      if(kDebugMode) print("Login failed, $e");
      return null;
    }
  }

  // Register request
  Future<UserStateResponse?> register(String username, String email, String pwd, Class clas) async {
    Uri url = Uri(
      scheme: "http",
      port: serverPort,
      host: serverAddress, 
      path: "/users"
    );

    if(kDebugMode) print("Sending register request");

    http.Response res = await http.post(url, body: {
      "username": username,
      "password": pwd,
      "email": email,
      "class": clas.id
    });

    if (res.statusCode == 201) {
      if(kDebugMode) print("Registered sucessfully");
      Map<String, dynamic> data = jsonDecode(res.body);
      return UserStateResponse(
        token: data["token"],
        id: data["id"],
        username: data["username"],
        role: data["role"],
        email: data["email"]
      );
    } else {
      if(kDebugMode) print("Registration failed: ${res.statusCode}");
      throw Exception("Registration failed(${res.statusCode})");
    }
  }

  // Get all classes
  Future<List<Class>>? getClasses() async {
    Uri uri = Uri(
        scheme: "http",
        port: serverPort,
        host: serverAddress,
        path: "/classes");

    http.Response res = await http.get(uri);

    if(res.statusCode == 200) {

      List<Class> fetched = (jsonDecode(res.body) as List)
          .map<Class>((e) => Class.fromJson(e))
          .toList();

      fetched.sort((a, b) => a.name.compareTo(b.name));

      if(kDebugMode) print("Classes fetched: ${fetched.length}");

      return fetched;
    } else throw Exception("Fetching classes failed(${res.statusCode})");
  }

  // Get all classes
  Future<List<Person>>? getTeachers() async {
    Uri uri = Uri(
      scheme: "http",
      port: serverPort,
      host: serverAddress,
      path: "/people",
      queryParameters: {
        "type": "teacher",
      }
    );

    http.Response res = await http.get(uri);

    if (res.statusCode == 200) {
      List<Person> fetched = (jsonDecode(res.body) as List)
        .map<Person>((e) => Person.fromJson(e))
        .toList();

      fetched.sort((a, b) => a.name.compareTo(b.name));

      if(kDebugMode) print("Teachers fetched: ${fetched.length}");
      //print(fetched.map((e) => e.name));
      return fetched;
    } else throw Exception("Fetching teachers failed(${res.statusCode})");
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

    // If the request was successful
    if (res.statusCode == 200) {

      List<Quote>? fetched;
      // If we are featching multiple potential quotes, the server wraps the quotes in "quotes" field
      if(jsonDecode(res.body) != null && id == null){
        fetched = (jsonDecode(res.body) as List)
          .map<Quote>((e) => Quote.fromJson(e))
          .toList();
      } else if(jsonDecode(res.body) != null && id != null){ // in case it was a single quote
        fetched = [Quote.fromJson(jsonDecode(res.body))];
      }

      if(kDebugMode) print("Quotes fetched sucessfully: ${fetched?.length}");

      return fetched;
    } else { // Else throw an exception
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

    // If the request was successful
    if (res.statusCode == 200) {
      Quote fetched = Quote.fromJson(jsonDecode(res.body));

      if(kDebugMode) print("Random quote fetched: $fetched");

      return fetched;
    } else { // Else throw an exception
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
  Future<QuoteActionResponse> createQuote({
    required String token,
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
        if(context != null && context != "") "context": context,
        if(note != null && note != "") "note": note,
        "originator": originator.id,
        if(clas != null) "class": clas.id
      }
    );

    if (res.statusCode == 201 || res.statusCode == 202) {
      return QuoteActionResponse(jsonDecode(res.body)["_id"], res.statusCode);
    } else {
      if(kDebugMode) print("Quote creation failed: ${res.statusCode}");
      return QuoteActionResponse(null, res.statusCode);
      //throw Exception("Quote creation error(${res.statusCode})");
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

    if(kDebugMode) print("Sending quote update request: $uri");

    http.Response res = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
      },
      body: {
        "text": quote.text,
        if(quote.context != null && quote.context != "") "context": quote.context,
        if(quote.note != null && quote.note != "") "note": quote.note,
        "originator": quote.originator.id,
        if(quote.clas != null) "class": quote.clas?.id
      }
    );

    if (res.statusCode == 204) {
      return QuoteActionResponse(quote.id, res.statusCode);
    } else {
      if(kDebugMode) print("Quote update failed: ${res.statusCode}");
      return QuoteActionResponse(null, res.statusCode);
      //throw Exception("Quote editing error(${res.statusCode})");
    }
  }

  // Edit quote status
  Future<QuoteActionResponse> setStatusQuote({required String token, required Quote quote, required Status state,}) async {
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
        "state": state.name
      }
    );

    if(res.statusCode == 204){
      if(kDebugMode) print("Quote state changed sucessfully to ${state.name}.");
      return QuoteActionResponse(quote.id, res.statusCode);
    } else {
      if(kDebugMode) print("Quote state change failed: ${res.statusCode}");
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

    http.Response res = await http.delete(
      uri,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 204) {
      if(kDebugMode) print("Deletion sucessfull");
      return QuoteActionResponse(null, res.statusCode);
    } else {
      if(kDebugMode) print("Deletion refused: ${res.statusCode}");
      return QuoteActionResponse(null, res.statusCode);
      //throw Exception("Quote editing error(${res.statusCode})");
    }
  }

}

// Created quote object
class QuoteActionResponse{
  final String? id;
  final int statusCode;

  QuoteActionResponse(this.id, this.statusCode);
}

// Response model for login and register actions
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
