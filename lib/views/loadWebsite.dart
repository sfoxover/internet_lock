import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:internet_lock/models/website.dart';

class LoadWebsite extends StatefulWidget {
  final Website website;

  LoadWebsite({Key key, this.website}) : super(key: key);
  @override
  _LoadWebsiteState createState() => _LoadWebsiteState();
}

class _LoadWebsiteState extends State<LoadWebsite> {
  // Webview single instance
  final _browser = new FlutterWebviewPlugin();

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget.website.startUrl,
      initialChild: Container(
        child: const Center(
          child: Text('Loading.....'),
        ),
      ),
      appBar: new AppBar(
        title: new Text(widget.website.title),
        actions: _getAppBarButtons(),
      ),
    );
  }

  // Display AppBar buttons for browser navigation
  _getAppBarButtons() {
    List<Widget> results = [];
    // Home page button
    results.add(RaisedButton.icon(
        icon: const Icon(Icons.home, size: 18.0, color: Colors.white),
        color: Theme.of(context).primaryColor,
        label:
            Text('Home', style: TextStyle(color: Colors.white, fontSize: 16.0)),
        onPressed: _loadHomePage));
    // Back button
    results.add(RaisedButton.icon(
        icon: const Icon(Icons.arrow_back, size: 18.0, color: Colors.white),
        color: Theme.of(context).primaryColor,
        label:
            Text('Back', style: TextStyle(color: Colors.white, fontSize: 16.0)),
        onPressed: _goBack));
    // Forward button
    results.add(RawMaterialButton(
        fillColor: Theme.of(context).primaryColor,
        textStyle: TextStyle(color: Colors.white, fontSize: 16.0),
        child: Row(
          children: <Widget>[
            Text('Forward'),
            Icon(Icons.arrow_forward, size: 18.0, color: Colors.white)
          ],
        ),
        onPressed: _goForward));
    return results;
  }

  // Reload home page
  void _loadHomePage() {
    _browser.reloadUrl(widget.website.startUrl);
  }

  // Go Back
  _goBack() {
    _browser.goBack();
  }

  // Go forward
  _goForward() {
    _browser.goForward();
  }
}
