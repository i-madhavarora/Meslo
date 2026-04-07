import 'package:hive/hive.dart';
import '../models/user_model.dart';

class UserService {
  static const boxName = "userBox";
  static const key = "user";

  Future<void> saveUser(UserModel user) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, {
      "userId": user.userId,
      "name": user.name,
      "username": user.username,
    });
  }

  Future<UserModel?> getUser() async {
    final box = await Hive.openBox(boxName);
    final data = box.get(key);

    if (data == null) return null;

    return UserModel(
      userId: data["userId"],
      name: data["name"],
      username: data["username"],
    );
  }
}