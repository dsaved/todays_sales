import 'package:flutter/material.dart';

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar({@required this.color, @required this.tabBar, this.tabHeight});

  final Color color;
  final TabBar tabBar;
  final double tabHeight;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
        color: color,
        child: tabBar,
        height: tabHeight,
      );
}
