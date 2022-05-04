import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef DrawerState(bool);

// ignore: must_be_immutable
class MyDrawer extends StatefulWidget {
  MyDrawer({@required this.child, this.drawerState});

  Widget child;
  DrawerState drawerState;

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  void initState() {
    super.initState();
    widget.drawerState(true);
  }

  @override
  void dispose() {
    widget.drawerState(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(child: widget.child);
  }
}
