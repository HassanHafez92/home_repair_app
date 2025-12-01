import 'package:home_repair_app/models/user_model.dart';
import 'package:home_repair_app/models/technician_model.dart';
import 'package:home_repair_app/models/technician_stats.dart';

abstract class IUserRepository {
  Future<void> createUser(UserModel user);

  Future<UserModel?> getUser(String uid);

  Future<void> updateUser(UserModel user);

  Future<void> updateUserFields(String uid, Map<String, dynamic> fields);

  Stream<List<TechnicianModel>> streamPendingTechnicians();

  Future<void> updateTechnicianStatus(String uid, TechnicianStatus status);

  Future<void> updateTechnicianAvailability(String uid, bool isAvailable);

  Stream<bool> streamTechnicianAvailability(String uid);

  Future<TechnicianStats> getTechnicianStats(String technicianId);

  Stream<TechnicianStats> streamTechnicianStats(String technicianId);
}
