import 'dart:async';
import 'dart:io';
import 'dart:math';

enum Direction { up, down, left, right }

class SnakeGame {
  List<Point<int>> snake = [Point(10, 10)];
  Point<int> food = Point(5, 5);
  Direction direction = Direction.right;
  bool gameOver = false;
  late int width;
  late int height;

  SnakeGame(this.width, this.height) {
    _placeFood();
  }

  void start() {
    stdout.write('\x1B[?25l'); // Hides the cursor
    stdin.echoMode = false; // Disable echo for input
    stdin.lineMode = false; // Disable line mode to receive characters directly

    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (gameOver) {
        timer.cancel();
        stdout.write('\x1B[?25h'); // Shows the cursor back
        _clearScreen(); // Clear screen before showing Game Over
        print('Game Over! Final Score: ${snake.length - 1}');
      } else {
        _update();
        _render();
      }
    });

    // Asynchronous input handling
    stdin.listen((List<int> data) {
      _handleInput(String.fromCharCodes(data).trim());
    });
  }

  void _placeFood() {
    final random = Random();
    do {
      food = Point(random.nextInt(width), random.nextInt(height));
    } while (snake.contains(food)); // Ensure food doesn't spawn on the snake
  }

  void _handleInput(String input) {
    switch (input) {
      case 'w':
        if (direction != Direction.down) direction = Direction.up;
        break;
      case 's':
        if (direction != Direction.up) direction = Direction.down;
        break;
      case 'a':
        if (direction != Direction.right) direction = Direction.left;
        break;
      case 'd':
        if (direction != Direction.left) direction = Direction.right;
        break;
    }
  }

  void _update() {
    Point<int> newHead;
    switch (direction) {
      case Direction.up:
        newHead = Point(snake.first.x, snake.first.y - 1);
        break;
      case Direction.down:
        newHead = Point(snake.first.x, snake.first.y + 1);
        break;
      case Direction.left:
        newHead = Point(snake.first.x - 1, snake.first.y);
        break;
      case Direction.right:
        newHead = Point(snake.first.x + 1, snake.first.y);
        break;
    }

    // Check if the snake hits the wall
    if (newHead.x < 0 ||
        newHead.y < 0 ||
        newHead.x >= width ||
        newHead.y >= height ||
        snake.contains(newHead)) {
      gameOver = true;
      return;
    }

    // Insert the new head of the snake
    snake.insert(0, newHead);

    // Check if the snake eats the food
    if (newHead == food) {
      _placeFood(); // If it eats the food, place new food
    } else {
      snake.removeLast(); // Remove tail if not eating
    }
  }

  void _render() {
    stdout.write('\x1B[H'); // Move cursor to top left corner

    // Clear screen without removing the cursor
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (snake.first == Point(x, y)) {
          stdout.write('*'); // Head of the snake (kadal)
        } else if (snake.contains(Point(x, y))) {
          stdout.write('* *'); // Body of the snake (kadal)
        } else if (food == Point(x, y)) {
          stdout.write('🍎'); // Food
        } else {
          stdout.write(' '); // Empty space (space)
        }
      }
      stdout.writeln();
    }
    stdout.writeln('Score: ${snake.length - 1}');
  }

  void _clearScreen() {
    stdout.write('\x1B[2J'); // Clear terminal screen
    stdout.write('\x1B[H'); // Move cursor to top left corner
  }
}

void main() {
  print('Start Snake Game! Control the snake with WASD keys.');
  final width =
      stdout.terminalColumns - 1; // Reduce by 1 to avoid terminal limits
  final height = stdout.terminalLines - 2; // Reduce line for score
  final game = SnakeGame(width, height);
  game.start();
}
