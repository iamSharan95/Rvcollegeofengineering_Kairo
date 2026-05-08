import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceProvider with ChangeNotifier {
  List<String> _interests = ['Flutter', 'AI', 'Open Source', 'Dart'];
  final String _storageKey = 'kairo_interests';

  List<String> get interests => _interests;

  PreferenceProvider() {
    _loadInterests();
  }

  Future<void> _loadInterests() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedInterests = prefs.getStringList(_storageKey);
    if (storedInterests != null) {
      _interests = storedInterests;
      notifyListeners();
    }
  }

  Future<void> addInterest(String interest) async {
    if (!_interests.contains(interest)) {
      _interests.add(interest);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _interests);
      notifyListeners();
    }
  }

  Future<void> removeInterest(String interest) async {
    if (_interests.contains(interest)) {
      _interests.remove(interest);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _interests);
      notifyListeners();
    }
  }
}
