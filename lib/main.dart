import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_lock/helpers/defines.dart';
import 'package:internet_lock/helpers/lockManager.dart';
import 'package:internet_lock/models/website.dart';
import 'package:internet_lock/models/websitesBloc.dart';
import 'package:internet_lock/views/addWebsite.dart';
import 'package:internet_lock/views/addWebsiteAdvanced.dart';
import 'package:internet_lock/views/loadWebsite.dart';
import 'package:internet_lock/views/parentLogon.dart';

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
  String _deviceName = "Tablet";
  // Check if app is pinned
  bool _isAppPinned = false;
  // Poll for app pinned state change
  Timer _timerAppPinned;

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
              if (snapshot.hasData && snapshot.data.length > 0) {
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
      // User is logged in
      if (LockManager.instance.loggedInUser != null) {
        // Add new website button
        results.add(RaisedButton.icon(
            icon:
                const Icon(Icons.library_add, size: 18.0, color: Colors.white),
            color: Theme.of(context).primaryColor,
            label: Text('Add site',
                style: TextStyle(color: Colors.white, fontSize: 16.0)),
            onPressed: _addWebsiteClick));

        // Allow admin to unpin device
        if (_isAppPinned) {
          results.add(RaisedButton.icon(
              icon: const Icon(Icons.lock, size: 18.0, color: Colors.white),
              color: Theme.of(context).primaryColor,
              label: Text('Unlock $_deviceName',
                  style: TextStyle(color: Colors.white, fontSize: 16.0)),
              onPressed: _unlockAppsClick));
        }
      }

      // Parent logon button
      results.add(RaisedButton.icon(
          icon: const Icon(Icons.settings, size: 18.0, color: Colors.white),
          color: Theme.of(context).primaryColor,
          label: Text('Parents',
              style: TextStyle(color: Colors.white, fontSize: 16.0)),
          onPressed: _parentLogonClick));

      // Show icon to lock app
      if (!_isAppPinned) {
        results.add(RaisedButton.icon(
            icon: const Icon(Icons.lock_open, size: 18.0, color: Colors.white),
            color: Theme.of(context).primaryColor,
            label: Text('Lock $_deviceName',
                style: TextStyle(color: Colors.white, fontSize: 16.0)),
            onPressed: _lockAppsClick));
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
  void _editWebsiteClick(Website website) {
    try {
      if (website != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddWebsiteAdvanced(website: website),
          ),
        );
      }
    } catch (e) {
      print("Exception in main::_editWebsiteClick, ${e.toString()}");
    }
  }

  // Delete website clicked
  void _deleteWebsiteClick(Website website) {
    try {
      if (website != null) {
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
                        WebsitesBloc.instance.delete(website.id);
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
                trailing: _getListTrailngButtons(item),
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

  // Show trailing edit and delete buttons
  Widget _getListTrailngButtons(Website website) {
    var buttons = new List<Widget>();
    final Color primary = Theme.of(context).primaryColor;

    // Button for admin user
    if (LockManager.instance.loggedInUser != null) {
      // Edit website button
      buttons.add(IconButton(
          icon: const Icon(Icons.edit, size: 18.0),
          color: primary,
          onPressed: () => _editWebsiteClick(website)));

      // Delete website button
      buttons.add(IconButton(
          icon: const Icon(Icons.delete, size: 18.0),
          color: primary,
          onPressed: () => _deleteWebsiteClick(website)));
    }
    // Load website button
    buttons.add(IconButton(
        icon: const Icon(Icons.play_arrow, size: 18.0),
        color: primary,
        onPressed: () => _loadWebsite(website)));

    return new ButtonBar(mainAxisSize: MainAxisSize.min, children: buttons);
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
          title: "Click 'Parent logon' to add a new website.",
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
      bool pinnedState = await _checkIfAppPinned();
      // App already pinned, just update button state
      if (pinnedState) {
        setState(() {
          _isAppPinned = true;
        });
      } else {
        // Start app pinned process
        LockManager.instance.loggedInUser = null;
        final platform =
            const MethodChannel('com.sfoxover.internetlock/lockapp');
        await platform.invokeMethod("lockApp");
        // Test for app pinned state change for 60 seconds
        _timerAppPinned = new Timer.periodic(
            const Duration(seconds: 1), _pollForLockStateChange);
      }
    } catch (e) {
      print("Exception in main::_lockAppsClick, ${e.toString()}");
    }
  }

  // Unlock device
  void _unlockAppsClick() async {
    try {
      bool pinnedState = await _checkIfAppPinned();
      // App already unlocked, just update button state
      if (!pinnedState) {
        setState(() {
          _isAppPinned = false;
        });
      } else {
        // Parent must logon to unlock
        if (LockManager.instance.loggedInUser == null) {
          _parentLogonClick();
        } else {
          // Start app pinned process
          final platform =
              const MethodChannel('com.sfoxover.internetlock/lockapp');
          await platform.invokeMethod("unlockApp");
          // Test for app pinned state change for 60 seconds
          _timerAppPinned = new Timer.periodic(
              const Duration(seconds: 1), _pollForLockStateChange);
        }
      }
    } catch (e) {
      print("Exception in main::_unlockAppsClick, ${e.toString()}");
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

  // Test for app pinned state change for 60 seconds
  _pollForLockStateChange(Timer timer) async {
    bool pinnedState = await _checkIfAppPinned();
    if (pinnedState && !_isAppPinned) {
      setState(() {
        _isAppPinned = true;
      });
    } else if (!pinnedState && _isAppPinned) {
      setState(() {
        _isAppPinned = false;
      });
    }
    if (timer.tick >= 60) {
      timer.cancel();
    }
  }
}
