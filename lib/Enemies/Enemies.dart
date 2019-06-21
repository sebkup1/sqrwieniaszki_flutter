import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

import 'package:sqrwieniaszki_flutter/Enemies/EnemyController.dart';

import '../Miscalenious.dart';

Widget enemies() {
  EnemyController enemyController = new EnemyController();
  CharacterInfo enemy = CharacterInfo(Globals().heroWidth, Globals().heroHeight, Globals().heroScale);

  return
    Positioned(
      left: (Globals().screenWidth / 4) - Globals().heroWidth / 2,
      top: (Globals().screenHeight / 2) - Globals().heroHeight/ 2,
      child: Transform.rotate(
        angle: Globals().heroAngle,
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
    )



  );
}