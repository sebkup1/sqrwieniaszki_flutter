import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/vec2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_controls.dart';

import '../Miscalenious.dart';
import 'Enemies.dart';

class EnemyController extends FlareControls {
  CharacterInfo _character;
  HeapPriorityQueue<HatedObject> hatedObjects;
  bool hatedQueueSet = false;
  int live = 5;
  HatedObject _target = null;

  bool standing = false;

  set character(CharacterInfo character) {
    _character = character;
  }

  EnemyController() {
    hatedObjects = HeapPriorityQueue<HatedObject>();
  }

  void takeEnemyPunch(CharacterInfo enemy) {
    live--;
    print("${_character.name} gets puch from ${enemy.name}, his live is $live");
    if (live == 0) {
      play("death"); //death
      Enemies().rip(_character);
      return;
    }
    HatedObject hatedObject;
    hatedObjects.toList().forEach((obj) {
      if (obj.enemy == enemy) {
        hatedObject = obj;
        obj.hatedLevel++;
      }
    });

    hatedObjects.remove(hatedObject);
    hatedObjects.add(hatedObject);
  }

  void update() {
    if (live <= 0) return;

    _adjustToTarget();

    if (hatedObjects.isEmpty /*|| _target == null*/) {
      if (!standing) {
        standing = true;
        play("stand");
      }
      return;
    }

    double widthOffset = 0;
    double heightOffset = 0;

    if (hatedObjects.first.enemy == Globals().hero) {
      widthOffset = -Globals().heroWidth / 2;
      heightOffset = -Globals().heroHeight / 2;
    }

    double alfa = atan2(
        hatedObjects.first.enemy.Y + heightOffset - _character.Y,
        hatedObjects.first.enemy.X + widthOffset - _character.X);
    _character.angle = alfa + pi / 2;

    double dist =
        pow(hatedObjects.first.enemy.X + widthOffset - _character.X, 2) +
            pow(hatedObjects.first.enemy.Y + heightOffset - _character.Y, 2);
//    print (dist);
    if (dist > 4500) {
      Vec2D newPos = Vec2D.subtract(
          Vec2D(),
          Vec2D.fromValues(_character.X, _character.Y),
          Vec2D.fromValues(
              -sin(_character.angle) * 1, cos(_character.angle) * 1));

      if (!withOtherEnemyCollizion(newPos) && !withHeroCollizion(newPos)) {
        _character.X = newPos[0];
        _character.Y = newPos[1];
      }
    } else {
      if (hatedObjects.first.enemy != Globals().hero) {
        (hatedObjects.first.enemy.flareActor.controller as EnemyController)
            .takeEnemyPunch(_character);
      }
    }

//    print("alfa: ${_character.angle*180/pi}");
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    super.advance(artboard, elapsed);
//    _update();
    return true;
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    super.initialize(artboard);
    play("walk");
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  bool withOtherEnemyCollizion(Vec2D newPos) {
    for (CharacterInfo enemy in Enemies().getEnemyList()) {
      if (enemy == _character ||
          (enemy.flareActor.controller as EnemyController).live <= 0) {
        continue;
      }
      double newDist =
          pow(enemy.X - newPos[0], 2) + pow(enemy.Y - newPos[1], 2);
      if (newDist < 4000 &&
          newDist <
              pow(enemy.X - _character.X, 2) + pow(enemy.Y - _character.Y, 2)) {
        return true;
      }
    }
    return false;
  }

  bool withHeroCollizion(Vec2D newPos) {
    double newDist =
        pow(Globals().hero.X - Globals().heroWidth / 2 - newPos[0], 2) +
            pow(Globals().hero.Y - Globals().heroHeight / 2 - newPos[1], 2);
    if (newDist < 4000 &&
        newDist <
            pow(Globals().hero.X - Globals().heroWidth / 2 - _character.X, 2) +
                pow(Globals().hero.Y - Globals().heroHeight / 2 - _character.Y,
                    2)) {
      return true;
    }
    return false;
  }

  void _adjustToTarget() {
    if (!hatedQueueSet) {
      Enemies().getEnemyList().forEach((enemy) {
        if (enemy == _character) return;
        int level = 0;
        if (enemy.familly != _character.familly) level++;
        hatedObjects.add(HatedObject(enemy, level));
      });
      hatedQueueSet = true;
    }

    if (!hatedObjects.isEmpty) {
      if ((hatedObjects.first.enemy.flareActor.controller is EnemyController) &&
          (hatedObjects.first.enemy.flareActor.controller as EnemyController)
                  .live <=
              0) {
        hatedObjects.removeFirst();
      }
      if (!hatedObjects.isEmpty) {
        double smallestDist = double.maxFinite;
        hatedObjects.toList().forEach((obj) {
          if (obj.hatedLevel == hatedObjects.first.hatedLevel) {
            if (pow(obj.enemy.X - _character.X, 2) +
                    pow(obj.enemy.Y - _character.Y, 2) <
                smallestDist) {
              _target = obj;
            }
          }
        });
      } else
        _target = null;
    } else
      _target = null;
  }
}
