import 'dart:async';

import 'package:internet_lock/models/website.dart';
import 'package:internet_lock/models/websiteDbProvider.dart';

class WebsitesBloc {
  WebsitesBloc._();

  static final WebsitesBloc instance = WebsitesBloc._();

  final _clientController = StreamController<List<Website>>.broadcast();

  final _dbProvider = new WebsiteDBProvider();

  get websites => _clientController.stream;

  dispose() {
    _clientController.close();
  }

  getWebsites() async {
    _clientController.sink.add(await _dbProvider.getAllWebsites());
  }

  WebsitesBloc() {
    getWebsites();
  }

  delete(int id) {
    _dbProvider.deleteClient(id);
    getWebsites();
  }

  add(Website item) {
    _dbProvider.addWebsite(item);
    getWebsites();
  }
}
