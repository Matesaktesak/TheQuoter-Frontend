import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thequoter_flutter_frontend/models/person.dart';
import 'package:thequoter_flutter_frontend/models/class.dart';
import 'dart:async';

import 'package:thequoter_flutter_frontend/models/quote.dart';

class QuoterAPI {
  String serverAddress;

  QuoterAPI(this.serverAddress) {
    print("QuoterAPI created");
    print(() async => await echo("The connetion to the server is working"));
  }

  Future<String> echo(String message) async {
    final response = await http.post(
      Uri(
        port: 8080,
        host: serverAddress,
        path: "/echo"
      ),
      body: {"message": message}
    );
    return jsonDecode(response.body)["message"];
  }

  Future<String> login(String username, String pwd) async {
    Uri url = Uri(host: serverAddress, path: "/users/login");

    http.Response res = await http.post(url, body: {
      "username": username,
      "password": pwd,
    });

    if (res.statusCode == 201) {
      return jsonDecode(res.body)["token"];
    } else {
      throw Exception(res.statusCode);
    }
  }

  Future<String> register(String username, String email, String pwd) async {
    Uri url = Uri(
      port: 8080,
      host: serverAddress,
      path: "/users/register"
    );

    http.Response res = await http.post(url, body: {
      "username": username,
      "password": pwd,
      "email": email,
    });

    if (res.statusCode == 201) {
      return jsonDecode(res.body)["token"];
    } else {
      throw Exception(res.statusCode);
    }
  }

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
      return Quote(
        data["_id"],
        data["author"],
        data["text"],
        data["context"],
        data["note"],
        Person(data["originator"]["_id"], data["originator"]["name"],
            data["originator"]["type"]),
        Class(data["class"]["_id"], data["class"]["name"]),
      );
    } else {
      // Else throw an exception
      throw Exception(res.statusCode);
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
      throw Exception("Quote creation error");
    }
  }
}
