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

  List<CharacterInfo> _enemiesList = new List<CharacterInfo>();

  Widget drawEnemies() {
    List<Widget> widgets = List<Widget>();
    _enemiesList.forEach((enemy) {
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
    });

    return Stack(children: widgets);
  }

  void addEnemy(
      {double angle: 0, double X: 0, double Y: 0, String name: "Unknown"}) {
    CharacterInfo newGay;
    EnemyController contr = EnemyController();
    newGay = CharacterInfo(angle, X, Y, name,
        FlareActor(
          "assets/Enemy.flr",
          controller: contr,
        ));
    contr.character = newGay;
    _enemiesList.add(newGay);
  }

  List<CharacterInfo> getEnemyList() {
    return _enemiesList;
  }
}