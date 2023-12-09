import 'package:flutter/material.dart';
import 'auth.dart';
import '../screens/export_screens.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree>{
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot){
        if(snapshot.hasData){
          return Home(currentTab: 0);
        }
        else{
          return const LoginPage();
        }
      }
    );
  }
}