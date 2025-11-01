import 'package:uuid/uuid.dart';

class UuidHelper {
  static final Uuid _uuid = Uuid();

  static String generateUuid() {
    return _uuid.v4();
  }
}
