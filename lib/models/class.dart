class Class {
  late String id;
  late String name;

  Class({required this.id, String? name}): name = name ?? id;

  static Class fromJson(json) {
    //print("Creating a Class from $json");

    return Class(id: json["_id"], name: json["name"]);
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Class[id: $id, name: $name]";
  }
}
