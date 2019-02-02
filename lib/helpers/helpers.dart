// Static helper methods
import 'package:flutter/material.dart';
import 'package:internet_lock/helpers/defines.dart';

class Helpers {
  
  // Test if url matches search domain
  static isSearchUriMatch(String url) {
    var search = Uri.parse(Defines.SEARCH_URL);
    var uri = Uri.parse(url);
    if (search.host == uri.host)
      return true;
    else
      return false;
  }

  // Display alert message snackbar
  static displayAlert(BuildContext context, String title, String message) {
    // flutter defined function
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Text(message),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        });
  }
}
