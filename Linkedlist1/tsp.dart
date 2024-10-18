import 'dart:collection';

class Graph {
  Map<String, Map<String, int>> adjList = {};

  void addNode(String node) {
    adjList[node] = {};
  }

  void addEdge(String node1, String node2, {required int weight}) {
    adjList[node1]?[node2] = weight;
    adjList[node2]?[node1] = weight; // For undirected graph
  }

  // Brute force all paths from start to start
  double findShortestCycle(String startNode) {
    List<String> nodes = adjList.keys.toList();
    List<List<String>> allPermutations = [];
    List<String> currentPath = [];
    Set<String> visited = {};

    void permute(List<String> nodesLeft) {
      if (nodesLeft.isEmpty) {
        allPermutations.add(List.from(currentPath));
      } else {
        for (int i = 0; i < nodesLeft.length; i++) {
          String nextNode = nodesLeft[i];

          // Skip if node has been visited
          if (!visited.contains(nextNode)) {
            visited.add(nextNode);
            currentPath.add(nextNode);

            // Recur with the remaining nodes
            permute(List.from(nodesLeft)..removeAt(i));

            // Backtrack
            currentPath.removeLast();
            visited.remove(nextNode);
          }
        }
      }
    }

    // Start permutation from nodes excluding startNode
    permute(nodes.where((n) => n != startNode).toList());

    double shortestDistance = double.infinity;
    List<String> bestRoute = [];

    // Check all permutations and calculate distances
    for (List<String> route in allPermutations) {
      double totalWeight = 0;
      String currentNode = startNode;

      // Go through the nodes in this route
      for (String nextNode in route) {
        if (adjList[currentNode]?[nextNode] != null) {
          totalWeight += adjList[currentNode]![nextNode]!;
          currentNode = nextNode;
        } else {
          totalWeight = double.infinity;
          break;
        }
      }

      // Back to the start node
      if (adjList[currentNode]?[startNode] != null) {
        totalWeight += adjList[currentNode]![startNode]!;
      } else {
        totalWeight = double.infinity;
      }

      // Update the shortest route if this one is better
      if (totalWeight < shortestDistance) {
        shortestDistance = totalWeight;
        bestRoute = route;
      }
    }

    // Display result
    print(
        "Shortest route: $startNode -> ${bestRoute.join(' -> ')} -> $startNode");
    print("Total distance: $shortestDistance");

    return shortestDistance;
  }
}

void main() {
  Graph graph = Graph();

  graph.addNode('A');
  graph.addNode('B');
  graph.addNode('C');
  graph.addNode('D');
  graph.addNode('E');

  graph.addEdge('A', 'B', weight: 8);
  graph.addEdge('A', 'C', weight: 10);
  graph.addEdge('B', 'D', weight: 2);
  graph.addEdge('B', 'E', weight: 3);
  graph.addEdge('C', 'D', weight: 4);
  graph.addEdge('C', 'E', weight: 6);
  graph.addEdge('D', 'E', weight: 7);
  graph.addEdge('D', 'A', weight: 9);
  graph.addEdge('E', 'B', weight: 5);

  // Find the shortest path starting and ending at different nodes

  print("Finding shortest cycle starting from A:");
  graph.findShortestCycle('A');

  print("Finding shortest cycle starting from B:");
  graph.findShortestCycle('B');

  print("\nFinding shortest cycle starting from C:");
  graph.findShortestCycle('C');

  print("\nFinding shortest cycle starting from D:");
  graph.findShortestCycle('D');

  print("\nFinding shortest cycle starting from E:");
  graph.findShortestCycle('E');
}
