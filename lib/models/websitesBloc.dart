import 'dart:async';

import 'package:internet_lock/models/website.dart';
import 'package:internet_lock/models/websiteDbProvider.dart';

class WebsitesBloc {
  WebsitesBloc._();
  static final WebsitesBloc instance = WebsitesBloc._();

  final _clientController = StreamController<List<Website>>.broadcast();

  get websites => _clientController.stream;

  dispose() {
    _clientController.close();
  }

  getWebsites() async {
    _clientController.sink.add(await WebsiteDBProvider.instance.getAllWebsites());
  }

  WebsitesBloc() {
    getWebsites();
  }

  delete(int id) {
    WebsiteDBProvider.instance.deleteClient(id);
    getWebsites();
  }

  add(Website item) {
    WebsiteDBProvider.instance.addWebsite(item);
    getWebsites();
  }
}
