import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:internet_lock/helpers/defines.dart';
import 'package:internet_lock/helpers/helpers.dart';
import 'package:internet_lock/models/website.dart';
import 'package:internet_lock/models/websitesBloc.dart';
import 'package:internet_lock/views/addWebsiteAdvanced.dart';
import 'package:internet_lock/widgets/iconButtonHelper.dart';

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
  // Webview single instance
  final _browser = new FlutterWebviewPlugin();
  // Widget identifiers
  GlobalKey _appBarKey = GlobalKey();
  GlobalKey _mainViewKey = GlobalKey();

  // Constructor
  _AddWebsiteState() {
    // Listen for url changed event
    _browser.onUrlChanged.listen(onUrlChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _browser.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          key: _appBarKey,
          title: new Text("Search and add website"),
          actions: _getAppBarButtons(),
        ),
        body: Container(
            key: _mainViewKey,
            child: WebviewScaffold(
              url: Defines.SEARCH_URL,
              initialChild: Container(
                child: const Center(
                  child: Text('Loading.....'),
                ),
              ),
            )));
  }

  // Display AppBar buttons dependent on admin logged in
  _getAppBarButtons() {
    List<Widget> results = [];
    // Save button
    results.add(IconButtonHelper.createRaisedButton(
        "Save site", Icons.save_alt, context, _addSite));
    // Cancel button
    results.add(IconButtonHelper.createRaisedButton(
        "Cancel", Icons.cancel, context, _cancel));
    // Show advanced button
    results.add(IconButtonHelper.createRaisedButton(
        "Advanced", Icons.settings, context, _showAdvancedPage));
    return results;
  }

  // Verify user input is valid
  bool _validateUserInput() {
    var bOK = false;
    // Check for empty site
    if (Helpers.isNullOrEmpty(_websiteUrl)) {
      Helpers.displayAlert(
        _mainViewKey,
        _appBarKey.currentContext.size.height,
        "Error, please wait until your selected site is loaded, then click this button.",
      );
    } else if (Helpers.isSearchUriMatch(_websiteUrl)) {
      // Do not save url if its a search result
      Helpers.displayAlert(
        _mainViewKey,
        _appBarKey.currentContext.size.height,
        "Error, please click the search result link you want and select the site after its loaded.",
      );
    } else if (Helpers.isNullOrEmpty(_websiteTitle)) {
      // Do not save if no title was loaded
      Helpers.displayAlert(
        _mainViewKey,
        _appBarKey.currentContext.size.height,
        "Error, please to load title from the selected website. Please type in the title of the website manually.",
      );
      _showAdvancedPage();
    } else {
      bOK = true;
    }
    return bOK;
  }

  // Validate and save new website
  void _addSite() async {
    try {
      if (_validateUserInput()) {
        // Save to database
        Website site = new Website(title: _websiteTitle, startUrl: _websiteUrl);
        WebsitesBloc.instance.add(site);
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
      }
    } catch (e) {
      print("Exception in _AddWebsiteState::_addSite, ${e.toString()}");
    }
  }

  // Show advanced settings page
  void _showAdvancedPage() {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddWebsiteAdvanced(
              website:
                  new Website(startUrl: _websiteUrl, title: _websiteTitle))),
    );
  }

  // Cancel adding new website
  void _cancel() {
    Navigator.of(context).pop();
  }

  // Listen for url changed event
  void onUrlChanged(String url) async {
    try {
      _websiteUrl = url;
      // Find page title
      _websiteTitle = await _browser.evalJavascript("window.document.title");
      _websiteTitle = _websiteTitle.replaceAll('"', '');
    } catch (e) {
      print("Exception in _AddWebsiteState::onUrlChanged, ${e.toString()}");
    }
  }
}
