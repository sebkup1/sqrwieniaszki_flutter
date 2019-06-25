import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:sqrwieniaszki_flutter/Enemies/EnemyController.dart';

import '../Miscalenious.dart';

EnemyController enemyController = new EnemyController();

CharacterInfo enemy1 = CharacterInfo(100, 100, 100, "Steve Rogers");
CharacterInfo enemy2 = CharacterInfo(-100, -100, -100, "Jorah Mormont");
CharacterInfo enemy3 = CharacterInfo(0, 0, 0, "Antoni Macierewicz");

List<Widget> heroes = <Widget>[
  Positioned(
      left: enemy1.X,
      top: enemy1.Y,
      child: Transform.rotate(
        angle: enemy1.angle,
        child: Container(
//                    margin: const EdgeInsets.all(1.0),
//                    decoration: BoxDecoration(border: Border.all()),
          height: Globals().heroHeight,
          width: Globals().heroWidth,
          child: FlareActor(
            "assets/Enemy.flr",
            controller: enemyController,
          ),
        ),
      )),
  Positioned(
      left: enemy2.X,
      top: enemy2.Y,
      child: Transform.rotate(
        angle: enemy2.angle,
        child: Container(
//                    margin: const EdgeInsets.all(1.0),
//                    decoration: BoxDecoration(border: Border.all()),
          height: Globals().heroHeight,
          width: Globals().heroWidth,
          child: FlareActor(
            "assets/Enemy.flr",
            controller: enemyController,
          ),
        ),
      )),
  Positioned(
      left: enemy3.X,
      top: enemy3.Y,
      child: Transform.rotate(
        angle: enemy3.angle,
        child: Container(
//                    margin: const EdgeInsets.all(1.0),
//                    decoration: BoxDecoration(border: Border.all()),
          height: Globals().heroHeight,
          width: Globals().heroWidth,
          child: FlareActor(
            "assets/Enemy.flr",
            controller: enemyController,
          ),
        ),
      ))
];


Widget getHeroes() {

  return Stack(children: heroes);
}

void addHero() {

}