import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PreferencesProvider extends ChangeNotifier {
  static const _boxName = 'preferences';

  static const _keyContentTypes = 'selectedContentTypes';
  static const _keyGenres = 'selectedGenres';
  static const _keyDarkMode = 'isDarkMode';
  static const _keyOnboarding = 'hasCompletedOnboarding';

  late Box _box;

  List<String> _selectedContentTypes = [];
  List<String> _selectedGenres = [];
  bool _isDarkMode = true;
  bool _hasCompletedOnboarding = false;

  List<String> get selectedContentTypes => _selectedContentTypes;
  List<String> get selectedGenres => _selectedGenres;
  bool get isDarkMode => _isDarkMode;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  Future<void> loadPreferences() async {
    _box = await Hive.openBox(_boxName);
    _selectedContentTypes =
        (_box.get(_keyContentTypes, defaultValue: <String>[]) as List)
            .cast<String>();
    _selectedGenres = (_box.get(_keyGenres, defaultValue: <String>[]) as List)
        .cast<String>();
    _isDarkMode = _box.get(_keyDarkMode, defaultValue: true) as bool;
    _hasCompletedOnboarding =
        _box.get(_keyOnboarding, defaultValue: false) as bool;
    notifyListeners();
  }

  void toggleContentType(String type) {
    if (_selectedContentTypes.contains(type)) {
      _selectedContentTypes.remove(type);
    } else {
      _selectedContentTypes.add(type);
    }
    _box.put(_keyContentTypes, _selectedContentTypes);
    notifyListeners();
  }

  void setContentTypeSelected(
    String type,
    bool selected, {
    List<String> removedGenres = const [],
  }) {
    final isSelected = _selectedContentTypes.contains(type);
    if (selected == isSelected) return;

    if (selected) {
      _selectedContentTypes.add(type);
    } else {
      _selectedContentTypes.remove(type);
      _selectedGenres.removeWhere(removedGenres.contains);
    }

    _box.put(_keyContentTypes, _selectedContentTypes);
    _box.put(_keyGenres, _selectedGenres);
    notifyListeners();
  }

  void toggleGenre(String genre) {
    if (_selectedGenres.contains(genre)) {
      _selectedGenres.remove(genre);
    } else {
      _selectedGenres.add(genre);
    }
    _box.put(_keyGenres, _selectedGenres);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    _box.put(_keyDarkMode, value);
    notifyListeners();
  }

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    _box.put(_keyOnboarding, true);
    notifyListeners();
  }

  void resetPreferences() {
    _selectedContentTypes = [];
    _selectedGenres = [];
    _isDarkMode = true;
    _hasCompletedOnboarding = false;
    _box.clear();
    notifyListeners();
  }
}
