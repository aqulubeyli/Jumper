import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent {
  Player({Vector2? position})
    : super(position: position ?? Vector2.zero(), size: Vector2.all(64)) {
    // A simple square to represent the player
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.blue,
        position: position,
      ),
    );
  }

  @override
  void update(double dt) {
    // position.x += 50 * dt; // Move right at 50 pixels per second
    super.update(dt);
  }
}
