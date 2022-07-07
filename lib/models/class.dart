class Class {
  late String id;
  late String name;

  Class({required this.id, String? name}): name = name ?? id;

  static Class fromJson(json) {
    //print("Creating a Class from $json");

    return Class(id: json["_id"], name: json["name"]);
  }

  @override
  bool operator == (other) => other is Class && id == other.id;

  @override
  String toString() => "Class[id: $id, name: $name]";
  
  @override
  int get hashCode => Object.hash(id, name);
  
}
