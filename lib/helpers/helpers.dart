// Static helper methods
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:internet_lock/helpers/defines.dart';

class Helpers {
  // Test if url matches search domain
  static isSearchUriMatch(String url) {
    var search = Uri.parse(Defines.SEARCH_URL);
    var uri = Uri.parse(url);
    if (search.host == uri.host)
      return true;
    else
      return false;
  }

  // Display alert message snackbar
  static displayAlert(GlobalKey viewKey, double appbarHeight, String message) {
    try {
      GlobalKey _snack = new GlobalKey();
      final _browser = new FlutterWebviewPlugin();
      final snackBar = SnackBar(
        duration: Duration(seconds: 20),
        content: Text(
          message,
          textAlign: TextAlign.center,
          key: _snack,
        ),
        backgroundColor: Theme.of(viewKey.currentContext).primaryColor,
      );
      Scaffold.of(viewKey.currentContext).showSnackBar(snackBar);
      // Shrink browser height
      double normalHeight = viewKey.currentContext.size.height;
      _browser.resize(Rect.fromLTRB(
          0,
          appbarHeight,
          viewKey.currentContext.size.width,
          viewKey.currentContext.size.height - 50));
      Future.delayed(const Duration(seconds: 20), () {
        final scaffold = Scaffold.of(viewKey.currentContext);
        scaffold.hideCurrentSnackBar();
        // Restore browser size
        _browser.resize(Rect.fromLTRB(
            0, appbarHeight, viewKey.currentContext.size.width, normalHeight));
      });
    } catch (e) {
      print("Exception in Helpers::displayAlert, ${e.toString()}");
    }
  }

  // Test for empty string
  static isNullOrEmpty(String value) {
    try {
      if (value == null || value.isEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {}
    return true;
  }

  // Test if app is pinned
  static Future<bool> checkIfAppPinned() async {
    bool pinned = false;
    try {
      final platform = const MethodChannel('com.sfoxover.internetlock/lockapp');
      var result = await platform.invokeMethod("getLockedStatus");
      if (result == "locked") {
        pinned = true;
      }
    } catch (e) {
      print("Exception in helpers::_checkIfAppPinned, ${e.toString()}");
    }
    return pinned;
  }

  // Get device name
  static String getDeviceName() {
    String name = "Tablet";
    if (!Device.get().isTablet) {
      name = "Phone";
    }
    return name;
  }

  // Check if android device
  static bool getIsAndroidDevice() {
    return Device.get().isAndroid;
  }
}
