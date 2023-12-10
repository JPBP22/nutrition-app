import 'package:flutter/material.dart';

class DishesScreen extends StatelessWidget {
  final dynamic menuData;

  DishesScreen({Key? key, required this.menuData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weekly Menu')),
      body: menuData != null && menuData['weekly_menu'] != null
        ? ListView.builder(
            itemCount: menuData['weekly_menu'].length,
            itemBuilder: (context, index) {
              var dayMenu = menuData['weekly_menu'][index];
              List<Widget> mealWidgets = [];
              for (var meal in dayMenu['menu']) {
                mealWidgets.add(
                  ListTile(
                    title: Text(meal['meal']),
                    subtitle: Text('${meal['recipe']} - ${meal['calories']}'),
                  ),
                );
              }
              return ExpansionTile(
                title: Text('Day ${index + 1}'),
                children: mealWidgets,
              );
            },
          )
        : Center(child: Text("No menu data available")),
    );
  }
}
