# Petersen Graph Visualization Project

This project visualizes the Petersen Graph using Processing. The Petersen Graph is a well-known mathematical graph structure consisting of 20 vertices and 30 edges, serving as a fundamental example in graph theory.

## Project Structure

The project is organized into the following files:

- **petersen_graph_processing/petersen_graph_processing.pde**: The main entry point for the Processing sketch. It initializes the sketch, sets up the canvas, and calls the rendering functions.
  
- **petersen_graph_processing/PetersenGraph.pde**: Defines the `PetersenGraph` class, which contains methods for creating the graph structure, including nodes and edges based on the specifications.
  
- **petersen_graph_processing/Node.pde**: Defines the `Node` class, representing individual nodes in the graph. It includes properties for position, color, and methods for displaying the node.
  
- **petersen_graph_processing/Edge.pde**: Defines the `Edge` class, representing the connections between nodes. It includes properties for the two nodes it connects and methods for drawing the edge.
  
- **petersen_graph_processing/GraphRenderer.pde**: Contains the `GraphRenderer` class, which handles the visualization of the Petersen Graph. It includes methods for rendering nodes and edges, applying colors, and managing the overall layout.
  
- **data/config.json**: Contains configuration settings for the visualization, such as node colors, edge colors, and radius settings for the circles.

## Running the Sketch

To run the Processing sketch:

1. Open the `petersen_graph_processing.pde` file in the Processing IDE.
2. Click the "Run" button to start the visualization.
3. Observe the Petersen Graph rendered on the canvas.

## Visualization Features

- The graph is displayed with three concentric circles representing different layers of nodes.
- Nodes are color-coded based on their layer:
  - Middle Circle Nodes: Red
  - Inner Circle Nodes: Blue
  - Outer Circle Nodes: Yellow
- Edges are color-coded based on their connection type for clarity.
- The visualization maintains the graph's structural properties and symmetry.

## Mathematical Significance

The Petersen Graph is notable for being:

- The smallest bridgeless cubic graph with no Hamiltonian path.
- A counterexample to several graph theory conjectures.
- A fundamental example in algebraic graph theory.

This project aims to provide an interactive and educational visualization of the Petersen Graph, showcasing its unique properties and structure.
