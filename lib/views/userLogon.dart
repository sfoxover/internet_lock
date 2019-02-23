import 'package:flutter/material.dart';
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
  // Is parent logged in
  bool _adminLoggedIn = false;
  // Selected list item
  int _selectedIndex = 0;
  // Selected website item
  User _selectedUser;

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
      if (_adminLoggedIn) {
        // Add new user button
        results.add(RaisedButton.icon(
            icon:
                const Icon(Icons.library_add, size: 18.0, color: Colors.white),
            color: Theme.of(context).primaryColor,
            label: Text('Add parent',
                style: TextStyle(color: Colors.white, fontSize: 16.0)),
            onPressed: _addUserClick));
        // Edit user button
        results.add(RaisedButton.icon(
            icon: const Icon(Icons.edit, size: 18.0, color: Colors.white),
            color: Theme.of(context).primaryColor,
            label: Text('Edit',
                style: TextStyle(color: Colors.white, fontSize: 16.0)),
            onPressed: _editUserClick));
        // Delete user button
        results.add(RaisedButton.icon(
            icon: const Icon(Icons.delete, size: 18.0, color: Colors.white),
            color: Theme.of(context).primaryColor,
            label: Text('Delete',
                style: TextStyle(color: Colors.white, fontSize: 16.0)),
            onPressed: _deleteUserClick));
      }
      return results;
    } catch (e) {
      print("Exception in UserLogon::_getAppBarButtons, ${e.toString()}");
      return null;
    }
  }

  // Load all users
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
                trailing: new SizedBox(
                    height: 35,
                    child: RaisedButton.icon(
                        icon: const Icon(Icons.play_arrow,
                            size: 35.0, color: Colors.white),
                        color: Theme.of(context).primaryColor,
                        label: Text('Logon',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0)),
                        onPressed: () {
                          _userLogon(user);
                        })),
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
  void _editUserClick() {
    try {
      if (_selectedUser != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddUser(user: _selectedUser),
          ),
        );
      }
    } catch (e) {
      print("Exception in UserLogon::_editUserClick, ${e.toString()}");
    }
  }

  // Delete selected user
  void _deleteUserClick() {
    try {
      if (_selectedUser != null) {
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
                        UserBloc.instance.delete(_selectedUser.id);
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

  void _userLogon(User user) {}
}
