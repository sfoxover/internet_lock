// Handle lock state of app in singleton class
import 'package:internet_lock/models/user.dart';

class LockManager {
  // Singleton object
  static final LockManager _singleton = new LockManager._internal();
  LockManager._internal();
  static LockManager get instance => _singleton;

  // Logged in user
  User loggedInUser;
}
