import 'package:my_wallet/data/data.dart';
import 'package:my_wallet/data/local/database_manager.dart' as db;
import 'package:my_wallet/ui/budget/category/domain/create_category_exception.dart';
import 'dart:math';
import 'package:my_wallet/data/firebase/database.dart' as fm;
import 'package:my_wallet/ca/data/ca_repository.dart';

export 'package:my_wallet/data/data.dart';

class CreateCategoryRepository extends CleanArchitectureRepository {
  final _CreateCategoryDatabaseRepository _dbRepo = _CreateCategoryDatabaseRepository();
  final _CreateCategoryFirebaseRepository _fbRepo = _CreateCategoryFirebaseRepository();

  Future<AppCategory> loadCategory(int id) {
    return _dbRepo.loadCategory(id);
  }

  Future<int> generateId() {
    return _dbRepo.generateId();
  }

  Future<String> generateRandomColor() {
    return _dbRepo._generateRandomColor();
  }

  Future<bool> saveCategory(int id, String name, String color, CategoryType type, int group) {
    _fbRepo.saveCategory(id, name, color, type, group);

    return _dbRepo.saveCategory(id, name, color, type, group);
  }

  Future<bool> updateCategory(int id, String name, String colorHex, CategoryType type, int group) {
    _fbRepo.updateCategory(id, name, colorHex, type, group);

    return _dbRepo.updateCategory(id, name, colorHex, type, group);
  }

  Future<bool> validateName(String name) async {
    return _dbRepo.validateName(name);
  }
}

class _CreateCategoryDatabaseRepository {

  Future<AppCategory> loadCategory(int id) async {
    var categoryList = await db.queryCategory(id: id);

    return categoryList == null || categoryList.isEmpty ? null : categoryList.first;
  }

  Future<bool> validateName(String name) async {
    return name == null || name.isEmpty ? throw CreateCategoryException("Please enter Category name") : true;
  }

  Future<int> generateId() {
    return db.generateCategoryId();
  }

  Future<String> _generateRandomColor() async {
    Random rnd = Random();
    var hex = "0123456789abcd";

    var color = "#";
    for(int i = 0; i < 6; i++) {
      color += String.fromCharCode(hex.codeUnitAt(rnd.nextInt(hex.length)));
    }

    return color;
  }

  Future<bool> saveCategory(int id, String name, String color, CategoryType categoryType, int group) async {
    db.insertCategory(AppCategory(id, name, color, categoryType, group: group));

    return true;
  }

  Future<bool> updateCategory(int id, String name, String colorHex, CategoryType type, int group) async {
    db.updateCategory(AppCategory(id, name, colorHex, type, group: group));

    return true;
  }
}

class _CreateCategoryFirebaseRepository {
  Future<bool> saveCategory(int id, String name, String color, CategoryType categoryType, int group) {
    return fm.addCategory(AppCategory(id, name, color, categoryType, group: group));
  }

  Future<bool> updateCategory(int id, String name, String colorHex, CategoryType type, int group) {
    return fm.updateCategory(AppCategory(id, name, colorHex, type, group: group));
  }
}
