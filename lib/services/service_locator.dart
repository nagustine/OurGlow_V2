import 'auth_service.dart';
import 'firestore_service.dart';
import 'storage_service.dart';
import 'ingredient_repository.dart';

class ServiceLocator {
  ServiceLocator._();

  static final AuthService auth = AuthService();
  static final FirestoreService firestore = FirestoreService();
  static final StorageService storage = StorageService();
  static final IngredientRepository ingredients = IngredientRepository();
}