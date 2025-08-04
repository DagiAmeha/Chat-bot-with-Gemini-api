import 'package:chat_bot/constants.dart';
import 'package:chat_bot/hive/boxes.dart';

class SettingsProviders {
  bool _isDarkMode = false;
  bool _shouldSpeak = false;

  bool get isDarkMode => _isDarkMode;
  bool get shouldSpeak => _shouldSpeak;

  void getSavedSettings() {
    final settingsBox = Boxes.getSettings();

    // if(settingsBox.isNotEmpty){
    //   final setting
    //   final settings = settingsBox.getAt(Constants.settingsBox)
    // }
  }
}
