import 'package:chat_bot/constants.dart';
import 'package:chat_bot/hive/boxes.dart';
import 'package:chat_bot/hive/settings.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _shouldSpeak = false;

  bool get isDarkMode => _isDarkMode;
  bool get shouldSpeak => _shouldSpeak;

  void getSavedSettings() {
    final settingsBox = Boxes.getSettings();

    if (settingsBox.isNotEmpty) {
      final setting = settingsBox.getAt(0);
      _isDarkMode = setting!.isDarkMode;
      _shouldSpeak = setting.shouldSpeak;
    }
  }

  void toggleDarkMode({required bool value, Settings? settings}) {
    if (settings != null) {
      settings.isDarkMode = value;
      settings.save();
    } else {
      final settingsBox = Boxes.getSettings();

      settingsBox.put(0, Settings(isDarkMode: value, shouldSpeak: shouldSpeak));
    }

    _isDarkMode = value;
    notifyListeners();
  }

  void toggleSpeak({required bool value, Settings? settings}) {
    if (settings != null) {
      settings.isDarkMode = value;
      settings.save();
    } else {
      final settingsBox = Boxes.getSettings();

      settingsBox.put(0, Settings(isDarkMode: value, shouldSpeak: shouldSpeak));
    }

    _isDarkMode = value;
    notifyListeners();
  }
}
