import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'HeroController.dart';
import 'MapControls.dart';

class Game extends StatefulWidget {
  Game({Key key}) : super(key: key);

  @override
  _GameState createState() => _GameState();
}

class CharacterInfo
{
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
  HeroControls _heroControler;
  FlareActor _hero;
  FlareActor _map;
  AnimationController _animationController;
  Animation<double> _animation;
  double _angle = 0;
  double _angleStep = 0.05;
  double _screenWidth, _screenHeight;
  CharacterInfo _heroSizes;
  double _heroScale = 0.75;
  double _heroWidth = 110.0;
  double _heroHeight = 70.0;
  ImmediateMultiDragGestureRecognizer _mulitiDragReco;

  @override
  initState() {
    super.initState();
    _heroControler = HeroControls();
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
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.blueAccent,
        body:  GestureDetector(

          onPanUpdate: (DragUpdateDetails details) =>
              onTapDown(context, details),
//          onTap: () =>
//          onDoubleTap(context),
//          onDoubleTap: () =>
//            onDoubleTap(context),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: _map,
              ),
              Positioned(
                left: (_screenWidth/2) - _heroSizes.width/2,
                top: (_screenHeight/2) - _heroSizes.height/2,
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

  void onTapDown(BuildContext context, DragUpdateDetails details) {
    print('${details.globalPosition}');
    final RenderBox box = context.findRenderObject();
    setState(() {
//      print("main _heroAngle " + '$_angle');
      if (details.globalPosition.dx > _screenWidth/2)
        _angle += _angleStep;
      else
        _angle -= _angleStep;

      _mapController.heroAngle = _angle;
    });
  }

  void onDoubleTap(BuildContext context) {
    _mapController.toggleStopped();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

