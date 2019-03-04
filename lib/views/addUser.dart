import 'package:flutter/material.dart';
import 'package:internet_lock/models/user.dart';
import 'package:internet_lock/models/userBloc.dart';
import 'package:internet_lock/widgets/iconButtonHelper.dart';

class AddUser extends StatefulWidget {
  // User
  final User user;

  AddUser({Key key, this.user}) : super(key: key);

  @override
  _AddUserState createState() => _AddUserState(user);
}

class _AddUserState extends State<AddUser> {
  // Global key to uniquely identify the Form
  final _formKey = GlobalKey<FormState>();
  // User
  User _user;
  // User pin control
  final _userPinKey = GlobalKey();

  // Set any web site values loaded from search page
  _AddUserState(this._user) {
    if (_user == null) {
      _user = new User();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add parent logon'),
          actions: _getAppBarButtons(),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Website title
              new ListTile(
                leading: const Icon(Icons.person),
                title: TextFormField(
                  autovalidate: false,
                  initialValue: _user.name,
                  decoration: new InputDecoration(
                    hintText: "Your name",
                  ),
                  onSaved: (value) => this._user.name = value,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a user name.';
                    }
                  },
                ),
              ),

              // pin password
              new ListTile(
                leading: const Icon(Icons.security),
                title: TextFormField(
                  key: _userPinKey,
                  autovalidate: false,
                  obscureText: true,
                  initialValue: _user.pin,
                  decoration: new InputDecoration(
                    hintText: "User pin or password",
                  ),
                  onSaved: (value) => this._user.pin = value,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a pin or password to logon for this user.';
                    } else if (value.length < 4) {
                      return 'Please user at least 4 digits for a pin or password.';
                    }
                  },
                ),
              ),

              // Repeat pin password
              new ListTile(
                leading: const Icon(Icons.repeat),
                title: TextFormField(
                  autovalidate: false,
                  obscureText: true,
                  initialValue: _user.pin,
                  decoration: new InputDecoration(
                    hintText: "Repeat pin or password",
                  ),
                  validator: (value) {
                    final FormFieldState<String> passwordField =
                        _userPinKey.currentState;
                    if (value.isEmpty) {
                      return 'Error, please enter a pin or password to logon for this user.';
                    } else if (value.length < 4) {
                      return 'Error, please user at least 4 digits for a pin or password.';
                    } else if (value != passwordField.value) {
                      return 'Error, pin or passwords do not match.';
                    }
                  },
                ),
              ),
            ],
          ),
        ));
  }

  // Display AppBar buttons dependent on admin logged in
  _getAppBarButtons() {
    List<Widget> results = [];
    // Save button
    results.add(IconButtonHelper.createRaisedButton(
        "Save user", Icons.save_alt, context, _saveSite));
    // Cancel button
    results.add(IconButtonHelper.createRaisedButton(
        "Cancel", Icons.cancel, context, _cancel));
    return results;
  }

  // Save user logon details
  void _saveSite() async {
    if (this._formKey.currentState.validate()) {
      setState(() {
        this._formKey.currentState.save();
      });
      // Save to database
      if (_user.id > 0) {
        await UserBloc.instance.edit(_user);
      } else {
        await UserBloc.instance.add(_user);
      }
      Navigator.of(context).pop();
    }
  }

  // Cancel page
  void _cancel() {
    Navigator.of(context).pop();
  }
}
