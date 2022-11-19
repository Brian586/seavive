
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seavive/pages/mapsDisplay.dart';
import 'package:seavive/pages/profilePage.dart';
import 'package:seavive/pages/statistics.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  PageController pageController = PageController();
  int getPageIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  whenPageChanges(int pageIndex) {
    setState(() {
      getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex) {
    pageController.animateToPage(pageIndex, duration: const Duration(milliseconds: 400), curve: Curves.bounceInOut,);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: const [
          MapsDisplay(),
          Statistics(),
          ProfilePage()
        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        activeColor: Colors.blue,
        inactiveColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Insights"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }

}
