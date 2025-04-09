import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/bangla_language.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(BanglaLanguage.settings),
      body: const Center(
        child: Text('Settings Screen', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
