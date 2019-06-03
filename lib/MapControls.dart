import 'dart:math';

import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/vec2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'Game.dart';

import 'HeroController.dart';

class MapControls extends FlareControls {
  ActorNode _map;
  ActorNode _ground;
  FlutterActorArtboard _artboard;
  Vec2D heroPos;
  double _heroAngle;
  double _speed = 4;
  FlareActor _hero;
  CharacterInfo _heroSizes;
  bool _walks = false;
  bool _stopped = false;
  ActorNode rect;
  double x;
  double y;
  List<FlutterActorShape> _obstacles;

  MapControls(double this._heroAngle, FlareActor this._hero, CharacterInfo this._heroSizes);

  set heroAngle(double angle) {
    _heroAngle = angle;
  }

  void toggleStopped() {
    _stopped = !_stopped;
    _stopped ? (_hero.controller as HeroControls).play("stand") : (_hero.controller as HeroControls).play("walk");
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    super.advance(artboard, elapsed);

    if (_stopped) return true;

    Vec2D pos = Vec2D.add(Vec2D(), _map.translation,
        Vec2D.fromValues(-sin(_heroAngle) * _speed, cos(_heroAngle) * _speed));

    if (pos[1] < (_ground.children[0] as FlutterActorRectangle).height/2 &&
        pos[1] > -(_ground.children[0] as FlutterActorRectangle).height/2 &&
        pos[0] < (_ground.children[0] as FlutterActorRectangle).width/2 &&
        pos[0] > -(_ground.children[0] as FlutterActorRectangle).width/2 &&
        !colision(Vec2D.subtract(Vec2D(), heroPos,
            Vec2D.fromValues(-sin(_heroAngle) * _speed, cos(_heroAngle) * _speed))) ) {
      _map.translation = pos;
      if (!_walks) {
        (_hero.controller as HeroControls).play("walk");
        _walks = true;
      }
      heroPos = Vec2D.subtract(
          Vec2D(),
          heroPos,
          Vec2D.fromValues(
              -sin(_heroAngle) * _speed, cos(_heroAngle) * _speed));
    } else {
      if (_walks) {
        (_hero.controller as HeroControls).play("stand");
        _walks = false;
      }
    }

    double x = heroPos[0];
    double y = heroPos[1];
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
    rect = artboard.getNode("rect4514");
    _obstacles = List<FlutterActorShape>();

    artboard.nodes.forEach((node) => {
      if (node is FlutterActorShape && node.name != "Ground") {
        _obstacles.add(node)
      }
    }  );

  }



  @override
  void setViewTransform(Mat2D viewTransform) {
  }

  bool colision(Vec2D pos) {
    bool colision = false;
    for (final obst in _obstacles)
    {
      if (obst.children[0] is  FlutterActorPath) continue;
      if (pos[0] >=
          (obst.x - 0.5 * (obst.children[0] as FlutterActorRectangle).width -
              abs(_heroSizes.width / 2 * cos(_heroAngle)) -
              abs(_heroSizes.height / 2 * sin(_heroAngle))) &&
          pos[0] <= (obst.x +
              0.5 * (obst.children[0] as FlutterActorRectangle).width +
              abs(_heroSizes.width / 2 * cos(_heroAngle)) +
              abs(_heroSizes.height / 2 * sin(_heroAngle))) &&
          pos[1] >= (obst.y -
              0.5 * (obst.children[0] as FlutterActorRectangle).height -
              abs(_heroSizes.height / 2 * cos(_heroAngle)) -
              abs(_heroSizes.width / 2 * sin(_heroAngle))) &&
          pos[1] <= (obst.y +
              0.5 * (obst.children[0] as FlutterActorRectangle).height +
              abs(_heroSizes.height / 2 * cos(_heroAngle)) +
              abs(_heroSizes.width / 2 * sin(_heroAngle))))
        {
          colision = true;
          break;
        }
    }

    return colision;
  }

  double abs(double val) {
    return val>=0 ? val : -val;
  }
}
