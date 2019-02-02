import 'package:flutter/material.dart';
import 'package:internet_lock/helpers/helpers.dart';
import 'package:internet_lock/views/addWebsite.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MainPage(title: 'Your Websites'),
       routes: <String, WidgetBuilder>{
      '/addWebsite': (BuildContext context) => new AddWebsite(),
    },
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  // Appbar title
  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Is admin logged in
  bool _adminLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
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
    if (_adminLoggedIn) {
      // Add new website button
      results.add(RaisedButton.icon(
          icon: const Icon(Icons.library_add, size: 18.0, color: Colors.white),
          color: Theme.of(context).primaryColor,
          label: Text('Add website',
              style: TextStyle(color: Colors.white, fontSize: 16.0)),
          onPressed: _addWebsiteClick));
      // Parent logout button
      results.add(RaisedButton.icon(
          icon: const Icon(Icons.lock_open, size: 18.0, color: Colors.white),
          color: Theme.of(context).primaryColor,
          label: Text('Lock',
              style: TextStyle(color: Colors.white, fontSize: 16.0)),
          onPressed: _parentLogOffClick));
    } else {
      // Parent logon button
      results.add(RaisedButton.icon(
          icon: const Icon(Icons.lock, size: 18.0, color: Colors.white),
          color: Theme.of(context).primaryColor,
          label: Text('Unlock',
              style: TextStyle(color: Colors.white, fontSize: 16.0)),
          onPressed: _parentLogonClick));
    }
    return results;
  }

  // Handle admin logon click
  void _parentLogonClick() {
    setState(() {
      _adminLoggedIn = true;
    });
  }

  // Handle admin log off click
  void _parentLogOffClick() {
    setState(() {
      _adminLoggedIn = false;
    });
  }

  // Load add website form
  void _addWebsiteClick() {
    Navigator.of(context).pushNamed('/addWebsite');
  }
}
