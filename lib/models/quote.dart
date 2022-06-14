import 'class.dart';
import 'person.dart';

enum Status {
  pending,
  approved
}

class Quote {
  final String id;
  //final String author;
  final String text;
  final String? context;
  final String? note;
  final Person originator;
  final Class? clas;
  final Status? status;

  const Quote({
    required this.id,
    //String author,
    required this.text,
    this.context,
    this.note,
    required this.originator,
    this.clas,
    this.status,
  });

  // From a JSON object
  static Quote fromJson(Map<String, dynamic> json) {
    Status? status;
    switch(json["status"]){
        case "pending": status = Status.pending; break;
        case "approved": status = Status.approved; break;
    }

    return Quote(
      id: json["_id"],
      //json["author"],
      text: json["text"],
      context: json["context"],
      note: json["note"],
      originator: Person.fromJson(json["originator"]),
      clas: json["class"] != null ? Class.fromJson(json["class"]) : null,
      status: status,
    );
  }
}
