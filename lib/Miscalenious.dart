import 'package:flare_dart/math/vec2d.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';

enum FootState {
  Stand, Walk, Marathon, Sprint
}

enum GestCommand {
  LeftHandPunch, LeftFootPunch, RightHandPunch, RightFootPunch,
  SlowDown, SpeedUp
}

enum Familly {
  PiS, Geje, Legia, Ciapaci, Lanister, Avengers
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
  String name;
  Familly familly;
  FlareActor flareActor;

//  CharacterInfo(double width, double height, double this.scale) {
//    this.width = width * scale;
//    this.height = height * scale;
//  }

  CharacterInfo(this.angle, this.X, this.Y, this.name, this.flareActor, this.familly) {}
}

class HatedObject extends Comparable<HatedObject>{
  CharacterInfo enemy;
  int hatedLevel = 0;

  HatedObject(CharacterInfo enemy, int level) {
    this.hatedLevel = level;
    this.enemy = enemy;
  }

  @override
  int compareTo(HatedObject other) {
    if (other.hatedLevel < this.hatedLevel) return 0;
    else return 1;
  }
}

class Globals {
  Vec2D heroPosOnMap;
  CharacterInfo hero;

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
    hero.Y = (Globals().screenHeight / 2);
    hero.X = (Globals().screenWidth / 2);
  }

  double get heroWidth => _characterWidth;

  double get heroHeight => _charackterHeight;

  double get heroScale => _charackterScale;
}