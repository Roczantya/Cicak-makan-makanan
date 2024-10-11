import 'dart:io';
import 'dart:async';
import 'dart:math';

class Snake {
  List<Point<int>> body; // Body of the snake
  Point<int> food; // Position of the food
  String direction; // Direction of movement
  bool isAlive; // Snake's status
  int width; // Width of the game area
  int height; // Height of the game area

  Snake(this.width, this.height)
      : body = [Point(5, 5)], // Initial position of the snake
        food = Point(
            Random().nextInt(width - 2) + 1, Random().nextInt(height - 2) + 1),
        direction = 'RIGHT',
        isAlive = true;

  void move() {
    if (!isAlive) return; // If snake is dead, do not move

    Point<int> newHead; // New head position

    // Determine the new head position based on the current direction
    switch (direction) {
      case 'UP':
        newHead = Point(body.first.x, body.first.y - 1);
        break;
      case 'DOWN':
        newHead = Point(body.first.x, body.first.y + 1);
        break;
      case 'LEFT':
        newHead = Point(body.first.x - 1, body.first.y);
        break;
      case 'RIGHT':
        newHead = Point(body.first.x + 1, body.first.y);
        break;
      default:
        newHead = body.first; // If direction is invalid, stay in current position
    }

    // Check if the snake eats the food
    if (newHead == food) {
      body.insert(0, newHead); // Add new head
      spawnFood(); // Spawn new food
    } else {
      // If not eating food, move the snake
      body.insert(0, newHead); // Add new head
      body.removeLast(); // Remove the last part (snake movement)
    }

    // Check if the snake is dead
    if (body.sublist(1).contains(newHead) ||
        newHead.x < 0 ||
        newHead.y < 0 ||
        newHead.x >= width ||
        newHead.y >= height) {
      isAlive = false; // If it crashes into itself or goes out of bounds
    }
  }

  void spawnFood() {
    do {
      food = Point(
          Random().nextInt(width - 2) + 1, Random().nextInt(height - 2) + 1);
    } while (body.contains(food)); // Ensure food doesn't spawn on the snake
  }

  void changeDirection(String newDirection) {
    // Prevent the snake from reversing into itself
    if ((newDirection == 'UP' && direction != 'DOWN') ||
        (newDirection == 'DOWN' && direction != 'UP') ||
        (newDirection == 'LEFT' && direction != 'RIGHT') ||
        (newDirection == 'RIGHT' && direction != 'LEFT')) {
      direction = newDirection; // Change movement direction
    }
  }

  void draw() {
    // Clear the terminal content
    stdout.write('\x1B[2J\x1B[0;0H');

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (body.isNotEmpty && body.first == Point(x, y)) {
          stdout.write('O'); // Head
        } else if (body.contains(Point(x, y))) {
          stdout.write('#'); // Body
        } else if (food == Point(x, y)) {
          stdout.write('🍎'); // Food
        } else {
          stdout.write(' '); // Empty space
        }
      }
      print(''); // Move to the next line
    }
  }

  // Function to get terminal size
  static Point<int> getTerminalSize() {
    int width = 80; // Default width
    int height = 24; // Default height

    try {
      final size = stdout.hasTerminal ? stdout.terminalColumns : width;
      width = size; // Set width if successful
      height = stdout.hasTerminal ? stdout.terminalLines : height; // Set height
    } catch (e) {
      print('Unable to get terminal size, using default size.');
    }

    return Point(width, height); // Return as Point
  }
}

void main() async {
  // Hide the cursor
  stdout.write('\x1B[?25l');

  // Get terminal dimensions
  Point<int> terminalSize = Snake.getTerminalSize();
  int terminalWidth = terminalSize.x; // Terminal width
  int terminalHeight = terminalSize.y; // Terminal height

  // Adjust for minimum dimensions
  terminalWidth = terminalWidth < 5 ? 5 : terminalWidth; // Minimum width
  terminalHeight = terminalHeight < 5 ? 5 : terminalHeight; // Minimum height

  // Create Snake object with terminal width and height
  Snake snake = Snake(terminalWidth, terminalHeight);
  stdin.echoMode = false;
  stdin.lineMode = false;

  // Function to read user input separately
  Future<void> readInput() async {
    while (snake.isAlive) {
      if (stdin.hasTerminal) {
        String input = stdin.readByteSync().toString(); // Read input from user
        if (input.isNotEmpty) {
          switch (input.toUpperCase()) {
            case 'W':
              snake.changeDirection('UP'); // Change direction up
              break;
            case 'S':
              snake.changeDirection('DOWN'); // Change direction down
              break;
            case 'A':
              snake.changeDirection('LEFT'); // Change direction left
              break;
            case 'D':
              snake.changeDirection('RIGHT'); // Change direction right
              break;
          }
        }
      }
      await Future.delayed(Duration(milliseconds: 50)); // Adjusted delay for smoother input reading
    }
  }

  // Run the input reading function in the background
  readInput();

  // Game loop
  Timer.periodic(Duration(milliseconds: 100), (timer) { // Faster movement speed
    if (snake.isAlive) {
      snake.move(); // Move the snake according to its current direction
      snake.draw(); // Draw the snake and food
    } else {
      timer.cancel(); // Stop the timer if the snake is dead
    }
  });

  // Clear the screen before displaying Game Over
  stdout.write('\x1B[2J\x1B[0;0H');
  print('Game Over! The snake is dead!');

  // Show the cursor again after game over
  stdout.write('\x1B[?25h');
}
