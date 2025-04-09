import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/bangla_language.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/grid_view.dart';

class SellScreen extends StatelessWidget {
  const SellScreen({super.key}); // Added semicolon here

  @override
  Widget build(BuildContext context) {
    // Define grid items with their icons, names and routes
    final List<Map<String, dynamic>> gridItems = [
      {
        'name': BanglaLanguage.addSellProducts,
        'icon': Icons.add_box_outlined,
        'route': '/',
        'color': Colors.blue,
      },
      {
        'name': BanglaLanguage.seeSellProducts,
        'icon': Icons.view_cozy_outlined,
        'route': '/',
        'color': Colors.orange,
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(BanglaLanguage.sell),
      body: Column(children: [CustomGridView(gridItems: gridItems)]),
    );
  }
}
