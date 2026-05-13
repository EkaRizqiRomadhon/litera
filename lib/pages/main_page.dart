import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/navigation_controller.dart';
import '../widgets/profile_avatar.dart';
import 'dashboard_page.dart';
import 'explore_page.dart';
import 'library_page.dart';
import 'profile_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List halaman yang akan ditampilkan
    final List<Widget> pages = const [
      DashboardPage(),
      ExplorePage(),
      LibraryPage(),
      ProfilePage(),
    ];

    return Consumer<NavigationController>(
      builder: (context, navControl, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Litera',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF2D5A41),
            foregroundColor: Colors.white,
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: SmallProfileAvatar(radius: 16),
              ),
            ],
          ),
          body: pages[navControl.selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navControl.selectedIndex,
            onTap: (index) => navControl.setIndex(index),
            selectedItemColor: const Color(0xFF2D5A41),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Beranda',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Eksplor',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.library_books),
                label: 'Koleksi',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: navControl.selectedIndex == 3
                        ? Border.all(color: const Color(0xFF2D5A41), width: 2)
                        : null,
                  ),
                  child: const SmallProfileAvatar(radius: 12),
                ),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
