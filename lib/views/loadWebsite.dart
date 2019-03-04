import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:internet_lock/models/website.dart';
import 'package:internet_lock/widgets/iconButtonHelper.dart';

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
    results.add(IconButtonHelper.createRaisedButton(
        "Home", Icons.home, context, _loadHomePage));
    // Back button
    results.add(IconButtonHelper.createRaisedButton(
        "Back", Icons.arrow_back, context, _goBack));
    // Forward button
    results.add(IconButtonHelper.createRaisedButtonRightIcon(
        "Forward", Icons.arrow_forward, context, _goForward));
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
