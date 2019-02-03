import 'dart:async';

import 'package:internet_lock/models/website.dart';
import 'package:internet_lock/models/websiteDbProvider.dart';

class WebsitesBloc {
  final _clientController = StreamController<List<Website>>.broadcast();

  get websites => _clientController.stream;

  dispose() {
    _clientController.close();
  }

  getWebsites() async {
    _clientController.sink.add(await WebsiteDBProvider.db.getAllWebsites());
  }

  WebsitesBloc() {
    getWebsites();
  }

  delete(int id) {
    WebsiteDBProvider.db.deleteClient(id);
    getWebsites();
  }

  add(Website item) {
    WebsiteDBProvider.db.addWebsite(item);
    getWebsites();
  }
}
