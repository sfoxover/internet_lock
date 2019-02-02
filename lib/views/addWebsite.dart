import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:internet_lock/helpers/defines.dart';
import 'package:internet_lock/helpers/helpers.dart';

class AddWebsite extends StatefulWidget {
  AddWebsite({Key key}) : super(key: key);
  @override
  _AddWebsiteState createState() => _AddWebsiteState();
}

class _AddWebsiteState extends State<AddWebsite> {
// Properties

  // Website url
  String _websiteUrl;
  // Website title
  String _websiteTitle;
  // Webview instance
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

// Methods

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
        label: Text('Add site',
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
        onPressed: _advancedOptions));
    return results;
  }

  // Validate and save new website
  void _addSite() async {
    // Check for empty site
    if (_websiteUrl.isEmpty) {
      Helpers.displayAlert(
        context,
        "Error",
        "please wait until your selected site is loaded, then click this button.",
      );
    } else if (Helpers.isSearchUriMatch(_websiteUrl)) {
      // Do not save url if its a search result
      Helpers.displayAlert(
        context,
        "Error",
        "please click the search result link you want and select the site after its loaded.",
      );
    } else {
      // Save new sites
      var bOK = await _saveSite();
      if (!bOK) {
        // TODO change to manual entry page

      }
    }
  }

  // Cancel adding new website
  void _cancel() {
    Navigator.of(context).pop();
  }

  // Show advances options page
  void _advancedOptions() {}

  // Listen for url changed event
  void onUrlChanged(String url) async {
    _websiteUrl = url;
    // Find page title
    _websiteTitle =
        await flutterWebviewPlugin.evalJavascript("window.document.title");
  }

  _saveSite() async {}
}
