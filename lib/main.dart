import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:task_2/collisions_class/collision_ground.dart';
import 'package:task_2/collisions_class/collision_wall.dart';
import 'package:task_2/collisions_class/collision_platforma.dart';
import 'package:task_2/player.dart';

void main() {
  runApp(GameWidget(game: Task2Game()));
}

class Task2Game extends FlameGame with HasCollisionDetection {
  late final JoystickComponent joystick;
  late final Player player;

  late TiledComponent map;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    debugMode = true;

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.white),
      background: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.black12,
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    // final player = Player();
    player = Player(position: Vector2.zero(), joystick: joystick);

    // player.anchor = Anchor.topLeft;
    map = await TiledComponent.load('level1.tmx', Vector2.all(64));
    world.add(map);

    try {
      final spawnpoints = map.tileMap.getLayer<ObjectGroup>('spawnpoints');
      for (final point in spawnpoints!.objects) {
        if (point.name == 'player') {
          player.position = Vector2(point.x, point.y);
          break;
        } else {
          print("Unknown spawnpoint not handlerd");
        }
      }
    } on Exception catch (e) {
      print(" Error loading spawnpoints: $e");
    }

    final wall = map.tileMap.getLayer<ObjectGroup>('collision_wall');
    final platforma = map.tileMap.getLayer<ObjectGroup>('collision_platforma');
    final ground = map.tileMap.getLayer<ObjectGroup>('collision_ground');

    if (wall != null) {
      for (final obj in wall.objects) {
        world.add(CollisionWall(obj));
      }
    } else {
      print('Warning: Object leayer "collision_wall" не найден.');
    }

    if (platforma != null) {
      for (final obj in platforma.objects) {
        world.add(CollisionPlatforma(obj));
      }
    } else {
      print('Warning: Object leayer "collision_platforma" не найден.');
    }

    if (ground != null) {
      for (final obj in ground.objects) {
        world.add(CollisionGround(obj));
      }
    } else {
      print('Warning: Object leayer "collision_ground" не найден.');
    }

    world.add(player);

    // camera.viewfinder.anchor = Anchor.center;
    camera.follow(player);
    camera.setBounds(Rectangle.fromLTWH(0, 0, map.width, map.height));

    camera.viewport.add(joystick);
    return super.onLoad();
  }
}
