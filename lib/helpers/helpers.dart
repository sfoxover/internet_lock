// Static helper methods
import 'package:flutter/material.dart';

class Helpers {
  // Test if url matches search domain
  static isSearchUriMatch(String url) {
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
