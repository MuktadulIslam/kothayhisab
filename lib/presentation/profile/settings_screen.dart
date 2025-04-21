import 'package:flutter/material.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('প্রোফাইল সেটিংস'),
      body: const Center(
        child: Text('Settings Screen', style: TextStyle(fontSize: 20)),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
