// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) {
  final jsonData = json.decode(str);
  return User.fromJson(jsonData);
}

String userToJson(User data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

// Parent user logon
class User {
  int id;
  String name;
  String pin;
  String createdDate;

  User({
    this.id,
    this.name,
    this.pin,
    this.createdDate,
  }) {
    if (id == null) {
      id = 0;
    }
  }

  factory User.fromJson(Map<String, dynamic> json) => new User(
        id: json["id"],
        name: json["name"],
        pin: json["pin"],
        createdDate: json["created_date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "pin": pin,
        "created_date": createdDate,
      };

  // Validate user logon
  bool passwordMatches(String value) {
    bool match = value != null && value.isNotEmpty && value == pin;
    return match;
  }
}
