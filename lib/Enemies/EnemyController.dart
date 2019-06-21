import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/vec2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_controls.dart';

class EnemyController extends FlareControls {
  FlutterActorArtboard _artboard;
  ActorNode _enemy;

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    super.advance(artboard, elapsed);
//    _enemy.translation = Vec2D.add(Vec2D(), _enemy.translation, Vec2D.fromValues(1, 1));

    return true;
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    super.initialize(artboard);
    _enemy = artboard.getNode("Hero");
    _artboard = artboard;
//    play("walk");
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

}