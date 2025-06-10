/**
 * Petersen Graph implementation
 */
class PetersenGraph {
  ArrayList<Node> nodes;
  ArrayList<Edge> edges;
  JSONObject config;
  
  PetersenGraph(JSONObject config) {
    this.config = config;
    this.nodes = new ArrayList<Node>();
    this.edges = new ArrayList<Edge>();
    
    initializeGraph();
  }
  
  void initializeGraph() {
    createNodes();
    createEdges();
  }
  
  void createNodes() {
    JSONObject nodeConfig = config.getJSONObject("nodes");
    JSONObject radiusConfig = nodeConfig.getJSONObject("radius");
    JSONObject colorConfig = nodeConfig.getJSONObject("colors");
    
    float innerRadius = radiusConfig.getFloat("inner");
    float middleRadius = radiusConfig.getFloat("middle");
    float outerRadius = radiusConfig.getFloat("outer");
    float nodeSize = nodeConfig.getFloat("size");
    
    // Create middle circle nodes (Chain IDs 0-4)
    JSONArray middleColors = colorConfig.getJSONArray("middle");
    for (int i = 0; i < 5; i++) {
      float angle = i * TWO_PI / 5.0;
      float x = cos(angle) * middleRadius;
      float y = sin(angle) * middleRadius;
      nodes.add(new Node(i, x, y, 
                        middleColors.getFloat(0), 
                        middleColors.getFloat(1), 
                        middleColors.getFloat(2), 
                        nodeSize));
    }
    
    // Create inner circle nodes (Chain IDs 5-9)
    JSONArray innerColors = colorConfig.getJSONArray("inner");
    for (int i = 0; i < 5; i++) {
      float angle = i * TWO_PI / 5.0;
      float x = cos(angle) * innerRadius;
      float y = sin(angle) * innerRadius;
      nodes.add(new Node(i + 5, x, y, 
                        innerColors.getFloat(0), 
                        innerColors.getFloat(1), 
                        innerColors.getFloat(2), 
                        nodeSize));
    }
    
    // Create outer circle nodes (Chain IDs 10-19)
    JSONArray outerColors = colorConfig.getJSONArray("outer");
    JSONArray outerAngles = nodeConfig.getJSONArray("outerAngles");
    for (int i = 0; i < 10; i++) {
      float angle = outerAngles.getFloat(i);
      float x = cos(angle) * outerRadius;
      float y = sin(angle) * outerRadius;
      nodes.add(new Node(i + 10, x, y, 
                        outerColors.getFloat(0), 
                        outerColors.getFloat(1), 
                        outerColors.getFloat(2), 
                        nodeSize));
    }
  }
  
  void createEdges() {
    JSONObject edgeConfig = config.getJSONObject("edges");
    JSONObject colorConfig = edgeConfig.getJSONObject("colors");
    float thickness = edgeConfig.getFloat("thickness");
    
    // Type 0: Middle to Inner (5 connections)
    // Connections: (0→5), (1→6), (2→7), (3→8), (4→9)
    JSONArray type0Colors = colorConfig.getJSONArray("type0");
    for (int i = 0; i < 5; i++) {
      Node from = nodes.get(i);      // Middle circle
      Node to = nodes.get(i + 5);    // Inner circle
      edges.add(new Edge(from, to, 0, 
                        type0Colors.getFloat(0), 
                        type0Colors.getFloat(1), 
                        type0Colors.getFloat(2), 
                        thickness));
    }
    
    // Type 1: Middle to Outer Pattern A (5 connections)
    // Connections: (0→10), (1→11), (2→12), (3→13), (4→14)
    JSONArray type1Colors = colorConfig.getJSONArray("type1");
    for (int i = 0; i < 5; i++) {
      Node from = nodes.get(i);       // Middle circle (0-4)
      Node to = nodes.get(10 + i);    // Outer circle (10-14)
      edges.add(new Edge(from, to, 1, 
                        type1Colors.getFloat(0), 
                        type1Colors.getFloat(1), 
                        type1Colors.getFloat(2), 
                        thickness));
    }
    
    // Type 2: Middle to Outer Pattern B (5 connections)
    // Connections: (0→15), (1→16), (2→17), (3→18), (4→19)
    JSONArray type2Colors = colorConfig.getJSONArray("type2");
    for (int i = 0; i < 5; i++) {
      Node from = nodes.get(i);       // Middle circle (0-4)
      Node to = nodes.get(15 + i);    // Outer circle (15-19)
      edges.add(new Edge(from, to, 2, 
                        type2Colors.getFloat(0), 
                        type2Colors.getFloat(1), 
                        type2Colors.getFloat(2), 
                        thickness));
    }
    
    // Type 3: Inner Circle Connections (5 connections) - FIXED PENTAGRAM PATTERN
    // According to spec: (5→7), (6→8), (7→9), (8→5), (9→6)
    // This creates a pentagram (star) pattern, not a simple +2 pattern
    JSONArray type3Colors = colorConfig.getJSONArray("type3");
    int[] innerConnections = {
      7,  // Node 5 connects to Node 7
      8,  // Node 6 connects to Node 8  
      9,  // Node 7 connects to Node 9
      5,  // Node 8 connects to Node 5
      6   // Node 9 connects to Node 6
    };
    
    for (int i = 0; i < 5; i++) {
      Node from = nodes.get(i + 5);                    // Inner circle nodes (5-9)
      Node to = nodes.get(innerConnections[i]);        // Target nodes for pentagram
      edges.add(new Edge(from, to, 3, 
                        type3Colors.getFloat(0), 
                        type3Colors.getFloat(1), 
                        type3Colors.getFloat(2), 
                        thickness));
    }
    
    // Type 4: Outer Circle Connections (10 connections) - Sequential loop
    // Connections: (10→11), (11→12), (12→13), (13→14), (14→15), (15→16), (16→17), (17→18), (18→19), (19→10)
    JSONArray type4Colors = colorConfig.getJSONArray("type4");
    for (int i = 0; i < 10; i++) {
      Node from = nodes.get(i + 10);              // Outer circle
      Node to = nodes.get(((i + 1) % 10) + 10);   // Next outer node with wrap
      edges.add(new Edge(from, to, 4, 
                        type4Colors.getFloat(0), 
                        type4Colors.getFloat(1), 
                        type4Colors.getFloat(2), 
                        thickness));
    }
  }
  
  void display() {
    pushMatrix();
    
    // Center and scale to 90% of screen (increased size)
    translate(width/2, height/2);
    scale(min(width, height) * 0.9); // 90% coverage

    // Draw edges first (behind nodes)
    for (Edge edge : edges) {
      edge.display();
    }
    
    // Draw nodes on top
    for (Node node : nodes) {
      node.display();
    }
    
    popMatrix();
  }
}