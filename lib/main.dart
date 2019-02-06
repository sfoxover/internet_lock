import 'package:flutter/material.dart';
import 'package:internet_lock/models/website.dart';
import 'package:internet_lock/models/websitesBloc.dart';
import 'package:internet_lock/views/addWebsite.dart';
import 'package:internet_lock/views/loadWebsite.dart';

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
        '/loadWebsite': (BuildContext context) => new LoadWebsite(),
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

  // Load websites with BLOC pattern
  final bloc = WebsitesBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          actions: _getAppBarButtons(),
        ),
        body: StreamBuilder<List<Website>>(
            stream: bloc.websites,
            builder:
                (BuildContext context, AsyncSnapshot<List<Website>> snapshot) {
              if (snapshot.hasData) {
                return _getWebsitesView(snapshot);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
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

      // Edit website button
      results.add(RaisedButton.icon(
          icon: const Icon(Icons.edit, size: 18.0, color: Colors.white),
          color: Theme.of(context).primaryColor,
          label: Text('Edit',
              style: TextStyle(color: Colors.white, fontSize: 16.0)),
          onPressed: _editWebsiteClick));

      // Delete website button
      results.add(RaisedButton.icon(
          icon: const Icon(Icons.delete, size: 18.0, color: Colors.white),
          color: Theme.of(context).primaryColor,
          label: Text('Delete',
              style: TextStyle(color: Colors.white, fontSize: 16.0)),
          onPressed: _deleteWebsiteClick));

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

  // Add website clicked
  void _addWebsiteClick() {
    Navigator.of(context).pushNamed('/addWebsite');
  }

  // Edit website clicked
  void _editWebsiteClick() {}

  // Delete website clicked
  void _deleteWebsiteClick() {}

  // Load all websites
  _getWebsitesView(AsyncSnapshot<List<Website>> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        Website item = snapshot.data[index];
        return ListTile(
          title: Text(item.title),
          leading: Image.network(item.favIconUrl),
          onTap: _loadWebsite(item),
        );
      },
    );
  }

  // Load selected web site
  _loadWebsite(Website item) {
    Navigator.of(context).pushNamed('/loadWebsite/$item.startUrl');
  }
}
