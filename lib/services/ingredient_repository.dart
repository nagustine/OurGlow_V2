import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/ingredient.dart';
import '../models/enums.dart';

class IngredientRepository {
  List<Ingredient> _ingredients = [];
  bool _loaded = false;

  List<Ingredient> get all => _ingredients;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('lib/data/ingredients.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final list = (data['ingredients'] as List)
        .map((e) => Ingredient.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    _ingredients = list;
    _loaded = true;
  }

  Ingredient? findById(String id) {
    for (final i in _ingredients) {
      if (i.id == id) return i;
    }
    return null;
  }

  List<Ingredient> matchText(String input) {
    final cleaned = input.toLowerCase();
    final tokens = cleaned
        .split(RegExp(r'[,;\n\r]+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final found = <String, Ingredient>{};

    for (final ingredient in _ingredients) {
      for (final alias in ingredient.aliases) {
        final a = alias.toLowerCase().trim();
        if (a.isEmpty) continue;

        if (tokens.any((t) => t == a)) {
          found[ingredient.id] = ingredient;
          break;
        }
      }
    }

    for (final ingredient in _ingredients) {
      for (final alias in ingredient.aliases) {
        final a = alias.toLowerCase().trim();
        if (a.length < 4) continue;

        if (cleaned.contains(a)) {
          found.putIfAbsent(ingredient.id, () => ingredient);
        }
      }
    }

    return found.values.toList();
  }

  List<ConflictResult> checkConflicts(List<String> ingredientIds) {
    final results = <ConflictResult>[];
    final ids = ingredientIds.toSet().toList();

    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        final a = findById(ids[i]);
        final b = findById(ids[j]);
        if (a == null || b == null) continue;

        final aConflictsB = a.conflicts.contains(b.id);
        final bConflictsA = b.conflicts.contains(a.id);

        if (aConflictsB || bConflictsA) {
          results.add(ConflictResult(
            ingredientA: a,
            ingredientB: b,
            severity: _severity(a, b),
          ));
        }
      }
    }

    return results;
  }

  StatusAman _severity(Ingredient a, Ingredient b) {
    final hardA = a.kategori == KategoriBahan.active ||
        a.kategori == KategoriBahan.exfoliant ||
        a.kategori == KategoriBahan.acneTreatment;
    final hardB = b.kategori == KategoriBahan.active ||
        b.kategori == KategoriBahan.exfoliant ||
        b.kategori == KategoriBahan.acneTreatment;

    if (hardA && hardB) return StatusAman.bentrok;
    return StatusAman.perluPerhatian;
  }
}

class ConflictResult {
  final Ingredient ingredientA;
  final Ingredient ingredientB;
  final StatusAman severity;

  const ConflictResult({
    required this.ingredientA,
    required this.ingredientB,
    required this.severity,
  });

  String get summary => '${ingredientA.name} + ${ingredientB.name}';
}