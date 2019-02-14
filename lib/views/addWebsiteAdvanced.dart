import 'package:flutter/material.dart';
import 'package:internet_lock/helpers/helpers.dart';
import 'package:internet_lock/models/website.dart';
import 'package:internet_lock/models/websitesBloc.dart';
import 'package:internet_lock/views/addWebsite.dart';

class AddWebsiteAdvanced extends StatefulWidget {
  // Website url
  final String websiteUrl;
  // Website title
  final String websiteTitle;

  AddWebsiteAdvanced({Key key, this.websiteUrl, this.websiteTitle})
      : super(key: key);

  @override
  _AddWebsiteAdvancedState createState() =>
      _AddWebsiteAdvancedState(websiteUrl, websiteTitle);
}

class _AddWebsiteAdvancedState extends State<AddWebsiteAdvanced> {
  // Global key to uniquely identify the Form
  final _formKey = GlobalKey<FormState>();
  // Website title
  String _websiteTitle;
  // Website url
  String _websiteUrl;

  // Set any web site values loaded from search page
  _AddWebsiteAdvancedState(this._websiteUrl, this._websiteTitle);

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
                  initialValue: _websiteTitle,
                  decoration: new InputDecoration(
                    hintText: "Website title",
                  ),
                  onSaved: (value) => this._websiteTitle = value,
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
                  initialValue: _websiteUrl,
                  decoration: new InputDecoration(
                    hintText: "Website url",
                  ),
                  onSaved: (value) => this._websiteUrl = value,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the url for this website.';
                    } else if (Helpers.isSearchUriMatch(value)) {
                      return 'Please enter the url for this website. Do not enter the url of the search result.';
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
    results.add(RaisedButton.icon(
        icon: const Icon(Icons.save_alt, size: 18.0, color: Colors.white),
        color: Theme.of(context).primaryColor,
        label: Text('Save site',
            style: TextStyle(color: Colors.white, fontSize: 16.0)),
        onPressed: _addSite));

    // Cancel button
    results.add(RaisedButton.icon(
        icon: const Icon(Icons.cancel, size: 18.0, color: Colors.white),
        color: Theme.of(context).primaryColor,
        label: Text('Cancel',
            style: TextStyle(color: Colors.white, fontSize: 16.0)),
        onPressed: _cancel));

    // Show advanced button
    results.add(RaisedButton.icon(
        icon: const Icon(Icons.settings, size: 18.0, color: Colors.white),
        color: Theme.of(context).primaryColor,
        label: Text('Search page',
            style: TextStyle(color: Colors.white, fontSize: 16.0)),
        onPressed: _showSearchPage));
    return results;
  }

  // Save website details
  void _addSite() {
    if (this._formKey.currentState.validate()) {
      setState(() {
        this._formKey.currentState.save();
      });
      // Save to database
      Website site = new Website(title: _websiteTitle, startUrl: _websiteUrl);
      WebsitesBloc.instance.add(site);
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
