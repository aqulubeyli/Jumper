import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:task_2/collisions_class/collision_wall.dart';

class Player extends PositionComponent with CollisionCallbacks {
  // Joystick to control the player
  final JoystickComponent joystick;
  Vector2 velocity = Vector2(0, 0);
  // Physics parameters
  final double _gravity = 980;
  final double _speed = 10;
  final double _jumpForce = 400;
  //
  bool isOnGround = false;

  Player({Vector2? position, required this.joystick})
    : super(position: position ?? Vector2.zero(), size: Vector2.all(64)) {
    // A simple square to represent the player
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.blue,
        position: position,
      ),
    );
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    velocity.y += _gravity * dt; // Apply gravity
    position += velocity * dt; // Update position based on velocity

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollision
    super.onCollision(intersectionPoints, other);
    if (other is CollisionWall) {
      if (velocity.x > 0) {
        // Collided while moving right
        isOnGround = true;
        position.x = other.position.x - size.x;
        velocity.x = 0;
      } else if (velocity.x < 0) {
        // Collided while moving left
        position.x = other.position.x + other.size.x;
        velocity.x = 0;
      }
    }
  }
}
