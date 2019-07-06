import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/vec2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_controls.dart';

class HeroAnimationController extends FlareControls {
  FlutterActorArtboard _artboard;
  ActorNode _hero;

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    super.advance(artboard, elapsed);
//    _hero.translation = Vec2D.add(Vec2D(), _hero.translation, Vec2D.fromValues(1, 1));
    return true;
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    super.initialize(artboard);
    _hero = artboard.getNode("Hero");
    _artboard = artboard;
    play("walk");
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  void start() {
    play("walk");
  }
}
