class Person {
    final String id;
    final String name;
    final String type;

    Person({required this.id, required this.name, required this.type});

    // From a JSON object
    static Person fromJson(Map<String, dynamic> json) {
        return Person(
            id: json["_id"],
            name: json["name"],
            type: json["type"],
        );
    }

  @override
  bool operator == (other){
    return other is Person && id == other.id;
  }

  @override
  int get hashCode => Object.hash(id, name, type);

  @override
  String toString() {
    return "$name [$id]";
  }
}
