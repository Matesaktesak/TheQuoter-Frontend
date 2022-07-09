import 'class.dart';
import 'person.dart';

enum Status {
  pending,
  public
}

class Quote {
  final String id;
  //final String author;
  final String text;
  final String? context;
  final String? note;
  final Person originator;
  final Class? clas;
  final Status? state;

  const Quote({
    required this.id,
    //String author,
    required this.text,
    this.context,
    this.note,
    required this.originator,
    this.clas,
    this.state,
  });

  // From a JSON object
  static Quote fromJson(Map<String, dynamic> json) {
    Status? state;
    switch(json["state"]){
        case "pending": state = Status.pending; break;
        case "public": state = Status.public; break;
    }

    return Quote(
      id: json["_id"],
      //json["author"],
      text: json["text"],
      context: json["context"],
      note: json["note"],
      originator: Person.fromJson(json["originator"]),
      clas: json["class"] != null ? Class.fromJson(json["class"]) : null,
      state: state,
    );
  }

  @override
  String toString() => "'$text' (by $originator) [$id]";
}
