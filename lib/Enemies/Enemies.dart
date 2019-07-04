import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:sqrwieniaszki_flutter/Enemies/EnemyController.dart';

import '../Miscalenious.dart';

class Enemies {
  Enemies._privateConstructor() {}

  static final Enemies _instance = Enemies._privateConstructor();

  factory Enemies() {
    return _instance;
  }

  List<CharacterInfo> _aliveEnemiesList = new List<CharacterInfo>();
  List<CharacterInfo> _ripEemiesList = new List<CharacterInfo>();
  List<Widget> widgets = List<Widget>();

  Widget drawEnemies() {
    widgets.clear();
    _ripEemiesList.forEach(_addToStack);
    _aliveEnemiesList.forEach(_addToStack);

    return Stack(children: widgets);
  }

  void _addToStack(CharacterInfo enemy) {
    widgets.add(Positioned(
        left: enemy.X,
        top: enemy.Y,
        child: Transform.rotate(
          angle: enemy.angle,
          child: Container(
//                    margin: const EdgeInsets.all(1.0),
//                    decoration: BoxDecoration(border: Border.all()),
            height: Globals().heroHeight,
            width: Globals().heroWidth,
            child: enemy.flareActor,
          ),
        )));
  }

  void addEnemy(
      {double angle: 0,
      double X: 0,
      double Y: 0,
      String name: "Unknown",
      Familly familly: Familly.Avengers}) {
//    CharacterInfo newGay;
    EnemyController contr = EnemyController();
    CharacterInfo newGay = CharacterInfo(
        angle,
        X,
        Y,
        name,
        FlareActor(
          "assets/Enemy.flr",
          controller: contr,
        ),
        familly);
    contr.character = newGay;
    _aliveEnemiesList.add(newGay);
  }

  List<CharacterInfo> getEnemyList() {
    return _aliveEnemiesList;
  }

  List<CharacterInfo> getCorpsList() {
    return _ripEemiesList;
  }

  void rip(CharacterInfo corps) {
    _aliveEnemiesList.remove(corps);
    _ripEemiesList.add(corps);
  }
}
