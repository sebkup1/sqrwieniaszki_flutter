import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/vec2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';

import '../Miscalenious.dart';
import 'Enemies.dart';

class EnemyController extends FlareControls {
  CharacterInfo _character;
  HeapPriorityQueue<HatedObject> hatedObjects;
  bool hatedQueueSet = false;
  int live = 5;

  set character(CharacterInfo character) {
    _character = character;
  }

  FlutterActorArtboard _artboard;
  ActorNode _enemy;

  EnemyController() {
    hatedObjects = HeapPriorityQueue<HatedObject>(
//            (a, b) {
//      if (a.hatedLevel > b.hatedLevel) 0;
//      else 1;
//    }
    );
  }

  void takeEnemyPunch(CharacterInfo enemy) {
    live--;
    print("${_character.name} gets puch from ${enemy.name}, his live is $live");
    if(live==0) {
      play("stand"); //death
      return;
    }
    HatedObject hatedObject;
    hatedObjects.toList().forEach((obj) {
      if(obj.enemy == enemy) {
        hatedObject = obj;
        obj.hatedLevel++;
      }
    });

    hatedObjects.remove(hatedObject);
    hatedObjects.add(hatedObject);
  }

  void update() {

    if (live <= 0) return;

    _adjustTotarget();

    if (hatedObjects.isEmpty) {
      play("Stand");
      return;
    }

    double widthOffset = 0;
    double heightOffset = 0;

    if(hatedObjects.first.enemy == Globals().hero) {
      widthOffset = - Globals().heroWidth/2;
      heightOffset = - Globals().heroHeight/2;
    }

    double alfa = atan2(hatedObjects.first.enemy.Y + heightOffset - _character.Y,
        hatedObjects.first.enemy.X + widthOffset - _character.X);
    _character.angle = alfa + pi/2;

    double dist = pow(hatedObjects.first.enemy.X + widthOffset - _character.X /*- Globals().screenWidth / 2 + Globals().heroWidth / 2*/, 2)
        + pow(hatedObjects.first.enemy.Y + heightOffset - _character.Y /*- Globals().screenHeight / 2 + Globals().heroHeight / 2*/,2);
    print (dist);

    if (dist > 4500) {
      Vec2D newPos = Vec2D.subtract(
          Vec2D(),
          Vec2D.fromValues(_character.X, _character.Y),
          Vec2D.fromValues(-sin(_character.angle) * 1,
              cos(_character.angle) * 1));

      if (!withOtherEnemyCollizion(_character, newPos)) {
        _character.X = newPos[0];
        _character.Y = newPos[1];
      }
    } else {
      if (hatedObjects.first.enemy != Globals().hero) {
      (hatedObjects.first.enemy.flareActor.controller as EnemyController).takeEnemyPunch(_character);
      }
    }

//    print("alfa: ${_character.angle*180/pi}");
  }


  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    super.advance(artboard, elapsed);
//    _enemy.translation = Vec2D.add(Vec2D(), _enemy.translation, Vec2D.fromValues(1, 1));

    return true;
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    super.initialize(artboard);
    _enemy = artboard.getNode("Hero");
    _artboard = artboard;
    play("walk");
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  bool withOtherEnemyCollizion(CharacterInfo character, Vec2D newPos) {
    for (CharacterInfo enemy in Enemies().getEnemyList()){
      if (enemy == character || (enemy.flareActor.controller as EnemyController).live <= 0) {
        continue;
      }
        double newDist = pow(enemy.X - newPos[0], 2) + pow(enemy.Y - newPos[1], 2);
      if (newDist < 4000 && newDist < pow(enemy.X - character.X, 2) + pow(enemy.Y - character.Y, 2)){
        return true;
      }
    }
    return false;
  }

  void _adjustTotarget() {
    if (!hatedQueueSet) {
//      if (_character.name == "Pech") {
//        hatedObjects.add(HatedObject(Globals().hero, 300));
//        hatedQueueSet = true;
//        return;
//      }
      Enemies().getEnemyList().forEach((enemy) {
        if(enemy == _character) return;
        int level = 0;
        if (enemy.familly != _character.familly) level++;
//        if (enemy.name == "Pech") level = 900;
        hatedObjects.add(HatedObject(enemy, level));
      });
      hatedQueueSet = true;
//      hatedObjects.add(HatedObject(Globals().hero, 0));
    }

    if (!hatedObjects.isEmpty && (hatedObjects.first.enemy.flareActor.controller is EnemyController) &&
        (hatedObjects.first.enemy.flareActor.controller as EnemyController).live <= 0) {
      hatedObjects.removeFirst();
    }
  }
}