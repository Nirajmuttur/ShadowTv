import 'package:flutter/material.dart';
import 'package:movieapp/Pages/Downloads.dart';
import 'package:movieapp/Pages/Home.dart';
import 'package:movieapp/Pages/Movie/Home.dart';
import 'package:movieapp/Pages/Search.dart';

class Navigation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NavigationState();
  }
}

class _NavigationState extends State<Navigation> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomePage(),
    MovieHome(),
    Search(),
    Downloads(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xff393e46),
        unselectedItemColor: Color(0xffeeeeee),
        backgroundColor: Color(0xff222831),
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.tv_sharp),
            title: Text('TV Shows'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            title: Text('Movies'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_rounded),
            title: Text('Downloads'),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
