import 'package:flutter/material.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:women_safety/screens/friend/friend.dart';
import 'package:women_safety/screens/main/main.dart';
import 'package:women_safety/screens/map/map.dart';

class ShowPages extends StatefulWidget {
  @override
  _ShowPagesState createState() => _ShowPagesState();
}

class _ShowPagesState extends State<ShowPages> {
  int currentIndex;
  var widgets = [Main(), MyApp2(), FriendList()];

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BubbleBottomBar(
        opacity: 0.2,
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
        currentIndex: currentIndex,
        hasInk: true,
        inkColor: Colors.black12,
        hasNotch: true,
        // fabLocation: BubbleBottomBarFabLocation.end,
        onTap: changePage,
        items: [
          BubbleBottomBarItem(
            backgroundColor: Colors.amber[900],
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.home,
              color: Colors.amber[900],
            ),
            title: Text('Home'),
          ),
          BubbleBottomBarItem(
            backgroundColor: Colors.amber[900],
            icon: Icon(
              Icons.location_on,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.location_on,
              color: Colors.amber[900],
            ),
            title: Text('Safe Routes'),
          ),
          BubbleBottomBarItem(
            backgroundColor: Colors.amber[900],
            icon: Icon(
              Icons.people_alt,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.people_alt,
              color: Colors.amber[900],
            ),
            title: Text('Friends'),
          ),
        ],
      ),
      body: Center(
        child: widgets[currentIndex],
      ),
    );
  }
}
