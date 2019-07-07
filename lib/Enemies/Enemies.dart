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
  List<CharacterInfo> all = new List<CharacterInfo>();
  List<Widget> widgets = List<Widget>();
  Map<EnemyController, CharacterInfo> map = Map<EnemyController, CharacterInfo>();

  Widget drawEnemies() {
    widgets = List<Widget>();
    all.forEach((en) {if ((en.flareActor.controller as EnemyController).live <= 0){_addToStack(en);}});
    all.forEach((en) {if ((en.flareActor.controller as EnemyController).live > 0){_addToStack(en);}});
//    _aliveEnemiesList.forEach(_addToStack);

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
    EnemyController contr = EnemyController(name);
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

    all.add(newGay);
  }

  List<CharacterInfo> getEnemyList() {
    List<CharacterInfo> toRet = List<CharacterInfo>();
    all.forEach((en) {
      if((en.flareActor.controller as EnemyController).live > 0)
        toRet.add(en);
    });
    return toRet;
//    return _aliveEnemiesList;
  }

  List<CharacterInfo> getCorpsList() {
    List<CharacterInfo> toRet = List<CharacterInfo>();
    all.forEach((en) {
      if((en.flareActor.controller as EnemyController).live <= 0)
        toRet.add(en);
    });
    return toRet;
  }

  List<CharacterInfo> getAll() {
//    List<CharacterInfo> all = List<CharacterInfo>();
//    all.clear();
//    all.addAll(_ripEemiesList);
//    all.addAll(_aliveEnemiesList);
    return all;
  }

//  void rip(CharacterInfo corps) {
////    CharacterInfo temp = corps;
////    _aliveEnemiesList.remove(corps);
////    _ripEemiesList.add(temp);
//  }
}
