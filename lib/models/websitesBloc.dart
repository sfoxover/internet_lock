import 'dart:async';

import 'package:internet_lock/models/website.dart';
import 'package:internet_lock/models/websiteDbProvider.dart';

class WebsitesBloc {
  WebsitesBloc._();

  static final WebsitesBloc instance = WebsitesBloc._();
  final _clientController = StreamController<List<Website>>.broadcast();
  final _dbProvider = new WebsiteDBProvider();
  get websites => _clientController.stream;

  // Empty website list flag
  bool _hasWebsites = false;
  get hasWebSites => _hasWebsites;

  dispose() {
    _clientController.close();
  }

  getWebsites() async {
    var sites = await _dbProvider.getAllWebsites();
    _hasWebsites = sites != null && sites.isNotEmpty;
    _clientController.sink.add(sites);
  }

  WebsitesBloc() {
    getWebsites();
  }

  add(Website item) async {
    await _dbProvider.addWebsite(item);
    await getWebsites();
  }

  edit(Website item) async {
    await _dbProvider.updateWebsite(item);
    await getWebsites();
  }

  delete(int id) async {
    await _dbProvider.deleteWebsite(id);
    await getWebsites();
  }
}
