import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/vec2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:sqrwieniaszki_flutter/Interactions/PunchTaker.dart';

import '../Miscalenious.dart';
import 'Enemies.dart';

class EnemyController extends FlareControls with PunchTaker {
  CharacterInfo _character;
  HeapPriorityQueue<HatedObject> _hatedObjects;
  bool _hatedQueueSet = false;
  int live = 5;
  HatedObject _target = null;

  bool _standing = false;
  bool _death = false;
  String _characterName;

  set character(CharacterInfo character) {
    _character = character;
  }

  EnemyController(this._characterName) {
    _hatedObjects = HeapPriorityQueue<HatedObject>();
  }

  @override
  void takeEnemyPunch(CharacterInfo enemy) {
    live--;
    print(
        "${_character.name} ${_characterName} ($live) gets punch from ${enemy.name} (${(enemy.flareActor.controller as EnemyController).live})");
    if (live <= 0) {
      this.play("death"); //death
      Enemies().rip(_character);
      _death = true;
      return;
    }

//    HatedObject hatedObject;
//    hatedObjects.toList().forEach((obj) {
//      if (obj.enemy == enemy) {
//        hatedObject = obj;
////        obj.hatedLevel++;
//      }
//    });
//    hatedObjects.remove(hatedObject);
//    hatedObject.hatedLevel++;
//    hatedObjects.add(hatedObject);
  }

  void update() {
//    print ("${_character.name} ($live)");
    if (live <= 0) {
//      this.play("death");
      _death = true;
      return;
    }

    _adjustToTarget();

    if (_hatedObjects.isEmpty || _target == null) {
//      print(
//          "${pow(_character.X - Globals().hero.X, 2) + pow(_character.Y - Globals().hero.Y, 2)}");
      if (!_standing) {
        _standing = true;
        this.play("stand");
        print("${_character.name} has nothing to do");
      }
      return;
    }

    double widthOffset = 0;
    double heightOffset = 0;

    if (_target.enemy == Globals().hero) {
      widthOffset = -Globals().heroWidth / 2;
      heightOffset = -Globals().heroHeight / 2;
    }

    double alfa = atan2(_target.enemy.Y + heightOffset - _character.Y,
        _target.enemy.X + widthOffset - _character.X);
    _character.angle = alfa + pi / 2;

    double dist = pow(_target.enemy.X + widthOffset - _character.X, 2) +
        pow(_target.enemy.Y + heightOffset - _character.Y, 2);
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
      (_target.enemy.flareActor.controller as EnemyController)
          .takeEnemyPunch(_character);
    }
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    if(artboard != null) {
      super.advance(artboard, elapsed);
//    _update();
      return true;
    } else return false;
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
    _hatedObjects.clear();
    Enemies().getAll().forEach((enemy) {
      if (enemy == _character || enemy.familly == _character.familly ||
          (enemy.flareActor.controller as EnemyController).live <=0) return;
      int level = 0;
      if (enemy.familly != _character.familly) level++;
      _hatedObjects.add(HatedObject(enemy, level));
    });

    if (!_hatedObjects.isEmpty) {
      _target = _hatedObjects.first;
      double smallestDist = pow(_target.enemy.X - _character.X, 2) +
          pow(_target.enemy.Y - _character.Y, 2);
      _hatedObjects.toList().forEach((obj) {
        if (obj.hatedLevel == _hatedObjects.first.hatedLevel &&
            (obj.enemy.flareActor.controller as EnemyController).live > 0) {
          double newDist = pow(obj.enemy.X - _character.X, 2) +
              pow(obj.enemy.Y - _character.Y, 2);
          if (newDist < smallestDist) {
            _target = obj;
            smallestDist = newDist;
          }
        }
      });
    } else
      _target = null;
  }
}
