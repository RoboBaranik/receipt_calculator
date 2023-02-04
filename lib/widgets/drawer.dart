import 'package:flutter/material.dart';

import '../routes.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.amberAccent,
          ),
          child: Text(
            'Receipt calculator',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTileTheme(
          selectedColor: Colors.orange,
          style: ListTileStyle.drawer,
          child: ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Receipt list'),
            selected: Routes.receiptList.compareTo(currentRoute) == 0,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, Routes.receiptList);
            },
          ),
        ),
        // ListTileTheme(
        //   selectedColor: Colors.orange,
        //   style: ListTileStyle.drawer,
        //   child: ListTile(
        //     leading: const Icon(Icons.receipt),
        //     title: const Text('Receipt'),
        //     selected: Routes.receipt.compareTo(currentRoute) == 0,
        //     onTap: () {
        //       Navigator.pop(context);
        //       Navigator.pushNamed(context, Routes.receipt);
        //     },
        //   ),
        // ),
      ],
    );
  }
}
