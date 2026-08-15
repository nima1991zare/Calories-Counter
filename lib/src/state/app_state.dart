import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/nutrients.dart';
import '../models/profile.dart';

/// Global app state: user profile, onboarding status and derived targets.
class AppState extends ChangeNotifier {
  static const _profileKey = 'user_profile';

  UserProfile _profile = const UserProfile();
  bool _onboarded = false;
  bool _loaded = false;

  UserProfile get profile => _profile;
  bool get onboarded => _onboarded;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw != null) {
      try {
        _profile = UserProfile.fromJsonString(raw);
        _onboarded = true;
      } catch (_) {
        _onboarded = false;
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    _onboarded = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, profile.toJsonString());
  }

  /// Daily targets for every tracked nutrient.
  Map<String, double> get nutrientTargets {
    final targets = Nutrients.rdaTargets(male: _profile.sex == Sex.male);
    targets[Nutrients.kcal] = _profile.kcalTarget;
    targets[Nutrients.protein] = _profile.proteinTargetG;
    targets[Nutrients.carbs] = _profile.carbsTargetG;
    targets[Nutrients.fat] = _profile.fatTargetG;
    return targets;
  }
}
