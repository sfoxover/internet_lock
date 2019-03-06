import 'package:flutter/material.dart';

class IconButtonHelper {

  // Helper method to create RaisedButton
  static Widget createRaisedButton(
      String text, IconData icon, BuildContext context, VoidCallback callback) {
    var color = Theme.of(context).primaryColor;
    Widget value = new RaisedButton.icon(
      icon: Icon(icon, size: 18.0, color: Colors.white),
      color: color,
      label: Text(text, style: TextStyle(color: Colors.white, fontSize: 16.0)),
      onPressed: () => callback(),
    );
    return value;
  }

  // Helper method to create RaisedButton with icon on right
  static Widget createRaisedButtonRightIcon(
      String text, IconData icon, BuildContext context, VoidCallback callback) {
    var color = Theme.of(context).primaryColor;
    Widget value = new RaisedButton(
        child: Row(
          children: <Widget>[
            Text(text, style: TextStyle(color: Colors.white, fontSize: 16.0)),
            Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(icon, size: 18.0, color: Colors.white))
          ],
        ),
        color: color,
        onPressed: () => callback());
    return value;
  }
}
