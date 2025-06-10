/**
 * Petersen Graph implementation - Fixed angle mapping
 */
class PetersenGraph {
  ArrayList<Node> nodes;
  ArrayList<Edge> edges;
  JSONObject config;
  
  float[] ANGLES = {
    // Middle circle (chainId 0-4)
    5.0265, 0.0, 1.2566, 2.5133, 3.7699,
    // Inner circle (chainId 5-9)
    5.0265, 0.0, 1.2566, 2.5133, 3.7699,
    // Outer circle (chainId 10-19)
    4.8521, 0.1745, 1.0821, 2.6878, 3.5954, 
    5.2009, 6.1087, 1.4312, 2.3387, 3.9444
  };
  
  // Exact connections from GLSL
  int[][] CONNECTIONS = {
    // Middle to inner (+5 pattern)
    {0, 5}, {1, 6}, {2, 7}, {3, 8}, {4, 9},
    // Middle to outer (+10 pattern)
    {0, 10}, {1, 11}, {2, 12}, {3, 13}, {4, 14},
    // Middle to outer (+15 pattern)
    {0, 15}, {1, 16}, {2, 17}, {3, 18}, {4, 19},
    // Inner circle connections
    {5, 7}, {6, 8}, {7, 9}, {8, 5}, {9, 6},
    // Outer circle connections
    {10, 11}, {11, 12}, {12, 13}, {13, 14}, {14, 15}, 
    {15, 16}, {16, 17}, {17, 18}, {18, 19}, {19, 10}
  };
  
  // Connection types for coloring
  int[] CONN_TYPE = {
    0, 0, 0, 0, 0,  // Middle to inner
    1, 1, 1, 1, 1,  // Middle to outer (+10)
    2, 2, 2, 2, 2,  // Middle to outer (+15)
    3, 3, 3, 3, 3,  // Inner circle
    4, 4, 4, 4, 4, 4, 4, 4, 4, 4  // Outer circle
  };
  
  PetersenGraph(JSONObject config) {
    this.config = config;
    this.nodes = new ArrayList<Node>();
    this.edges = new ArrayList<Edge>();
    
    initializeGraph();
  }
  
  void initializeGraph() {
    createNodes();
    createEdges();
    printNodePositions();
  }
  
  void createNodes() {
    JSONObject nodeConfig = config.getJSONObject("nodes");
    JSONObject radiusConfig = nodeConfig.getJSONObject("radius");
    JSONObject colorConfig = nodeConfig.getJSONObject("colors");
    
    float innerRadius = radiusConfig.getFloat("inner");
    float middleRadius = radiusConfig.getFloat("middle");
    float outerRadius = radiusConfig.getFloat("outer");
    float nodeSize = nodeConfig.getFloat("size");
    
    // Create all 20 nodes using exact GLSL positioning
    for (int i = 0; i < 20; i++) {
      float angle = ANGLES[i];
      float radius;
      float[] nodeColor;
      
      // Determine radius and color based on chainId
      if (i < 5) {
        // Middle circle (chainId 0-4)
        radius = middleRadius;
        JSONArray middleColors = colorConfig.getJSONArray("middle");
        nodeColor = new float[]{middleColors.getFloat(0), middleColors.getFloat(1), middleColors.getFloat(2)};
      } else if (i < 10) {
        // Inner circle (chainId 5-9)
        radius = innerRadius;
        JSONArray innerColors = colorConfig.getJSONArray("inner");
        nodeColor = new float[]{innerColors.getFloat(0), innerColors.getFloat(1), innerColors.getFloat(2)};
      } else {
        // Outer circle (chainId 10-19)
        radius = outerRadius;
        JSONArray outerColors = colorConfig.getJSONArray("outer");
        nodeColor = new float[]{outerColors.getFloat(0), outerColors.getFloat(1), outerColors.getFloat(2)};
      }
      
      float x = cos(angle) * radius;
      float y = sin(angle) * radius;
      
      nodes.add(new Node(i, x, y, nodeColor[0], nodeColor[1], nodeColor[2], nodeSize));
    }
    
    println("Created " + nodes.size() + " nodes");
  }
  
  void printNodePositions() {
    println("\n--- NODE POSITIONS DEBUG ---");
    for (int i = 0; i < nodes.size(); i++) {
      Node node = nodes.get(i);
      float angle = ANGLES[i];
      println(String.format("Node %2d: angle=%.4f, pos=(%.4f, %.4f)", 
                           i, angle, node.x, node.y));
    }
    
    println("\n--- CONNECTION VERIFICATION ---");
    println("Middle to Outer Type 1 connections:");
    for (int i = 0; i < 5; i++) {
      Node middle = nodes.get(i);
      Node outer = nodes.get(i + 10);
      println(String.format("  %d→%d: Middle(%.4f,%.4f) to Outer(%.4f,%.4f)", 
                           i, i+10, middle.x, middle.y, outer.x, outer.y));
    }
    
    println("Middle to Outer Type 2 connections:");
    for (int i = 0; i < 5; i++) {
      Node middle = nodes.get(i);
      Node outer = nodes.get(i + 15);
      println(String.format("  %d→%d: Middle(%.4f,%.4f) to Outer(%.4f,%.4f)", 
                           i, i+15, middle.x, middle.y, outer.x, outer.y));
    }
  }
  
  void createEdges() {
    JSONObject edgeConfig = config.getJSONObject("edges");
    JSONObject colorConfig = edgeConfig.getJSONObject("colors");
    float thickness = edgeConfig.getFloat("thickness");
    
    // Color arrays for each connection type
    JSONArray[] typeColors = {
      colorConfig.getJSONArray("type0"),
      colorConfig.getJSONArray("type1"),
      colorConfig.getJSONArray("type2"),
      colorConfig.getJSONArray("type3"),
      colorConfig.getJSONArray("type4")
    };
    
    // Create all 30 connections exactly as in GLSL
    for (int i = 0; i < CONNECTIONS.length; i++) {
      int fromId = CONNECTIONS[i][0];
      int toId = CONNECTIONS[i][1];
      int connType = CONN_TYPE[i];
      
      Node from = nodes.get(fromId);
      Node to = nodes.get(toId);
      JSONArray colors = typeColors[connType];
      
      edges.add(new Edge(i, from, to, connType, 
                        colors.getFloat(0), 
                        colors.getFloat(1), 
                        colors.getFloat(2), 
                        thickness));
    }
    
    println("Created " + edges.size() + " edges");
    
    // Verify connection counts by type
    int[] typeCounts = new int[5];
    for (Edge edge : edges) {
      typeCounts[edge.type]++;
    }
    println("Type counts: " + typeCounts[0] + ", " + typeCounts[1] + ", " + typeCounts[2] + ", " + typeCounts[3] + ", " + typeCounts[4]);
  }
  
  void display() {
    pushMatrix();
    
    translate(width/2, height/2);
    scale(min(width, height) * 0.9);
    
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