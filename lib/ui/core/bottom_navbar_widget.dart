import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavbarWidget extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavbarWidget({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra route hiện tại để ẩn bottom navigation bar khi ở cart
    final currentLocation = GoRouterState.of(context).uri.path;
    final isCartScreen = currentLocation == '/cart';
    
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Trang chủ",
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: "Tin nhắn",
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: "Lịch sử",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Hồ sơ",
          ),
      
              
               
                NavigationDestination(
                  icon: Icon(Icons.shopping_cart_outlined),
                  selectedIcon: Icon(Icons.shopping_cart),
                  label: "Giỏ hàng",
                ),
              ],
            ),
    );
  }
}
