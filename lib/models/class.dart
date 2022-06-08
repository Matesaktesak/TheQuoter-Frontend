class Class {
  late String id;
  late String name;

  Class({required String id, String? name}){
    this.id = id;
    this.name = name ?? "No name class";
  }

  static Class fromJson(json) {
    return Class(id: json["_id"], name: json["name"]);
  }
}
