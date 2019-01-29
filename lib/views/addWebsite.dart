import 'package:flutter/material.dart';

class AddWebsite extends StatefulWidget {
  AddWebsite({Key key}) : super(key: key);
  @override
  _AddWebsiteState createState() => _AddWebsiteState();
}

class _AddWebsiteState extends State<AddWebsite> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Add new website'),
        actions: _getAppBarButtons(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Test App',
            ),
          ],
        ),
      ),
    );
  }

  // Display AppBar buttons dependent on admin logged in
  _getAppBarButtons() {
    List<Widget> results = [];
    // Add new website button
    results.add(RaisedButton.icon(
        icon: const Icon(Icons.library_add, size: 18.0, color: Colors.white),
        color: Theme.of(context).primaryColor,
        label: Text('Add website',
            style: TextStyle(color: Colors.white, fontSize: 16.0)),
        onPressed: null));
    // Parent logout button
    results.add(RaisedButton.icon(
        icon: const Icon(Icons.lock_open, size: 18.0, color: Colors.white),
        color: Theme.of(context).primaryColor,
        label:
            Text('Lock', style: TextStyle(color: Colors.white, fontSize: 16.0)),
        onPressed: null));

    return results;
  }
}
