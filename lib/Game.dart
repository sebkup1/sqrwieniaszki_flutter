import 'dart:math';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'HeroController.dart';
import 'MapControls.dart';
import 'Miscalenious.dart';

class Game extends StatefulWidget {
  Game(this._context, {Key key}) : super(key: key);
  BuildContext _context;

  @override
  _GameState createState() => _GameState(_context);
}

class CharacterInfo {
  double width;
  double height;
  double scale;
  double X, Y;

  CharacterInfo(double width, double height, double this.scale) {
    this.width = width * scale;
    this.height = height * scale;
  }
}

class _GameState extends State<Game> with SingleTickerProviderStateMixin {
  MapControls _mapController;
  HeroAnimationController _heroControler;
  FlareActor _hero;
  FlareActor _map;
  double _angle = 0;
  double _angleDiffRatio = 0.05;
  double _screenWidth, _screenHeight;
  CharacterInfo _heroSizes;
  double _heroScale = 0.75;
  double _heroWidth = 110.0;
  double _heroHeight = 110.0;
  double _lastCoursorX = -1.0,
      _lastCoursorY = -1.0;
  bool _verMoveStarted = false;
  double _verMoveDist = 0.0;
  bool _vertGestDone = false;
  GestCommand _gestCommand;
  BuildContext _context;

  _GameState(this._context);

  @override
  initState() {
    super.initState();
    _heroControler = HeroAnimationController();
    _heroSizes = CharacterInfo(_heroWidth, _heroHeight, _heroScale);
    _hero = FlareActor(
      "assets/Hero.flr",
      controller: _heroControler,
    );
    _mapController = MapControls(_angle, _hero, _heroSizes);

    _map = FlareActor(
      "assets/map.flr",
      controller: _mapController,
    );
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    _screenHeight = MediaQuery
        .of(context)
        .size
        .height;

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
              Positioned(
                left: (_screenWidth / 2) - _heroSizes.width / 2,
                top: (_screenHeight / 2) - _heroSizes.height / 2,
                child: Transform.rotate(
                  angle: _angle,
                  child: Container(
//                    margin: const EdgeInsets.all(1.0),
//                    decoration: BoxDecoration(border: Border.all()),
                    height: _heroSizes.height,
                    width: _heroSizes.width,
                    child: _hero,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void onDragUpdate(BuildContext context, DragUpdateDetails details) {
    print('${details.globalPosition}');
    final RenderBox box = context.findRenderObject();
    setState(() {
      double newX = details.globalPosition.dx;
      double newY = details.globalPosition.dy;

      if (_lastCoursorX != -1.0 && _lastCoursorY != -1.0) {
        if (abs(newX - _lastCoursorX) >
            2 * abs(newY - _lastCoursorY)) {
          _verMoveStarted = false;
          _verMoveDist = 0.0;
          if (abs(newX - _lastCoursorX) * _angleDiffRatio <
              pi / 8) {
            if (newX > _screenWidth / 2 &&
                newX > _lastCoursorX) {
              _angle += abs(newX - _lastCoursorX) *
                  _angleDiffRatio;
            } else if (newX < _screenWidth / 2 &&
                newX < _lastCoursorX) {
              _angle += -abs(newX - _lastCoursorX) *
                  _angleDiffRatio;
            }
          }
          _mapController.heroAngle = _angle;
        } else if (_verMoveStarted ||
            abs(newX - _lastCoursorX) * 5 <
                abs(newY - _lastCoursorY)) {
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
            timeInSecForIos: 1
        );
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