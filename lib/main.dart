import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:task_2/collisions_block.dart';
import 'package:task_2/player.dart';

void main() {
  runApp(GameWidget(game: Task2Game()));
}

class Task2Game extends FlameGame {
  late TiledComponent map;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    debugMode = true;

    final player = Player();
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

    final layer = map.tileMap.getLayer<ObjectGroup>('collisions');

    if (layer != null) {
      // 2. Создаем компоненты коллизий
      for (final obj in layer.objects) {
        world.add(
          // Используем наш собственный класс CollisionBlock,
          // чтобы избежать ошибки с TiledObject.
          CollisionBlock(obj),
        );
      }
    } else {
      print('ПРЕДУПРЕЖДЕНИЕ: Объектный слой "collisions" не найден.');
    }

    world.add(player);

    // camera.viewfinder.anchor = Anchor.center;
    camera.follow(player);
    camera.setBounds(Rectangle.fromLTWH(0, 0, map.width, map.height));
    return super.onLoad();
  }
}
