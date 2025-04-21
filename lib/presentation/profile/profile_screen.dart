import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/data/api/services/user_service.dart';

class MenuItem {
  final String text;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  MenuItem({
    required this.text,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.trailing,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  bool _isLoadingProfile = true;
  String _userName = '';
  String _userMobile = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final name = await UserProfileService.getUserName();
      final mobile = await UserProfileService.getUserMobileNumber();
      final email = await UserProfileService.getUserEmail();

      setState(() {
        _userName = name ?? 'User';
        _userMobile = mobile ?? '';
        _userEmail = email ?? '';
        _isLoadingProfile = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    final response = await AuthService.logout();

    setState(() {
      _isLoading = false;
    });

    if (response['success']) {
      // Navigate to login screen on successful logout
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.loginPage);
      }
    } else {
      // Show error if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Logout failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create menu items with the MenuItem class
    final List<MenuItem> menuItems = [
      MenuItem(
        text: 'প্রোফাইল এডিট করুন',
        icon: Icons.edit_note,
        iconColor: Colors.blue,
        onTap: () {
          // Handle edit profile
        },
      ),
      MenuItem(
        text: 'সেটিংস',
        icon: Icons.settings,
        iconColor: Colors.blue,
        onTap: () {
          // Handle settings
        },
      ),
      MenuItem(
        text: 'সাহায্য',
        icon: Icons.help_outline,
        iconColor: Colors.blue,
        onTap: () {
          // Handle help
        },
      ),
      MenuItem(
        text: 'লগ আউট',
        icon: Icons.logout,
        iconColor: Colors.blue,
        onTap: _isLoading ? null : _logout,
        trailing:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                )
                : Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey[400],
                ),
      ),
    ];

    return Scaffold(
      appBar: CustomAppBar("ব্যক্তিগত তথ্য"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header with user info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFECF2F9),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child:
                    _isLoadingProfile
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                          children: [
                            // Profile image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 15),
                            // User details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _userMobile,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (_userEmail.isNotEmpty) ...[
                                    const SizedBox(height: 5),
                                    Text(
                                      _userEmail,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
              ),

              const SizedBox(height: 10),

              // Menu items
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    // Build menu items from the list
                    for (int i = 0; i < menuItems.length; i++) ...[
                      _buildMenuItem(menuItems[i]),
                      // Add divider except after the last item
                      if (i < menuItems.length - 1) _buildDivider(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            // Icon with background
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: item.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 22),
            ),
            const SizedBox(width: 15),
            // Menu text
            Text(
              item.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const Spacer(),
            // Custom trailing widget or default arrow icon
            item.trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Colors.grey[400],
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, indent: 20, endIndent: 20);
  }
}
