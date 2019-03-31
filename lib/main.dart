import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_lock/helpers/lockManager.dart';
import 'package:internet_lock/models/website.dart';
import 'package:internet_lock/models/websiteDbProvider.dart';
import 'package:internet_lock/models/websitesBloc.dart';
import 'package:internet_lock/views/addWebsite.dart';
import 'package:internet_lock/views/addWebsiteAdvanced.dart';
import 'package:internet_lock/views/loadWebsite.dart';
import 'package:internet_lock/views/parentLogon.dart';
import 'package:internet_lock/widgets/iconButtonHelper.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internet Lock',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MainPage(title: 'Websites'),
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
  // Can show lock app and floating button
  bool _listHasValues = true;
  // AppBar key
  final _appBarKey = new GlobalKey();

  _MainPageState() : super() {
    if (!Device.get().isTablet) {
      _deviceName = "Phone";
    }
    // Check for website to allow app pinning
    _checkCanShowLockAppButton();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Website>>(
        stream: WebsitesBloc.instance.websites,
        builder: (BuildContext context, AsyncSnapshot<List<Website>> snapshot) {
          return _buildScaffold(snapshot);
        });
  }

  Widget _buildScaffold(AsyncSnapshot<List<Website>> snapshot) {
    return Scaffold(
        appBar: AppBar(
          key: _appBarKey,
          title: Text(widget.title),
          actions: _getAppBarButtons(),
        ),
        floatingActionButton: _getFloatingButton(snapshot),
        body: _getWebsitesView(snapshot));
  }

  // Display AppBar buttons dependent on admin logged in
  _getAppBarButtons() {
    try {
      List<Widget> results = [];
      bool isLoggedIn = LockManager.instance.loggedInUser != null;
      // User is logged in
      if (isLoggedIn) {
        // Add new website button
        results.add(IconButtonHelper.createRaisedButton(
            "Add site", Icons.library_add, context, _addWebsiteClick));
      }
      // Parent logon button
      results.add(IconButtonHelper.createRaisedButton(
          "Parents", Icons.settings, context, _parentLogonClick));
      // Allow admin to unpin device
      if (isLoggedIn && _isAppPinned) {
        results.add(IconButtonHelper.createRaisedButton(
            "Unlock $_deviceName", Icons.lock_open, context, _unlockAppsClick));
      }
      // Show icon to lock app if there is at least 1 website
      if (!_isAppPinned && _listHasValues) {
        results.add(IconButtonHelper.createRaisedButton(
            "Lock $_deviceName", Icons.lock, context, _lockAppsClick));
      }
      return results;
    } catch (e) {
      print("Exception in main::_getAppBarButtons, ${e.toString()}");
      return null;
    }
  }

  // Get floating action button
  _getFloatingButton(AsyncSnapshot<List<Website>> snapshot) {
    if (snapshot.hasData && snapshot.data.length > 0) {
      return new FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: "Open selected website",
        child: new Icon(Icons.open_in_new),
        onPressed: () => _loadWebsite(_selectedWebsite),
      );
    } else {
      return Container();
    }
  }

  // Add website clicked
  void _addWebsiteClick() async {
    await Navigator.of(context).pushNamed('/addWebsite');
    // Check for website to allow app pinning
    _checkCanShowLockAppButton();
  }

  // Check for website to allow app pinning
  _checkCanShowLockAppButton() async {
    // Check state for 2 seconds
    Timer.periodic(const Duration(milliseconds: 200), (Timer timer) {
      if (_listHasValues != WebsitesBloc.instance.hasWebSites) {
        setState(() {
          _listHasValues = WebsitesBloc.instance.hasWebSites;
        });
        build(_appBarKey.currentContext);
      }
      if (timer.tick >= 10) {
        timer.cancel();
      }
    });
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
                        _checkCanShowLockAppButton();
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
      // Load list with websites
      if (snapshot.hasData && snapshot.data.length > 0) {
        if (_selectedWebsite == null && snapshot.data.length > 0) {
          _selectedWebsite = snapshot.data[0];
          _listHasValues = true;
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
      } else {
        // Show empty websites view
        return _getEmptyWebsiteView();
      }
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
  _getEmptyWebsiteView() {
    try {
      // Check if we can show lock app button
      if (_listHasValues) {
        _checkCanShowLockAppButton();
      }

      String text1 =
          '1 - Click the "Parents" button to create a user logon with your pin or password. Then add websites you want to allow access to.';
      String text2 =
          '2 - When you want to lock the $_deviceName to only these websites, click "Lock $_deviceName".';
      String text3 =
          '3 - When you are ready to unlock the $_deviceName, click "Parents" button and logon with the pin or password you created. After that you will then be able to click the "Unlock $_deviceName" button.';

      return Column(children: <Widget>[
        Card(
            child: ListTile(
                leading: Icon(Icons.web),
                title: Text('Welcome'),
                subtitle: Text('Please read the quick start guide below.'))),
        Row(children: <Widget>[
          Expanded(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(25, 20, 20, 0),
                  child:
                      Text(text1, style: Theme.of(context).textTheme.subhead)))
        ]),
        Row(children: <Widget>[
          Expanded(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(25, 20, 20, 0),
                  child:
                      Text(text2, style: Theme.of(context).textTheme.subhead)))
        ]),
        Row(children: <Widget>[
          Expanded(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(25, 20, 20, 0),
                  child:
                      Text(text3, style: Theme.of(context).textTheme.subhead)))
        ])
      ]);
    } catch (e) {
      print("Exception in main::_getEmptyWebsiteView, ${e.toString()}");
      return null;
    }
  }

  // Handle parent logon click
  void _parentLogonClick() {
    // Load parent logon page
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ParentLogon(),
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
