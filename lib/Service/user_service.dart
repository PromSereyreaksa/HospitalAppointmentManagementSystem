import '../Domain/models/user.dart';
import '../Data/repositories/user_repository.dart';

class UserService {
  final UserRepository userRepository = UserRepository();
  List<User> users = [];
  User? currentUser;

  UserService() {
    users = userRepository.loadAll();
  }

  bool login(String email, String password) {
    for (int i = 0; i < users.length; i++) {
      if (users[i].getEmail() == email && users[i].getPassword() == password) {
        currentUser = users[i];
        return true;
      }
    }
    return false;
  }

  bool logout() {
    if (currentUser != null) {
      currentUser = null;
      return true;
    }
    return false;
  }

  User? getCurrentUser() {
    return currentUser;
  }
}
