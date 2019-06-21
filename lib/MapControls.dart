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
import 'Miscalenious.dart';
import 'HeroController.dart';


class MapControls extends FlareControls {


  MapControls._privateConstructor();

  static final MapControls _instance = MapControls._privateConstructor();

  factory MapControls(){
    return _instance;
  }

  ActorNode _map;
  ActorNode _ground;
  FlutterActorArtboard _artboard;
  Vec2D heroPos;
  double _lastCollisionAngle;
  double _heroSpeed;
  FlareActor _hero;
  bool _walks = false;
  bool _stopped = false;
  List<FlutterActorShape> _obstacles;
  bool heroCollidingState = false;
  FlutterActorShape _collidingObstacle;
  bool _conditionallyLetHimGo = false;
  FootState _heroFootState;
  GameState _gameState;
  List<CharacterInfo> _enemies = new List<CharacterInfo>();
  List<EnemyController> _enemiesContr = new List<EnemyController>();

  void setHero(hero) {
    _hero = hero;
  }

  void setGameState(gameState) {
    _gameState = gameState;
  }

  void addEnemy(CharacterInfo enemy/*, EnemyController ec*/) {
    _enemies.add(enemy);
//    _enemiesContr.add(ec);
  }

  set heroAngle(double angle) {
    Globals().heroAngle = angle;
    if(heroCollidingState){
//      Vec2D pos = Vec2D.add(Vec2D(), _map.translation,
//          Vec2D.fromValues(-sin(angle) * _speed, cos(angle) * _speed));

      Vec2D newPos = Vec2D.subtract(
          Vec2D(),
          heroPos,
          Vec2D.fromValues(
              -sin(Globals().heroAngle) * _heroSpeed, cos(Globals().heroAngle) * _heroSpeed));

      double prevDist = sqrt(pow(_collidingObstacle.x - heroPos.values[0], 2)+
          pow(_collidingObstacle.y - heroPos.values[1], 2));

      double newDist = sqrt(pow(_collidingObstacle.x - newPos.values[0], 2)+
          pow(_collidingObstacle.y - newPos.values[1], 2));

      if (prevDist < newDist) {
        heroCollidingState = false;
        _conditionallyLetHimGo = true;
        _map.translation = Vec2D.add(Vec2D(), _map.translation,
            Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed, cos(Globals().heroAngle) * _heroSpeed));

        heroPos = Vec2D.subtract(Vec2D(), heroPos, Vec2D.fromValues(
                -sin(Globals().heroAngle) * _heroSpeed, cos(Globals().heroAngle) * _heroSpeed));

      } else {

      }
/*      
      bool Right = pos[0] >= (_collidingObstacle.x -
          0.5 * (_collidingObstacle.children[0] as FlutterActorRectangle).width -
          abs(_heroSizes.width / 2 * cos(_heroAngle)) -
          abs(_heroSizes.height / 2 * sin(_heroAngle)));
      bool Left = pos[0] <= (_collidingObstacle.x +
          0.5 * (_collidingObstacle.children[0] as FlutterActorRectangle).width +
          abs(_heroSizes.width / 2 * cos(_heroAngle)) +
          abs(_heroSizes.height / 2 * sin(_heroAngle)));
      bool Down = pos[1] >= (_collidingObstacle.y -
          0.5 * (_collidingObstacle.children[0] as FlutterActorRectangle).height -
          abs(_heroSizes.height / 2 * cos(_heroAngle)) -
          abs(_heroSizes.width / 2 * sin(_heroAngle)));
      bool Up = pos[1] <= (_collidingObstacle.y +
          0.5 * (_collidingObstacle.children[0] as FlutterActorRectangle).height +
          abs(_heroSizes.height / 2 * cos(_heroAngle)) +
          abs(_heroSizes.width / 2 * sin(_heroAngle)));

      if (Right && Left && Down && Up) {
        heroCollidingState = true;
          _stopped = true;
      } else {
        heroCollidingState = false;
      }

        _setCorrectPositions(_speed);
        heroCollidingState = false;
      if(_collidingObstacle.x < heroPos.values[0]) {
        if (_collidingObstacle.y < heroPos.values[1]) {

        } else {

        }
      } else {
        if (_collidingObstacle.y < heroPos.values[1]) {

        } else {

        }
      }
      */

    }
    Globals().heroAngle = angle;
  }

//  void _setCorrectPositions(double speed) {
//    _map.translation = Vec2D.subtract(Vec2D(), _map.translation,
//        Vec2D.fromValues(-sin(Globals().heroAngle) * speed, cos(Globals().heroAngle) * speed));
//    heroPos = Vec2D.add(
//        Vec2D(), heroPos, Vec2D.fromValues(
//            -sin(Globals().heroAngle) * speed, cos(Globals().heroAngle) * speed));
//  }

  void toggleStopped() {
    _stopped = !_stopped;
    _stopped /*|| heroCollidingState*/ ?
    (_hero.controller as HeroAnimationController).play("stand") :
    (_hero.controller as HeroAnimationController).play("walk");
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
    switch(_heroFootState) {
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
        timeInSecForIos: 1
    );
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    super.advance(artboard, elapsed);

    if (_stopped) return true;
    if (heroCollidingState) return true;

    Vec2D pos = Vec2D.add(Vec2D(), _map.translation,
        Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed, cos(Globals().heroAngle) * _heroSpeed));

    if (pos[1] < (_ground.children[0] as FlutterActorRectangle).height/2 &&
        pos[1] > -(_ground.children[0] as FlutterActorRectangle).height/2 &&
        pos[0] < (_ground.children[0] as FlutterActorRectangle).width/2 &&
        pos[0] > -(_ground.children[0] as FlutterActorRectangle).width/2 &&
        (!collision(Vec2D.subtract(Vec2D(), heroPos,
            Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed, cos(Globals().heroAngle) * _heroSpeed)))
            /*|| _conditionallyLetHimGo*/)) {
      _map.translation = pos;
      if (!_walks) {
//        (_hero.controller as HeroControls).play("walk");
        _walks = true;
      }
      heroPos = Vec2D.subtract(Vec2D(), heroPos,
          Vec2D.fromValues(
              -sin(Globals().heroAngle) * _heroSpeed, cos(Globals().heroAngle) * _heroSpeed));


      Vec2D enemyPos = Vec2D.add(Vec2D(), Vec2D.fromValues(enemy.X, enemy.Y),
          Vec2D.fromValues(-sin(Globals().heroAngle) * _heroSpeed/2, cos(Globals().heroAngle) * _heroSpeed/2));

      enemy.X = enemyPos[0];
      enemy.Y = enemyPos[1];

      _gameState.setEnemy(enemyPos[0], enemyPos[1]);


    } else {
      if (_walks) {
//        (_hero.controller as HeroControls).play("stand");
        _walks = false;
      }
    }

    double x = heroPos[0];
    double y = heroPos[1];



    
    _enemies.forEach((enemy) => () {
    // nie dziala
//      print("x " + '${enemyPos[0]}' + " |  y " + '${enemyPos[0]}');
    });



//    print("x " + '$x' + " |  y " + '$y');

//    print("_heroAngle: " + (_heroAngle*180/pi).toString());
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
    heroPos = Vec2D.fromValues(_artboard.width/2, _artboard.height/2);
    enemy.X = _artboard.width/2;
    enemy.Y = _artboard.height/2;
    _obstacles = List<FlutterActorShape>();
    _heroFootState = FootState.Walk;
    _heroSpeed = 2;

    artboard.nodes.forEach((node) => {
      if (node is FlutterActorShape && node.name != "Ground") {
        _obstacles.add(node)
      }
    }  );

  }

  @override
  void setViewTransform(Mat2D viewTransform) {
  }

  bool collision(Vec2D pos) {
    for (final obst in _obstacles) {
      if (obst.children[0] is  FlutterActorPath) continue;
      bool Right = pos[0] >= (obst.x -
          0.5 * (obst.children[0] as FlutterActorRectangle).width -
          abs(Globals().heroWidth / 2 * cos(Globals().heroAngle)) -
          abs(Globals().heroHeight / 2 * sin(Globals().heroAngle)));
      bool Left = pos[0] <= (obst.x +
          0.5 * (obst.children[0] as FlutterActorRectangle).width +
          abs(Globals().heroWidth / 2 * cos(Globals().heroAngle)) +
          abs(Globals().heroHeight / 2 * sin(Globals().heroAngle)));
      bool Down = pos[1] >= (obst.y -
          0.5 * (obst.children[0] as FlutterActorRectangle).height -
          abs(Globals().heroHeight / 2 * cos(Globals().heroAngle)) -
          abs(Globals().heroWidth / 2 * sin(Globals().heroAngle)));
      bool Up = pos[1] <= (obst.y +
          0.5 * (obst.children[0] as FlutterActorRectangle).height +
          abs(Globals().heroHeight / 2 * cos(Globals().heroAngle)) +
          abs(Globals().heroWidth / 2 * sin(Globals().heroAngle)));

      if (Right && Left && Down && Up) {
          heroCollidingState = true;
          _collidingObstacle = obst;
          _lastCollisionAngle = Globals().heroAngle;
//          _stopped = true;
          break;
        }
    }

    return heroCollidingState;
  }


}
