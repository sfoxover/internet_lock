import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:internet_lock/helpers/defines.dart';
import 'package:internet_lock/helpers/helpers.dart';
import 'package:internet_lock/models/website.dart';
import 'package:internet_lock/models/websiteDbProvider.dart';
import 'package:internet_lock/views/addWebsiteAdvanced.dart';

class AddWebsite extends StatefulWidget {
  AddWebsite({Key key}) : super(key: key);
  @override
  _AddWebsiteState createState() => _AddWebsiteState();
}

class _AddWebsiteState extends State<AddWebsite> {
  // Website url
  String _websiteUrl;
  // Website title
  String _websiteTitle;
  // Webview instance
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  // Constructor
  _AddWebsiteState() {
    // Listen for url changed event
    flutterWebviewPlugin.onUrlChanged.listen(onUrlChanged);
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: Defines.SEARCH_URL,
      initialChild: Container(
        child: const Center(
          child: Text('Loading.....'),
        ),
      ),
      appBar: new AppBar(
        title: new Text("Search and add website"),
        actions: _getAppBarButtons(),
      ),
    );
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
        label: Text('Advanced',
            style: TextStyle(color: Colors.white, fontSize: 16.0)),
        onPressed: _showAdvancedPage));
    return results;
  }

  // Verify user input is valid
  bool _validateUserInput() {
    var bOK = false;
    // Check for empty site
    if (_websiteUrl.isEmpty) {
      Helpers.displayAlert(
        context,
        "Error",
        "Please wait until your selected site is loaded, then click this button.",
      );
    } else if (Helpers.isSearchUriMatch(_websiteUrl)) {
      // Do not save url if its a search result
      Helpers.displayAlert(
        context,
        "Error",
        "Please click the search result link you want and select the site after its loaded.",
      );
    } else if (_websiteTitle.isEmpty) {
      // Do not save if no title was loaded
      Helpers.displayAlert(
        context,
        "Error",
        "Unable to load title from the selected website. Please type in the title of the website manually.",
      );
      _showAdvancedPage();
    } else {
      bOK = true;
    }
    return bOK;
  }

  // Validate and save new website
  void _addSite() async {
    if (_validateUserInput()) {
      // Save to database
      Website site = new Website(title: _websiteTitle, startUrl: _websiteUrl);
      WebsiteDBProvider.db.addWebsite(site);
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    }
  }

  // Show advanced settings page
  void _showAdvancedPage() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddWebsiteAdvanced(
              websiteUrl: _websiteUrl, websiteTitle: _websiteTitle)),
    );
  }

  // Cancel adding new website
  void _cancel() {
    Navigator.of(context).pop();
  }

  // Listen for url changed event
  void onUrlChanged(String url) async {
    _websiteUrl = url;
    // Find page title
    _websiteTitle =
        await flutterWebviewPlugin.evalJavascript("window.document.title");
    _websiteTitle = _websiteTitle.replaceAll('"', '');
  }
}
