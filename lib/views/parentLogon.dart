import 'package:flutter/material.dart';
import 'package:internet_lock/helpers/lockManager.dart';
import 'package:internet_lock/models/user.dart';
import 'package:internet_lock/models/userBloc.dart';
import 'package:internet_lock/models/userDbProvider.dart';
import 'package:internet_lock/views/addUser.dart';

class UserLogon extends StatefulWidget {
  // Constructor
  UserLogon({Key key}) : super(key: key);

  @override
  _UserLogonState createState() => _UserLogonState();
}

class _UserLogonState extends State<UserLogon> {
  // Selected list item
  int _selectedIndex = 0;
  // Selected website item
  User _selectedUser;
  // Page build context
  BuildContext _mainContext;

  // Constructor
  _UserLogonState() {
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
      print("Exception in UserLogon::_checkForUserAccount, ${e.toString()}");
    }
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Parent logon"),
          actions: _getAppBarButtons(),
        ),
        body: StreamBuilder<List<User>>(
            stream: UserBloc.instance.users,
            builder:
                (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
              _mainContext = context;
              if (snapshot.hasData) {
                return _getUserView(snapshot);
              } else {
                return _getEmptyList();
              }
            }));
  }

  // Display AppBar buttons dependent on admin logged in
  _getAppBarButtons() {
    try {
      List<Widget> results = [];
      if (LockManager.instance.loggedInUser != null) {
        // Edit websites
        results.add(RaisedButton.icon(
            icon: const Icon(Icons.web_asset, size: 18.0, color: Colors.white),
            color: Theme.of(context).primaryColor,
            label: Text('Add/edit website',
                style: TextStyle(color: Colors.white, fontSize: 16.0)),
            onPressed: () {
              Navigator.of(context).popUntil(ModalRoute.withName('/'));
            }));

        // Add new user button
        results.add(RaisedButton.icon(
            icon:
                const Icon(Icons.library_add, size: 18.0, color: Colors.white),
            color: Theme.of(context).primaryColor,
            label: Text('Add parent',
                style: TextStyle(color: Colors.white, fontSize: 16.0)),
            onPressed: _addUserClick));

        // Logout parent
        results.add(RaisedButton.icon(
            icon: const Icon(Icons.lock_open, size: 30, color: Colors.white),
            color: Theme.of(context).primaryColor,
            label: Text('Logout',
                style: TextStyle(color: Colors.white, fontSize: 16.0)),
            onPressed: () {
              _userLogout(LockManager.instance.loggedInUser);
            }));
      } else {
        // Logon parent
        results.add(RaisedButton.icon(
            icon: const Icon(Icons.lock, size: 30, color: Colors.white),
            color: Theme.of(context).primaryColor,
            label: Text('Logon',
                style: TextStyle(color: Colors.white, fontSize: 16.0)),
            onPressed: () {
              _userLogon(_selectedUser);
            }));
      }
      return results;
    } catch (e) {
      print("Exception in UserLogon::_getAppBarButtons, ${e.toString()}");
      return null;
    }
  }

  // Load all users list view
  Widget _getUserView(AsyncSnapshot<List<User>> snapshot) {
    try {
      if (_selectedUser == null && snapshot.data.length > 0) {
        _selectedUser = snapshot.data[0];
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
    } catch (e) {
      print("Exception in UserLogon::_getUserView, ${e.toString()}");
      return null;
    }
  }

  // Show edit and delete buttons on list item
  Widget _getListItemButtons(User user) {
    if (LockManager.instance.loggedInUser == null) {
      return null;
    }
    var buttons = new List<Widget>();
    final Color primary = Theme.of(context).primaryColor;

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
      print("Exception in UserLogon::_getEmptyList, ${e.toString()}");
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
      print("Exception in UserLogon::_addUserClick, ${e.toString()}");
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
      print("Exception in UserLogon::_editUserClick, ${e.toString()}");
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
      print("Exception in UserLogon::_deleteUserClick, ${ex.toString()}");
    }
  }

  // Show user logon dialog
  void _userLogon(User user) {
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
                      Navigator.of(context).pop();
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