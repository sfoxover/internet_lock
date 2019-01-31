import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

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
      url: 'https://www.bing.com/',
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
        onPressed: _save));
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
  void _save() {}

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
}
