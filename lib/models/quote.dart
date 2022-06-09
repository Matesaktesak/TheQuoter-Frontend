import 'package:thequoter_flutter_frontend/models/class.dart';
import 'package:thequoter_flutter_frontend/models/person.dart';

class Quote {
  final String id;
  //final String author;
  final String text;
  final String? context;
  final String? note;
  final Person originator;
  final Class? clas;

  const Quote({
    required this.id,
    //String author,
    required this.text,
    this.context,
    this.note,
    required this.originator,
    this.clas,
  });

  // From a JSON object
  static Quote fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json["_id"],
      //json["author"],
      text: json["text"],
      context: json["context"],
      note: json["note"],
      originator: Person.fromJson(json["originator"]),
      clas: json["class"] != null ? Class.fromJson(json["class"]) : null,
    );
  }
}
