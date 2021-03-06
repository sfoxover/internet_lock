import 'package:flutter/material.dart';
import 'package:internet_lock/helpers/helpers.dart';
import 'package:internet_lock/models/website.dart';
import 'package:internet_lock/models/websitesBloc.dart';
import 'package:internet_lock/views/addWebsite.dart';
import 'package:internet_lock/widgets/iconButtonHelper.dart';

class AddWebsiteAdvanced extends StatefulWidget {
  // Website
  final Website website;

  AddWebsiteAdvanced({Key key, this.website}) : super(key: key);

  @override
  _AddWebsiteAdvancedState createState() => _AddWebsiteAdvancedState(website);
}

class _AddWebsiteAdvancedState extends State<AddWebsiteAdvanced> {
  // Global key to uniquely identify the Form
  final _formKey = GlobalKey<FormState>();
  // Website
  Website _website;

  // Set any web site values loaded from search page
  _AddWebsiteAdvancedState(this._website) {
    if (_website == null) {
      _website = new Website();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add website advanced'),
          actions: _getAppBarButtons(),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Website title
              new ListTile(
                leading: const Icon(Icons.title),
                title: TextFormField(
                  autovalidate: false,
                  initialValue: _website.title,
                  decoration: new InputDecoration(
                    hintText: "Website title",
                  ),
                  onSaved: (value) => this._website.title = value,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a title for this website.';
                    }
                  },
                ),
              ),

              // Website url
              new ListTile(
                leading: const Icon(Icons.home),
                title: TextFormField(
                  autovalidate: false,
                  initialValue: _website.startUrl,
                  decoration: new InputDecoration(
                    hintText: "Website url",
                  ),
                  onSaved: (value) => this._website.startUrl = value,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the url for this website.';
                    } else if (Helpers.isSearchUriMatch(value)) {
                      return 'Please do not enter the url of the search site or result.';
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
        "Save site", Icons.save_alt, context, _saveSite));
    // Cancel button
    results.add(IconButtonHelper.createRaisedButton(
        "Cancel", Icons.cancel, context, _cancel));
    // Show advanced button
    results.add(IconButtonHelper.createRaisedButton(
        "Search page", Icons.settings, context, _showSearchPage));
    return results;
  }

  // Save website details
  void _saveSite() async {
    if (this._formKey.currentState.validate()) {
      setState(() {
        this._formKey.currentState.save();
      });
      // Save to database
      if (_website.id > 0) {
        await WebsitesBloc.instance.edit(_website);
      } else {
        await WebsitesBloc.instance.add(_website);
      }
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    }
  }

  // Cancel page
  void _cancel() {
    Navigator.of(context).pop();
  }

  // Load search page
  void _showSearchPage() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddWebsite()),
    );
  }
}
