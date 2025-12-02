import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/ui/chat/chat_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';

class BottomNavbarWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Kiểm tra route hiện tại để ẩn bottom navigation bar khi ở cart hoặc payment
    final currentLocation = GoRouterState.of(context).uri.path;
    final isCartScreen = currentLocation == '/cart';
    final isPaymentScreen = currentLocation.startsWith('/payment');
    
    // Lấy tổng số tin nhắn chưa đọc
    final unreadTotalAsync = ref.watch(unreadTotalProvider);
    
    final isDark = ThemeHelper.isDarkMode(context);
    final backgroundColor = ThemeHelper.getCardBackgroundColor(context);
    final selectedColor = ThemeHelper.getPrimaryColor(context);
    final unselectedColor = ThemeHelper.getSecondaryIconColor(context);
    
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: (isCartScreen || isPaymentScreen)
          ? null 
          : Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: ThemeHelper.getShadowColor(context),
                    blurRadius: 20,
                    offset: const Offset(0, -2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _goBranch,
                backgroundColor: backgroundColor,
                elevation: 0,
                height: 70,
                indicatorColor: isDark 
                    ? Colors.blue.shade900.withOpacity(0.3)
                    : Colors.blue.shade50,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                labelTextStyle: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return TextStyle(
                      color: selectedColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    );
                  }
                  return TextStyle(
                    color: unselectedColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  );
                }),
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      Icons.home_outlined,
                      color: unselectedColor,
                      size: 24,
                    ),
                    selectedIcon: Icon(
                      Icons.home_rounded,
                      color: selectedColor,
                      size: 26,
                    ),
                    label: "Trang chủ",
                  ),
                  NavigationDestination(
                    icon: _buildChatIcon(
                      context: context,
                      icon: Icons.chat_bubble_outline,
                      unreadCount: unreadTotalAsync.hasValue ? (unreadTotalAsync.value ?? 0) : 0,
                      isSelected: false,
                      selectedColor: selectedColor,
                      unselectedColor: unselectedColor,
                    ),
                    selectedIcon: _buildChatIcon(
                      context: context,
                      icon: Icons.chat_bubble_rounded,
                      unreadCount: unreadTotalAsync.hasValue ? (unreadTotalAsync.value ?? 0) : 0,
                      isSelected: true,
                      selectedColor: selectedColor,
                      unselectedColor: unselectedColor,
                    ),
                    label: "Tin nhắn",
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.history_outlined,
                      color: unselectedColor,
                      size: 24,
                    ),
                    selectedIcon: Icon(
                      Icons.history_rounded,
                      color: selectedColor,
                      size: 26,
                    ),
                    label: "Lịch sử",
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.person_outline,
                      color: unselectedColor,
                      size: 24,
                    ),
                    selectedIcon: Icon(
                      Icons.person_rounded,
                      color: selectedColor,
                      size: 26,
                    ),
                    label: "Tôi",
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildChatIcon({
    required BuildContext context,
    required IconData icon,
    required int unreadCount,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          icon,
          color: isSelected ? selectedColor : unselectedColor,
          size: isSelected ? 26 : 24,
        ),
        if (unreadCount > 0)
          Positioned(
            right: -4,
            top: -8,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: unreadCount > 9 ? 6 : 5,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ThemeHelper.getCardBackgroundColor(context),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
