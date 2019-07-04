import 'dart:math';

import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/vec2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Enemies/Enemies.dart';
import 'Enemies/EnemyController.dart';
import 'Game.dart';
import 'HeroController.dart';
import 'Miscalenious.dart';

class MapControls extends FlareControls {
  MapControls._privateConstructor();

  static final MapControls _instance = MapControls._privateConstructor();

  factory MapControls() {
    return _instance;
  }

  ActorNode _map;
  FlutterActorArtboard _artboard;
  double _heroSpeed;
  FlareActor _hero;
  bool _walks = false;
  bool _stopped = false;
  List<FlutterActorShape> _obstacles;
  bool heroCollidingState = false;
  FlutterActorShape _collidingObstacle;
  CharacterInfo _collidingEnemy;
  FootState _heroFootState;
  GameState _gameState;

  void setHero(hero) {
    _hero = hero;
  }

  void setGameState(gameState) {
    _gameState = gameState;
  }

  set heroAngle(double angle) {
    Globals().heroAngle = angle;

    if (heroCollidingState) {
      double prevDist = 0, newDist = 1;
      if (_collidingObstacle != null) {

        Vec2D newPos = Vec2D.subtract(
            Vec2D(),
            Globals().heroPosOnMap,
            Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed,
                cos(Globals().heroAngle) * _heroSpeed));

      prevDist =
          pow(_collidingObstacle.x - Globals().heroPosOnMap.values[0], 2) +
              pow(_collidingObstacle.y - Globals().heroPosOnMap.values[1], 2);

      newDist = pow(_collidingObstacle.x - newPos.values[0], 2) +
          pow(_collidingObstacle.y - newPos.values[1], 2);
      }

      if (_collidingEnemy != null) {
        Vec2D newPos = Vec2D.add(
            Vec2D(),
            Vec2D.fromValues(_collidingEnemy.X, _collidingEnemy.Y),
            Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed / 2,
                cos(Globals().heroAngle) * _heroSpeed / 2));

        newDist = pow(newPos[0] - Globals().screenWidth / 2 + Globals().heroWidth / 2, 2)
            + pow(newPos[1] - Globals().screenHeight / 2 + Globals().heroHeight / 2,2);

        prevDist = pow(_collidingEnemy.X - Globals().screenWidth / 2 + Globals().heroWidth / 2, 2)
            + pow(_collidingEnemy.Y - Globals().screenHeight / 2 + Globals().heroHeight / 2,2);

      }

      if (prevDist < newDist) {
        heroCollidingState = false;
        _collidingObstacle = null;
        _collidingEnemy = null;
        _map.translation = Vec2D.add(
            Vec2D(),
            _map.translation,
            Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed,
                cos(Globals().heroAngle) * _heroSpeed));

        Globals().heroPosOnMap = Vec2D.subtract(
            Vec2D(),
            Globals().heroPosOnMap,
            Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed,
                cos(Globals().heroAngle) * _heroSpeed));
      } else {}
    }
  }

  void toggleStopped() {
    _stopped = !_stopped;
    _stopped /*|| heroCollidingState*/ ? (_hero.controller
                as HeroAnimationController)
            .play("stand")
        : (_hero.controller as HeroAnimationController).play("walk");
  }

  void heroSpeedUp() {
    if (_heroFootState != FootState.Sprint) {
      _heroFootState = FootState.values[_heroFootState.index + 1];
      setNewFootState();
    }
  }

  void heroSlowDown() {
    if (_heroFootState != FootState.Stand) {
      _heroFootState = FootState.values[_heroFootState.index - 1];
      setNewFootState();
    }
  }

  void setNewFootState() {
    switch (_heroFootState) {
      case FootState.Stand:
        _stopped = true;
        (_hero.controller as HeroAnimationController).play("stand");
        break;
      case FootState.Walk:
        _heroSpeed = 1.5;
        break;
      case FootState.Marathon:
        _heroSpeed = 4;
        break;
      case FootState.Sprint:
        _heroSpeed = 8;
        break;
    }
    if (_heroFootState != FootState.Stand) {
      _stopped = false;
      (_hero.controller as HeroAnimationController).play("walk");
    }

    Fluttertoast.showToast(
        msg: "$_heroFootState",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIos: 1);
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    super.advance(artboard, elapsed);

    if (_stopped || heroCollidingState) {
      Enemies().getEnemyList().forEach((enemy) {
        (enemy.flareActor.controller as EnemyController).update();
      });
      Enemies().getCorpsList().forEach((enemy) {
        (enemy.flareActor.controller as EnemyController).update();
      });
      _gameState.updateState();
      return true;
    }

    Vec2D pos = Vec2D.add(
        Vec2D(),
        _map.translation,
        Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed,
            cos(Globals().heroAngle) * _heroSpeed));

    if (/*pos[1] < (_ground.children[0] as FlutterActorRectangle).height / 2 &&
        pos[1] > -(_ground.children[0] as FlutterActorRectangle).height / 2 &&
        pos[0] < (_ground.children[0] as FlutterActorRectangle).width / 2 &&
        pos[0] > -(_ground.children[0] as FlutterActorRectangle).width / 2 &&*/
        (!collision(Vec2D.subtract(
            Vec2D(),
            Globals().heroPosOnMap,
            Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed,
                cos(Globals().heroAngle) * _heroSpeed))))) {
      _map.translation = pos;
      if (!_walks) {
        _walks = true;
      }
      Globals().heroPosOnMap = Vec2D.subtract(
          Vec2D(),
          Globals().heroPosOnMap,
          Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed,
              cos(Globals().heroAngle) * _heroSpeed));

      Enemies().getCorpsList().forEach((corps) {
        Vec2D enemyPos = Vec2D.add(
            Vec2D(),
            Vec2D.fromValues(corps.X, corps.Y),
            Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed / 2,
                cos(Globals().heroAngle) * _heroSpeed / 2));

        corps.X = enemyPos[0];
        corps.Y = enemyPos[1];
      });
      Enemies().getEnemyList().forEach((enemy) {
        Vec2D enemyPos = Vec2D.add(
            Vec2D(),
            Vec2D.fromValues(enemy.X, enemy.Y),
            Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed / 2,
                cos(Globals().heroAngle) * _heroSpeed / 2));

        enemy.X = enemyPos[0];
        enemy.Y = enemyPos[1];
      });
    } else {
      if (_walks) {
        _walks = false;
      }
    }

    Enemies().getEnemyList().forEach((enemy) {
      (enemy.flareActor.controller as EnemyController).update();
    });
    Enemies().getCorpsList().forEach((enemy) {
      (enemy.flareActor.controller as EnemyController).update();
    });
    _gameState.updateState();

    return true;
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    super.initialize(artboard);
    artboard.nodes;
    _artboard = artboard;
    _ground = artboard.getNode("Ground");
    _map = artboard.getNode("map2");
    _map.translation = Vec2D.fromValues(0, 0);
    Globals().heroPosOnMap = Vec2D.fromValues(_artboard.width / 2, _artboard.height / 2);

    _obstacles = List<FlutterActorShape>();
    _heroFootState = FootState.Walk;
    _heroSpeed = 2;

    artboard.nodes.forEach((node) => {
          if (node is FlutterActorShape && node.name != "Ground")
            {_obstacles.add(node)}
        });
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  bool collision(Vec2D pos) {
    for (final obst in _obstacles) {
      if (obst.children[0] is FlutterActorPath) continue;
      bool Right = pos[0] >=
          (obst.x -
              0.5 * (obst.children[0] as FlutterActorRectangle).width -
              abs(Globals().heroWidth / 2 * cos(Globals().heroAngle)) -
              abs(Globals().heroHeight / 2 * sin(Globals().heroAngle)));
      bool Left = pos[0] <=
          (obst.x +
              0.5 * (obst.children[0] as FlutterActorRectangle).width +
              abs(Globals().heroWidth / 2 * cos(Globals().heroAngle)) +
              abs(Globals().heroHeight / 2 * sin(Globals().heroAngle)));
      bool Down = pos[1] >=
          (obst.y -
              0.5 * (obst.children[0] as FlutterActorRectangle).height -
              abs(Globals().heroHeight / 2 * cos(Globals().heroAngle)) -
              abs(Globals().heroWidth / 2 * sin(Globals().heroAngle)));
      bool Up = pos[1] <=
          (obst.y +
              0.5 * (obst.children[0] as FlutterActorRectangle).height +
              abs(Globals().heroHeight / 2 * cos(Globals().heroAngle)) +
              abs(Globals().heroWidth / 2 * sin(Globals().heroAngle)));

      if (Right && Left && Down && Up) {
        heroCollidingState = true;
        _collidingObstacle = obst;
        break;
      }
    }

    if (!heroCollidingState) {
      for (final enemy in  Enemies().getEnemyList()) {
        if((enemy.flareActor.controller as EnemyController).live <= 0) continue;
        Vec2D newPos = Vec2D.add(
            Vec2D(),
            Vec2D.fromValues(enemy.X, enemy.Y),
            Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed / 2,
                cos(Globals().heroAngle) * _heroSpeed / 2));

        double newDist = pow(newPos[0] - Globals().screenWidth / 2 + Globals().heroWidth / 2, 2)
            + pow(newPos[1] - Globals().screenHeight / 2 + Globals().heroHeight / 2,2);
        if(newDist < 3000 && newDist < pow(enemy.X - Globals().screenWidth / 2 + Globals().heroWidth / 2, 2)
            + pow(enemy.Y - Globals().screenHeight / 2 + Globals().heroHeight / 2,2)) {
          heroCollidingState = true;
          _collidingEnemy = enemy;
          break;
        }
      };
    }

    return heroCollidingState;
  }
}
