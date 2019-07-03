import 'dart:math';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqrwieniaszki_flutter/Enemies/Enemies.dart';

import 'HeroController.dart';
import 'MapControls.dart';
import 'Miscalenious.dart';

class Game extends StatefulWidget {
  Game(this._context, {Key key}) : super(key: key);
  BuildContext _context;

  @override
  GameState createState() => GameState(_context);
}

class GameState extends State<Game> with SingleTickerProviderStateMixin {
  MapControls _mapController = MapControls();
  HeroAnimationController _heroControler;
  FlareActor _map;
  double _angleDiffRatio = 0.05;
  double _screenWidth, _screenHeight;
  double _lastCoursorX = -1.0, _lastCoursorY = -1.0;
  bool _verMoveStarted = false;
  double _verMoveDist = 0.0;
  bool _vertGestDone = false;
  GestCommand _gestCommand;
  BuildContext _context;
  Globals _globals;

  GameState(this._context);

  void updateState() {
    setState(() {});
  }

  @override
  initState() {
    super.initState();

    _heroControler = HeroAnimationController();

    _map = FlareActor(
      "assets/map.flr",
      controller: _mapController,
    );

    Enemies().addEnemy(name: "Steve Rogers",
        X: 0, Y: 450, angle: 0, familly: Familly.Avengers);

    Enemies().addEnemy(name: "Jorah Mormont",
        X: -200, Y: -100, angle: -100, familly: Familly.Avengers);

    Enemies().addEnemy(name: "Antoni Macierewicz",
        X: -300, Y: 1100, angle: 0, familly: Familly.Avengers);

    Enemies().addEnemy(name: "Pech",
        X: -200, Y: 200, angle: 200, familly: Familly.Lanister);

    Enemies().addEnemy(name: "Johnny Walker",
        X: 0, Y: 200, angle: 200, familly: Familly.Lanister);

    Enemies().addEnemy(name: "Steve Rogers",
        X: 1100, Y: 1450, angle: 0);

    Enemies().addEnemy(name: "Jorah Mormont",
        X: -1100, Y: -1100, angle: -100, familly: Familly.Ciapaci);

    Enemies().addEnemy(name: "Antoni Macierewicz",
        X: 1000, Y: 10, angle: 0, familly: Familly.Ciapaci);

    Enemies().addEnemy(name: "Sandor Clegane",
        X: 1200, Y: 1200, angle: 200, familly: Familly.Geje);

    Enemies().addEnemy(name: "Johnny Walker",
        X: 0, Y: 1200, angle: 200, familly: Familly.PiS);

    Enemies().addEnemy(name: "Steve Rogers",
        X: 2100, Y: 2450, angle: 0);

    Enemies().addEnemy(name: "Jorah Mormont",
        X: -2100, Y: -2100, angle: -100);

    Enemies().addEnemy(name: "Antoni Macierewicz",
        X: 200, Y: 0, angle: 0);

    Enemies().addEnemy(name: "Sandor Clegane",
        X: 2200, Y: 2200, angle: 200);

    Enemies().addEnemy(name: "Johnny Walker",
        X: 0, Y: 2200, angle: 200);

  Globals().hero = CharacterInfo(0,0,0,"Buhaj",FlareActor(
    "assets/Hero.flr",
    controller: _heroControler,
  ), Familly.Lanister );

    _mapController.setHero(Globals().hero.flareActor);
  }

  @override
  Widget build(BuildContext context) {
    _globals = Globals();
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _globals.setScreenSizes(_screenWidth, _screenHeight);

    _mapController.setGameState(this);

    return Scaffold(
        backgroundColor: Colors.blueAccent,
        body: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) =>
              onDragUpdate(context, details),
          onPanEnd: (DragEndDetails details) => onDragEnd(details),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: _map,
              ),
              Enemies().drawEnemies(),
              Positioned(
                left: (_screenWidth / 2) - Globals().heroWidth / 2,
                top: (_screenHeight / 2) - Globals().heroHeight / 2,
                child: Transform.rotate(
                  angle: Globals().heroAngle,
                  child: Container(
//                    margin: const EdgeInsets.all(1.0),
//                    decoration: BoxDecoration(border: Border.all()),
                    height: Globals().heroHeight,
                    width: Globals().heroWidth,
                    child: Globals().hero.flareActor,
                  ),
                ),
              ),

            ],
          ),
        ));
  }

  void onDragUpdate(BuildContext context, DragUpdateDetails details) {
    print('${details.globalPosition}');
    setState(() {
      double newX = details.globalPosition.dx;
      double newY = details.globalPosition.dy;

      if (_lastCoursorX != -1.0 && _lastCoursorY != -1.0) {
        if (abs(newX - _lastCoursorX) > 2 * abs(newY - _lastCoursorY)) {
          _verMoveStarted = false;
          _verMoveDist = 0.0;
          if (abs(newX - _lastCoursorX) * _angleDiffRatio < pi / 8) {
            if (newX > _screenWidth / 2 && newX > _lastCoursorX) {
              Globals().heroAngle +=
                  abs(newX - _lastCoursorX) * _angleDiffRatio;
            } else if (newX < _screenWidth / 2 && newX < _lastCoursorX) {
              Globals().heroAngle +=
                  -abs(newX - _lastCoursorX) * _angleDiffRatio;
            }
          }
          _mapController.heroAngle = Globals().heroAngle;
        } else if (_verMoveStarted ||
            abs(newX - _lastCoursorX) * 5 < abs(newY - _lastCoursorY)) {
          _verMoveStarted = true;
          _verMoveDist += (newY - _lastCoursorY);

          if (abs(_verMoveDist) > 30) {
            _vertGestDone = true;
            if (_verMoveDist > 0.0) {
              if (newX > 2 * _screenWidth / 3) {
                _gestCommand = GestCommand.RightHandPunch;
              } else if (newX < _screenWidth / 3) {
                _gestCommand = GestCommand.LeftHandPunch;
              } else {
                _gestCommand = GestCommand.SpeedUp;
              }
            } else {
              if (newX > 2 * _screenWidth / 3) {
                _gestCommand = GestCommand.RightFootPunch;
              } else if (newX < _screenWidth / 3) {
                _gestCommand = GestCommand.LeftFootPunch;
              } else {
                _gestCommand = GestCommand.SlowDown;
              }
            }
          }
        }
      }

      _lastCoursorX = newX;
      _lastCoursorY = newY;
    });
  }

  void onDragEnd(DragEndDetails details) {
    _lastCoursorX = -1.0;
    _lastCoursorY = -1.0;
    _verMoveStarted = false;
    if (_vertGestDone) {
      _verMoveDist = 0.0;
      _vertGestDone = false;

      if (_gestCommand != GestCommand.SlowDown &&
          _gestCommand != GestCommand.SpeedUp) {
        Fluttertoast.showToast(
            msg: "$_gestCommand",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIos: 1);
      }
      if (_gestCommand == GestCommand.SlowDown) {
        _mapController.heroSlowDown();
      } else if (_gestCommand == GestCommand.SpeedUp) {
        _mapController.heroSpeedUp();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  double abs(double val) {
    return val >= 0 ? val : -val;
  }
}
