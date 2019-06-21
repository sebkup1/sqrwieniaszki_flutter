import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:sqrwieniaszki_flutter/Enemies/EnemyController.dart';

import '../MapControls.dart';
import '../Miscalenious.dart';

class Enemies {

  Enemies() {
//    MapControls().addEnemy(enemy);
  }

}


EnemyController enemyController = new EnemyController();
CharacterInfo enemy = CharacterInfo(
    100,
    100,
    100);


Widget getEnemies() {

  return Positioned(
      left: enemy.X,
      top: enemy.Y,
      child: Transform.rotate(
        angle: enemy.angle,
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
      ));
}