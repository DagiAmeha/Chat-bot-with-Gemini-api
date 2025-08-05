import 'dart:io';
import 'dart:developer' as dev;

import 'package:chat_bot/hive/boxes.dart';
import 'package:chat_bot/hive/settings.dart';
import 'package:chat_bot/providers/settings_provider.dart';
import 'package:chat_bot/widget/build_display_image.dart';
import 'package:chat_bot/widget/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? file;
  String userName = 'Dexter';
  String userImage = '';
  final ImagePicker _picker = ImagePicker();

  void pickImage() async {
    try {
      final pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 95,
      );
      if (pickedImage != null) {
        setState(() {
          file = File(pickedImage.path);
        });
      }
    } catch (error) {
      dev.log('Error picking image: $error');
    }
  }

  // get user data
  void getUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // get user data from box
      final userBox = Boxes.getUser();

      if (userBox.isNotEmpty) {
        final user = userBox.getAt(0);
        setState(() {
          userImage = user!.image;
          userName = user.name;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.check))],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: BuildDisplayImage(
                  file: file,
                  userImage: userImage,
                  onPressed: () {
                    pickImage();
                  },
                ),
              ),

              const SizedBox(height: 20.0),

              Text(userName, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 40.0),

              ValueListenableBuilder<Box<Settings>>(
                valueListenable: Boxes.getSettings().listenable(),
                builder: (context, box, child) {
                  if (box.isEmpty) {
                    return Column(
                      children: [
                        SettingsTile(
                          icon: Icons.mic,
                          title: 'Enable AI voice',
                          value: false,
                          onChanged: (value) {
                            final settingsProvider = context
                                .read<SettingsProvider>();
                            settingsProvider.toggleSpeak(value: value);
                          },
                        ),
                        const SizedBox(height: 10.0),

                        SettingsTile(
                          icon: Icons.light_mode,
                          title: 'Enable AI voice',
                          value: false,
                          onChanged: (value) {
                            final settingsProvider = context
                                .read<SettingsProvider>();
                            settingsProvider.toggleDarkMode(value: value);
                          },
                        ),
                      ],
                    );
                  } else {
                    final settings = box.getAt(0);
                    return Column(
                      children: [
                        SettingsTile(
                          icon: Icons.mic,
                          title: 'Enable AI voice',
                          value: settings!.shouldSpeak,
                          onChanged: (value) {
                            final settingsProvider = context
                                .read<SettingsProvider>();
                            settingsProvider.toggleSpeak(value: value);
                          },
                        ),
                        const SizedBox(height: 10.0),
                        SettingsTile(
                          icon: settings.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          title: 'Theme',
                          value: settings.isDarkMode,
                          onChanged: (value) {
                            final settingsProvider = context
                                .read<SettingsProvider>();
                            settingsProvider.toggleDarkMode(value: value);
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
