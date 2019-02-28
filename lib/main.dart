import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_lock/helpers/defines.dart';
import 'package:internet_lock/helpers/lockManager.dart';
import 'package:internet_lock/models/website.dart';
import 'package:internet_lock/models/websitesBloc.dart';
import 'package:internet_lock/views/addWebsite.dart';
import 'package:internet_lock/views/addWebsiteAdvanced.dart';
import 'package:internet_lock/views/loadWebsite.dart';
import 'package:internet_lock/views/userLogon.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internet Lock',
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
  // Appbar title
  final String title;

  MainPage({Key key, this.title}) : super(key: key) {
    WebsitesBloc.instance.getWebsites();
  }

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Selected list item
  int _selectedIndex = 0;
  // Selected website item
  Website _selectedWebsite;
  // Device name
  String _deviceName = "tablet";
  // Check if app is pinned
  bool _isAppPinned = false;

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
            stream: WebsitesBloc.instance.websites,
            builder:
                (BuildContext context, AsyncSnapshot<List<Website>> snapshot) {
              if (snapshot.hasData) {
                return _getWebsitesView(snapshot);
              } else {
                return _getEmptyWebsiteList();
              }
            }));
  }

  // Display AppBar buttons dependent on admin logged in
  _getAppBarButtons() {
    try {
      List<Widget> results = [];
      if (LockManager.instance.loggedInUser != null) {
        // Add new website button
        results.add(RaisedButton.icon(
            icon:
                const Icon(Icons.library_add, size: 18.0, color: Colors.white),
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
            icon: const Icon(Icons.settings, size: 18.0, color: Colors.white),
            color: Theme.of(context).primaryColor,
            label: Text('Parent settings',
                style: TextStyle(color: Colors.white, fontSize: 16.0)),
            onPressed: _parentLogonClick));
      } else {
        // Parent logon button
        results.add(RaisedButton.icon(
            icon: const Icon(Icons.settings, size: 18.0, color: Colors.white),
            color: Theme.of(context).primaryColor,
            label: Text('Parent settings',
                style: TextStyle(color: Colors.white, fontSize: 16.0)),
            onPressed: _parentLogonClick));
        // App is pinned show locked icon
        if (_isAppPinned) {
          results.add(RaisedButton.icon(
              icon: const Icon(Icons.lock, size: 18.0, color: Colors.white),
              color: Theme.of(context).primaryColor,
              label: Text('$_deviceName locked',
                  style: TextStyle(color: Colors.white, fontSize: 16.0)),
              onPressed: _lockAppsClick));
        } else {
          // Show unlocked icon to pin app
          results.add(RaisedButton.icon(
              icon:
                  const Icon(Icons.lock_open, size: 18.0, color: Colors.white),
              color: Theme.of(context).primaryColor,
              label: Text('Lock $_deviceName',
                  style: TextStyle(color: Colors.white, fontSize: 16.0)),
              onPressed: _lockAppsClick));
        }
      }
      return results;
    } catch (e) {
      print("Exception in main::_getAppBarButtons, ${e.toString()}");
      return null;
    }
  }

  // Add website clicked
  void _addWebsiteClick() {
    Navigator.of(context).pushNamed('/addWebsite');
  }

  // Edit website clicked
  void _editWebsiteClick() {
    try {
      if (_selectedWebsite != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddWebsiteAdvanced(website: _selectedWebsite),
          ),
        );
      }
    } catch (e) {
      print("Exception in main::_editWebsiteClick, ${e.toString()}");
    }
  }

  // Delete website clicked
  void _deleteWebsiteClick() {
    try {
      if (_selectedWebsite != null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text("Are you sure you want to delete this website?"),
                  content: SingleChildScrollView(
                    child: Text('${_selectedWebsite.title}'),
                  ),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("Yes"),
                      onPressed: () {
                        WebsitesBloc.instance.delete(_selectedWebsite.id);
                        Navigator.of(context).pop();
                      },
                    ),
                    new FlatButton(
                        child: new Text("No"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                  ]);
            });
      }
    } catch (ex) {
      print("Exception in main::_deleteWebsiteClick, ${ex.toString()}");
    }
  }

  // Load all websites
  _getWebsitesView(AsyncSnapshot<List<Website>> snapshot) {
    try {
      if (_selectedWebsite == null && snapshot.data.length > 0) {
        _selectedWebsite = snapshot.data[0];
      }
      return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (BuildContext context, int index) {
            Website item = snapshot.data[index];
            // List view item
            return new Container(
              color: _selectedIndex == index
                  ? Theme.of(context).selectedRowColor
                  : Theme.of(context).scaffoldBackgroundColor,
              child: ListTile(
                title: Text(item.title),
                leading: Image.network(item.favIconUrl, height: 35),
                selected: _selectedIndex == index,
                // Load website button
                trailing: new SizedBox(
                    height: 35,
                    child: RaisedButton.icon(
                        icon: const Icon(Icons.play_arrow,
                            size: 35.0, color: Colors.white),
                        color: Theme.of(context).primaryColor,
                        label: Text('Load',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0)),
                        onPressed: () {
                          _loadWebsite(item);
                        })),
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                    _selectedWebsite = item;
                  });
                  //_loadWebsite(item);
                },
              ),
            );
          });
    } catch (e) {
      print("Exception in main::_getWebsitesView, ${e.toString()}");
      return null;
    }
  }

  // Load selected web site
  _loadWebsite(Website item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadWebsite(website: item),
      ),
    );
  }

  // Return placehold website
  _getEmptyWebsiteList() {
    try {
      print("Loading empty website message for list.");
      var sites = new List<Website>();
      sites.add(new Website(
          id: -1,
          title: "Click unlock to add a new website.",
          favIconUrl: Defines.SEARCH_FAV_ICON_URL));
      return ListView.builder(
        itemCount: sites.length,
        itemBuilder: (BuildContext context, int index) {
          Website item = sites[index];
          return ListTile(
            title: Text(item.title),
            leading: Image.network(item.favIconUrl),
            onTap: () {
              _parentLogonClick();
            },
          );
        },
      );
    } catch (e) {
      print("Exception in main::_getEmptyWebsiteList, ${e.toString()}");
      return null;
    }
  }

  // Handle parent logon click
  void _parentLogonClick() {
    // Load parent logon page
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserLogon(),
        ));
  }

  // Lock device to this app
  void _lockAppsClick() async {
    try {
      if (await _checkIfAppPinned()) {
        setState(() {
          _isAppPinned:
          true;
        });
      } else {
        final platform =
            const MethodChannel('com.sfoxover.internetlock/lockapp');
        await platform.invokeMethod("lockApp");
      }
    } catch (e) {
      print("Exception in main::_lockAppsClick, ${e.toString()}");
    }
  }

  // Test if app is pinned
  Future<bool> _checkIfAppPinned() async {
    bool pinned = false;
    try {
      final platform = const MethodChannel('com.sfoxover.internetlock/lockapp');
      var result = await platform.invokeMethod("getLockedStatus");
      if (result == "locked") {
        pinned = true;
      }
    } catch (e) {
      print("Exception in main::_checkIfAppPinned, ${e.toString()}");
    }
    return pinned;
  }
}
