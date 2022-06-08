import 'package:thequoter_flutter_frontend/models/class.dart';
import 'package:thequoter_flutter_frontend/models/person.dart';

class Quote {
  final String id;
  final String author;
  final String text;
  final String context;
  final String note;
  final Person originator;
  final Class clas;

  const Quote(this.id, this.author, this.text, this.context, this.note, this.originator, this.clas);

  // From a JSON object
  static Quote fromJson(Map<String, dynamic> json) {
    return Quote(
      json["_id"],
      json["author"],
      json["text"],
      json["context"],
      json["note"],
      Person.fromJson(json["originator"]),
      Class.fromJson(json["class"]),
    );
  }
}
