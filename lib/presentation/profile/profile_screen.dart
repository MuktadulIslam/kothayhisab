import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/bangla_language.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(BanglaLanguage.profile),
      body: const Center(
        child: Text('User Profile Screen', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
