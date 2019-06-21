import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';

enum FootState {
  Stand, Walk, Marathon, Sprint
}

enum GestCommand {
  LeftHandPunch, LeftFootPunch, RightHandPunch, RightFootPunch,
  SlowDown, SpeedUp
}


enum CollisionDirection {
  Top, Bottom, Lefr, Right
}

double abs(double val) {
  return val>=0 ? val : -val;
}

class CharacterInfo {
  double width;
  double height;
  double angle;
  double scale;
  double X, Y;

//  CharacterInfo(double width, double height, double this.scale) {
//    this.width = width * scale;
//    this.height = height * scale;
//  }

  CharacterInfo(this.angle, this.X, this.Y) {

  }
}

class Globals {
  Globals._privateConstructor() {

  }

  final double _charackterScale = 0.75;

  final double _characterWidth = 110.0;

  final double _charackterHeight = 110.0;


  static final Globals _instance = Globals._privateConstructor();

  factory Globals(){
    return _instance;
  }

  double _screenWidth, _screenHeight;

  double get screenWidth => _screenWidth;

  double get screenHeight => _screenHeight;

  double heroAngle = 0;

  void setScreenSizes(double screenWidth, double screenHeight) {
    _screenHeight = screenHeight;
    _screenWidth = screenWidth;
  }

  double get heroWidth => _characterWidth;

  double get heroHeight => _charackterHeight;

  double get heroScale => _charackterScale;
}