import 'package:flutter/material.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'test/player_page.dart';
import 'test/player_page2.dart';
import 'test/local_assets.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // TODO
          ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey,
            flexibleSpace: const SafeArea(
                child: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.audiotrack),
                  text: "Artist",
                ),
                Tab(
                  icon: Icon(Icons.audiotrack),
                  text: "Album",
                ),
                Tab(
                  icon: Icon(Icons.favorite),
                  text: "Favorite",
                ),
              ],
            )),
          ),
          body: _topPageBody(context),
        ),
      ),
    );
  }

  Widget _topPageBody(BuildContext context) {
    return TabBarView(
      children: <Widget>[
        artist(context),
        albumList(context),
        favoriteList(context),
      ],
    );
  }

  Widget artist(BuildContext context) {
    return PlayerPage();
  }

  Widget albumList(BuildContext context) {
    return PlayerPage2();
  }

  Widget favoriteList(BuildContext context) {
    return AssetsPage();
  }

  void _showSnackBar(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 1000),
    ));
  }
}
