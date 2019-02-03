// To parse this JSON data, do
//
//     final website = websiteFromJson(jsonString);

import 'dart:convert';

Website websiteFromJson(String str) {
  final jsonData = json.decode(str);
  return Website.fromJson(jsonData);
}

String websiteToJson(Website data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Website {
  int id;
  String title;
  String startUrl;
  String favIconUrl;
  List<dynamic> allowedUrls;

  Website({
    this.id,
    this.title,
    this.startUrl,
    this.favIconUrl,
    this.allowedUrls,
  }) {
    if (id == null) id = 0;
    if (favIconUrl == null || favIconUrl.isEmpty) {
      var uri = Uri.parse(startUrl);
      uri = uri.replace(path: "favicon.ico", query: "");
      favIconUrl = uri.toString();
    }
    if (allowedUrls == null) {
      allowedUrls = new List<String>();
    }
  }

  factory Website.fromJson(Map<String, dynamic> json) => new Website(
        id: json["id"],
        title: json["title"],
        startUrl: json["start_url"],
        favIconUrl: json["fav_icon_url"],
        allowedUrls: new List<dynamic>.from(json["allowed_urls"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "start_url": startUrl,
        "fav_icon_url": favIconUrl,
        "allowed_urls": new List<dynamic>.from(allowedUrls.map((x) => x)),
      };
}
