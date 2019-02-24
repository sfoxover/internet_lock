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
  static displayAlert(BuildContext context, String message) {
    try {
      final snackBar = SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      );
      Scaffold.of(context).showSnackBar(snackBar);
      Future.delayed(const Duration(seconds: 5), () {
        final scaffold = Scaffold.of(context);
        scaffold.hideCurrentSnackBar();
      });
    } catch (e) {
      print("Exception in Helpers::displayAlert, ${e.toString()}");
    }
  }

  // Test for empty string
  static isNullOrEmpty(String value) {
    try {
      if (value == null || value.isEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {}
    return true;
  }
}
