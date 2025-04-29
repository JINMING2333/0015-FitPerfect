import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  Set<String> _favorites = {};
  final String _prefsKey = 'favorites';

  Set<String> get favorites => _favorites;

  FavoritesService() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedFavorites = prefs.getStringList(_prefsKey) ?? [];
    _favorites = Set<String>.from(savedFavorites);
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _favorites.toList());
  }

  void toggleFavorite(String exerciseId) {
    if (_favorites.contains(exerciseId)) {
      _favorites.remove(exerciseId);
    } else {
      _favorites.add(exerciseId);
    }
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String exerciseId) {
    return _favorites.contains(exerciseId);
  }
} 