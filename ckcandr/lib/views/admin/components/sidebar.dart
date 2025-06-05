import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/providers/user_provider.dart';

class AdminSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final bool isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      width: isSmallScreen ? null : 250,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      child: Column(
        children: [
          // User info header
          if (isSmallScreen)
            UserAccountsDrawerHeader(
              accountName: Text(currentUser?.hoVaTen ?? 'Administrator'),
              accountEmail: Text(currentUser?.email ?? 'admin@ckcquiz.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: theme.primaryColor.withOpacity(0.8),
                child: Text(
                  currentUser?.hoVaTen.isNotEmpty == true 
                      ? currentUser!.hoVaTen[0].toUpperCase() 
                      : 'A',
                  style: const TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: theme.primaryColor,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.primaryColor.withOpacity(0.8),
                    child: Text(
                      currentUser?.hoVaTen.isNotEmpty == true 
                          ? currentUser!.hoVaTen[0].toUpperCase() 
                          : 'A',
                      style: const TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentUser?.hoVaTen ?? 'Administrator',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    currentUser?.email ?? 'admin@ckcquiz.com',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Quản trị viên',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  index: 0,
                  title: 'Tổng quan',
                  icon: Icons.dashboard,
                  selected: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                ),
                _buildMenuItem(
                  context,
                  index: 1,
                  title: 'Người dùng',
                  icon: Icons.people,
                  selected: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                ),
                _buildMenuItem(
                  context,
                  index: 2,
                  title: 'Môn học',
                  icon: Icons.book,
                  selected: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                ),
                
                Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'HỆ THỐNG',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Cài đặt'),
                  onTap: () {
                    // TODO: Navigate to settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Trợ giúp'),
                  onTap: () {
                    // TODO: Navigate to help
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required int index,
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: selected 
            ? theme.primaryColor.withOpacity(isDarkMode ? 0.2 : 0.1)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? theme.primaryColor : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? theme.primaryColor : null,
          ),
        ),
        selected: selected,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
} 