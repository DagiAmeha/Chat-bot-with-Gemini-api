import 'package:chat_bot/providers/chat_provider.dart';
import 'package:chat_bot/screens/chat_history_screen.dart';
import 'package:chat_bot/screens/chat_screen.dart';
import 'package:chat_bot/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // list of screens
  final List<Widget> _screens = [
    const ChatHistoryScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
          body: PageView(
            controller: chatProvider.pageController,
            onPageChanged: (index) {
              chatProvider.setCurrentIndex(index);
            },
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: chatProvider.currentIndex,
            elevation: 0,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            onTap: (index) {
              chatProvider.setCurrentIndex(index);
              chatProvider.pageController.jumpToPage(index);
            },

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
