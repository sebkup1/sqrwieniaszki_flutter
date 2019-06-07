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