import 'package:flutter/material.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('প্রোফাইল এডিট করুন'),
      body: const Center(
        child: Text('Edit Profile', style: TextStyle(fontSize: 20)),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
