// Handle lock state of app in singleton class
class LockManager{
  // Singleton object
  static final LockManager _singleton = new LockManager._internal();
  LockManager._internal();
  static LockManager get instance => _singleton;

   // Is parent logged in
  bool adminLoggedIn = false;
}