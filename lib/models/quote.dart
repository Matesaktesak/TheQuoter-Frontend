import 'package:thequoter_flutter_frontend/models/class.dart';
import 'package:thequoter_flutter_frontend/models/person.dart';

class Quote {
  final String _id;
  final String author;
  final String text;
  final String context;
  final String note;
  final Person originator;
  final Class clas;

  const Quote(this._id, this.author, this.text, this.context, this.note, this.originator, this.clas);
}
