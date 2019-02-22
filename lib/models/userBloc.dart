import 'dart:async';

import 'package:internet_lock/models/user.dart';
import 'package:internet_lock/models/userDbProvider.dart';

class UserBloc {
  UserBloc._();

  static final UserBloc instance = UserBloc._();

  final _clientController = StreamController<List<User>>.broadcast();

  final _dbProvider = new UserDBProvider();

  get users => _clientController.stream;

  dispose() {
    _clientController.close();
  }

  getUsers() async {
    _clientController.sink.add(await _dbProvider.getAll());
  }

  UserBloc() {
    getUsers();
  }

  add(User item) async {
    await _dbProvider.add(item);
    await getUsers();
  }

  edit(User item) async {
    await _dbProvider.update(item);
    await getUsers();
  }

  delete(int id) async {
    await _dbProvider.delete(id);
    await getUsers();
  }
}
