import '../Domain/models/user.dart';
import '../Data/repositories/user_repository.dart';

class UserService {
  final UserRepository userRepository = UserRepository();
  List<User> users = [];
  User? currentUser;

  UserService() {
    users = userRepository.loadAll();
  }

  void login(String email, String password) {
    try {
      for (int i = 0; i < users.length; i++) {
        if (users[i].getEmail() == email && users[i].getPassword() == password) {
          currentUser = users[i];
          return;
        }
      }
      throw Exception('Invalid email or password');
    } catch (e) {
      rethrow;
    }
  }

  void logout() {
    try {
      if (currentUser != null) {
        currentUser = null;
        return;
      }
      throw Exception('No user is currently logged in');
    } catch (e) {
      rethrow;
    }
  }

  User? getCurrentUser() {
    return currentUser;
  }
}
