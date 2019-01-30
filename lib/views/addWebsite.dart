import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddWebsite extends StatefulWidget {
  AddWebsite({Key key}) : super(key: key);
  @override
  _AddWebsiteState createState() => _AddWebsiteState();
}

class _AddWebsiteState extends State<AddWebsite> {

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Add new website'),
        actions: _getAppBarButtons(),
      ),
     body: 
     WebView(
        initialUrl: 'https://www.bing.com/',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
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
        label:
            Text('Save', style: TextStyle(color: Colors.white, fontSize: 16.0)),
        onPressed: _save));
    // Cancel button
    results.add(RaisedButton.icon(
        icon: const Icon(Icons.cancel, size: 18.0, color: Colors.white),
        color: Theme.of(context).primaryColor,
        label: Text('Cancel',
            style: TextStyle(color: Colors.white, fontSize: 16.0)),
        onPressed: _cancel));

    return results;
  }

// Validate and save new website
  void _save() {}

// Cancel adding new website
  void _cancel() {
    Navigator.of(context).pop();
  }
}
