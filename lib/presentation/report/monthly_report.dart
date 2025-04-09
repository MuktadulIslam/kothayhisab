import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/bangla_language.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(BanglaLanguage.monthlyReport),
      body: const Center(
        child: Text('Monthly Report Screen', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
