class Person {
    final String id;
    final String name;
    final String type;

    Person(this.id, this.name, this.type);

    // From a JSON object
    static Person fromJson(Map<String, dynamic> json) {
        return Person(
            json["_id"],
            json["name"],
            json["type"],
        );
    }
}
