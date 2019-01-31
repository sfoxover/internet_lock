// Static helper methods
import 'package:flutter/material.dart';

class Helpers{
  
  // Test if url matches search domain
  static isSearchUriMatch(String url)  {
    return false;
  }

  // Display alert message snackbar
  static displayAlert(String message, BuildContext context){
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

}