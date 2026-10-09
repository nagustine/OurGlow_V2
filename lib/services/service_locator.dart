import 'auth_service.dart';
import 'firestore_service.dart';
import 'storage_service.dart';
import 'ingredient_repository.dart';
import 'diary_service.dart';
import 'scan_service.dart';
import 'routine_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final AuthService auth = AuthService();
  static final FirestoreService firestore = FirestoreService();
  static final StorageService storage = StorageService();
  static final IngredientRepository ingredients = IngredientRepository();
  static final DiaryService diary = DiaryService();
  static final ScanService scan = ScanService();
  static final RoutineService routine = RoutineService();
}