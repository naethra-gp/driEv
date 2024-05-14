import 'package:hive/hive.dart';

import '../app_config/app_constants.dart';

class SecureStorage {
  var box = Hive.box(Constants.storageBox);

  get(key) {
    return box.get(key);
  }

  save(key, value) {
    box.put(key, value);
  }

  saveToken(token) {
    box.put('token', token);
  }
  getToken() {
    return box.get("token");
  }
}
