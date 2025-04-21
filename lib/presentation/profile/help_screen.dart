import 'package:flutter/material.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('সাহায্য'),
      body: const Center(
        child: Text('Help Screen', style: TextStyle(fontSize: 20)),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
