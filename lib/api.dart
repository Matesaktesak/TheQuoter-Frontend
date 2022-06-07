import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';


class QuoterAPI {
  String serverAddress = "localhost:3000";

  QuoterAPI(this.serverAddress);
  

  Future<String> login(String username, String pwd) async {
    Uri url = Uri.parse(serverAddress + "/users/login");
    http.Response res = await http.post(
      url,
      body: {
        "username": username,
        "password": pwd,
      }
    );

    if(res.statusCode == 201){
      return jsonDecode(res.body)["token"];
    } else {
      throw Exception(res.statusCode);
    }
  }

  void getRandomQuote() async {
    Uri url = Uri.parse(serverAddress + "/quotes");

    http.Response res = await http.get(
      url,
      headers: {
        "authentication": "token goes here", // TODO: Add the damn token
      },
    );
  }
}