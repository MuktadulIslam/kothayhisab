import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/bangla_language.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/grid_view.dart'; // Import the new CustomGridView

class ShopsScreen extends StatelessWidget {
  const ShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define grid items with their icons, names and routes
    final List<Map<String, dynamic>> gridItems = [
      {
        'name': BanglaLanguage.addShop,
        'icon': Icons.add_home_work_outlined,
        'route': '/store/add_shops',
        'color': Colors.blue,
      },
      {
        'name': BanglaLanguage.allShops,
        'icon': Icons.home_work_outlined,
        'route': '/store/show_all_shops',
        'color': Colors.teal,
      },
      {
        'name': BanglaLanguage.addEmployee,
        'icon': Icons.person_add_alt_outlined,
        'route': '/',
        'color': Colors.redAccent,
      },
      {
        'name': BanglaLanguage.allEmployees,
        'icon': Icons.people_alt_outlined,
        'route': '/',
        'color': Colors.orange,
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(BanglaLanguage.store),
      body: Column(
        children: [
          // Grid section - Now using the custom grid view with internal navigation
          CustomGridView(gridItems: gridItems),
        ],
      ),
    );
  }
}
