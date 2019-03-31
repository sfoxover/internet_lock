import 'package:flutter/material.dart';
import 'package:internet_lock/helpers/lockManager.dart';
import 'package:internet_lock/models/user.dart';
import 'package:internet_lock/models/userBloc.dart';
import 'package:internet_lock/models/userDbProvider.dart';
import 'package:internet_lock/views/addUser.dart';
import 'package:internet_lock/widgets/iconButtonHelper.dart';

class ParentLogon extends StatefulWidget {
  // Constructor
  ParentLogon({Key key}) : super(key: key);

  @override
  _ParentLogonState createState() => _ParentLogonState();
}

class _ParentLogonState extends State<ParentLogon> {
  // Selected list item
  int _selectedIndex = 0;
  // Selected website item
  User _selectedUser;
  // Page build context
  BuildContext _mainContext;

  // Constructor
  _ParentLogonState() {
    _checkForUserAccount();
  }

  // If not user exists load new user page
  Future _checkForUserAccount() async {
    try {
      final db = new UserDBProvider();
      bool empty = await db.isEmpty();
      if (empty) {
        _addUserClick();
      } else {
        UserBloc.instance.getUsers();
      }
    } catch (e) {
      print("Exception in ParentLogon::_checkForUserAccount, ${e.toString()}");
    }
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<User>>(
        stream: UserBloc.instance.users,
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          return _buildScaffold(snapshot);
        });
  }

  Widget _buildScaffold(AsyncSnapshot<List<User>> snapshot) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Parent logon"),
          actions: _getAppBarButtons(),
        ),
        floatingActionButton: _getFloatingButton(snapshot),
        body: _getUserView(snapshot));
  }

  // Display AppBar buttons dependent on admin logged in
  _getAppBarButtons() {
    try {
      List<Widget> results = [];
      if (LockManager.instance.loggedInUser != null) {
        // Edit websites
        results.add(IconButtonHelper.createRaisedButton(
            "Add/edit website",
            Icons.web_asset,
            context,
            () => Navigator.of(context).popUntil(ModalRoute.withName('/'))));
        // Add new user button
        results.add(IconButtonHelper.createRaisedButton(
            "Add parent", Icons.library_add, context, _addUserClick));
        // Logout parent
        results.add(IconButtonHelper.createRaisedButton("Logout", Icons.lock,
            context, () => _userLogout(LockManager.instance.loggedInUser)));
      } else {
        // Logon selected parent
        results.add(IconButtonHelper.createRaisedButton("Logon",
            Icons.lock_open, context, () => _ParentLogon(_selectedUser)));
      }
      return results;
    } catch (e) {
      print("Exception in ParentLogon::_getAppBarButtons, ${e.toString()}");
      return null;
    }
  }

  // Get floating action button
  _getFloatingButton(AsyncSnapshot<List<User>> snapshot) {
    if (snapshot.hasData && snapshot.data.length > 0) {
      return new FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: new Icon(Icons.lock_open),
        onPressed: () => _ParentLogon(_selectedUser),
      );
    } else {
      return Container();
    }
  }

  // Load all users list view
  Widget _getUserView(AsyncSnapshot<List<User>> snapshot) {
    try {
      if (snapshot.hasData && snapshot.data.length > 0) {
        if (_selectedUser == null) {
          if (snapshot.data[0] != null) {
            _selectedUser = snapshot.data[0];
          }
        }
        return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              User user = snapshot.data[index];
              // List view item
              return new Container(
                color: _selectedIndex == index
                    ? Theme.of(context).selectedRowColor
                    : Theme.of(context).scaffoldBackgroundColor,
                child: ListTile(
                  title: Text(user.name),
                  leading: Icon(Icons.supervised_user_circle),
                  selected: _selectedIndex == index,
                  // Logon user button
                  trailing: _getListItemButtons(user),
                  // Select list view item
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                      _selectedUser = user;
                    });
                  },
                ),
              );
            });
      } else {
        return _getEmptyList();
      }
    } catch (e) {
      print("Exception in ParentLogon::_getUserView, ${e.toString()}");
      return null;
    }
  }

  // Show edit and delete buttons on list item
  Widget _getListItemButtons(User user) {
    var buttons = new List<Widget>();
    final Color primary = Theme.of(context).primaryColor;
    if (LockManager.instance.loggedInUser != null) {
      // Edit user button
      buttons.add(IconButton(
          icon: const Icon(Icons.edit, size: 18.0),
          color: primary,
          onPressed: () => _editUserClick(user)));
      // Delete user button
      buttons.add(IconButton(
          icon: const Icon(Icons.delete, size: 18.0),
          color: primary,
          onPressed: () => _deleteUserClick(user)));
    } else {
      // Logon parent
      buttons.add(IconButton(
          icon: const Icon(Icons.lock, size: 18.0),
          color: primary,
          onPressed: () => _ParentLogon(user)));
    }
    return new ButtonBar(mainAxisSize: MainAxisSize.min, children: buttons);
  }

  // Return placeholder message
  _getEmptyList() {
    try {
      print("Loading empty user message for list.");
      var sites = new List<User>();
      sites.add(new User(id: -1, name: "Please add a user logon."));
      return ListView.builder(
          itemCount: sites.length,
          itemBuilder: (BuildContext context, int index) {
            User item = sites[index];
            return ListTile(
                title: Text(item.name),
                leading: Icon(Icons.supervised_user_circle),
                onTap: () {
                  _addUserClick();
                });
          });
    } catch (e) {
      print("Exception in ParentLogon::_getEmptyList, ${e.toString()}");
      return null;
    }
  }

  // Load add user page
  void _addUserClick() {
    try {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddUser(),
          ));
    } catch (e) {
      print("Exception in ParentLogon::_addUserClick, ${e.toString()}");
    }
  }

  // Edit selected user
  void _editUserClick(User user) {
    try {
      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddUser(user: user),
          ),
        );
      }
    } catch (e) {
      print("Exception in ParentLogon::_editUserClick, ${e.toString()}");
    }
  }

  // Delete selected user
  void _deleteUserClick(User user) {
    try {
      if (user != null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  title: Text(
                      "Are you sure you want to delete this parent logon?"),
                  content: SingleChildScrollView(
                    child: Text('${_selectedUser.name}'),
                  ),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("Yes"),
                      onPressed: () {
                        UserBloc.instance.delete(user.id);
                        // Log out deleted user
                        if (LockManager.instance.loggedInUser.id == user.id) {
                          LockManager.instance.loggedInUser = null;
                        }
                        _selectedUser = null;
                        _selectedIndex = -1;
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
      print("Exception in ParentLogon::_deleteUserClick, ${ex.toString()}");
    }
  }

  // Show user logon dialog
  void _ParentLogon(User user) {
    final password = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext contextDlg) {
          return AlertDialog(
              title: Text("Please enter your pin or password"),
              content: SingleChildScrollView(
                  child: new TextField(
                controller: password,
                decoration: new InputDecoration(labelText: "pin/password"),
                obscureText: true,
              )),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("OK"),
                  onPressed: () {
                    if (user.passwordMatches(password.text)) {
                      setState(() {
                        LockManager.instance.loggedInUser = user;
                      });
                      Navigator.of(context).popUntil(ModalRoute.withName('/'));
                    } else {
                      final snackBar = SnackBar(
                        content: Text(
                          'Your pin or password was not correct!',
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      );
                      Scaffold.of(_mainContext).showSnackBar(snackBar);
                      Future.delayed(const Duration(seconds: 5), () {
                        final scaffold = Scaffold.of(_mainContext);
                        scaffold.hideCurrentSnackBar();
                      });
                    }
                  },
                ),
                new FlatButton(
                    child: new Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  // Log out user
  void _userLogout(User user) {
    setState(() {
      LockManager.instance.loggedInUser = null;
    });
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }
}
