class PetersenGraph {
  Node[] nodes;
  Edge[] edges;
  JSONObject config;
  
  float innerRadius;
  float middleRadius;
  float outerRadius;
  float nodeSize;
  float lineWidth;

  PetersenGraph(JSONObject config) {
    this.config = config;
    
    // Load configuration values
    JSONObject radii = config.getJSONObject("radii");
    innerRadius = radii.getFloat("innerRadius");
    middleRadius = radii.getFloat("middleRadius");
    outerRadius = radii.getFloat("outerRadius");
    nodeSize = config.getFloat("nodeSize");
    lineWidth = config.getFloat("lineWidth");
    
    nodes = new Node[20];
    edges = new Edge[30];
    
    createNodes();
    createEdges();
  }

  void createNodes() {
    JSONObject nodeColors = config.getJSONObject("nodeColors");
    
    // Create middle circle nodes (Chain IDs 0-4)
    JSONArray middleColor = nodeColors.getJSONObject("middleCircle").getJSONArray("rgb");
    color middleNodeColor = color(middleColor.getInt(0), middleColor.getInt(1), middleColor.getInt(2));
    
    // Specific angles from specification (in radians)
    float[] middleAngles = {5.0265, 0.0, 1.2566, 2.5133, 3.7699};
    for (int i = 0; i < 5; i++) {
      float x = cos(middleAngles[i]) * middleRadius;
      float y = sin(middleAngles[i]) * middleRadius;
      nodes[i] = new Node(x, y, middleNodeColor, nodeSize, i);
    }

    // Create inner circle nodes (Chain IDs 5-9)
    JSONArray innerColor = nodeColors.getJSONObject("innerCircle").getJSONArray("rgb");
    color innerNodeColor = color(innerColor.getInt(0), innerColor.getInt(1), innerColor.getInt(2));
    
    for (int i = 0; i < 5; i++) {
      float x = cos(middleAngles[i]) * innerRadius;
      float y = sin(middleAngles[i]) * innerRadius;
      nodes[i + 5] = new Node(x, y, innerNodeColor, nodeSize, i + 5);
    }

    // Create outer circle nodes (Chain IDs 10-19)
    JSONArray outerColor = nodeColors.getJSONObject("outerCircle").getJSONArray("rgb");
    color outerNodeColor = color(outerColor.getInt(0), outerColor.getInt(1), outerColor.getInt(2));
    
    // Specific outer angles from specification
    float[] outerAngles = {4.8521, 0.1745, 1.0821, 2.6878, 3.5954, 5.2009, 6.1087, 1.4312, 2.3387, 3.9444};
    for (int i = 0; i < 10; i++) {
      float x = cos(outerAngles[i]) * outerRadius;
      float y = sin(outerAngles[i]) * outerRadius;
      nodes[i + 10] = new Node(x, y, outerNodeColor, nodeSize, i + 10);
    }
  }

  void createEdges() {
    int index = 0;
    JSONObject edgeColors = config.getJSONObject("edgeColors");

    // Type 0: Middle to Inner connections (5 connections)
    JSONArray middleToInnerColor = edgeColors.getJSONObject("middleToInner").getJSONArray("rgb");
    color type0Color = color(middleToInnerColor.getInt(0), middleToInnerColor.getInt(1), middleToInnerColor.getInt(2));
    
    for (int i = 0; i < 5; i++) {
      edges[index++] = new Edge(nodes[i], nodes[i + 5], type0Color, lineWidth);
    }

    // Type 1: Middle to Outer Pattern A (5 connections)
    JSONArray middleToOuterAColor = edgeColors.getJSONObject("middleToOuterA").getJSONArray("rgb");
    color type1Color = color(middleToOuterAColor.getInt(0), middleToOuterAColor.getInt(1), middleToOuterAColor.getInt(2));
    
    for (int i = 0; i < 5; i++) {
      edges[index++] = new Edge(nodes[i], nodes[i + 10], type1Color, lineWidth);
    }

    // Type 2: Middle to Outer Pattern B (5 connections)
    JSONArray middleToOuterBColor = edgeColors.getJSONObject("middleToOuterB").getJSONArray("rgb");
    color type2Color = color(middleToOuterBColor.getInt(0), middleToOuterBColor.getInt(1), middleToOuterBColor.getInt(2));
    
    for (int i = 0; i < 5; i++) {
      edges[index++] = new Edge(nodes[i], nodes[i + 15], type2Color, lineWidth);
    }

    // Type 3: Inner Circle Connections (5 connections) - Pentagram pattern
    JSONArray innerCircleColor = edgeColors.getJSONObject("innerCircle").getJSONArray("rgb");
    color type3Color = color(innerCircleColor.getInt(0), innerCircleColor.getInt(1), innerCircleColor.getInt(2));
    
    // Connections: (5→7), (6→8), (7→9), (8→5), (9→6)
    edges[index++] = new Edge(nodes[5], nodes[7], type3Color, lineWidth);
    edges[index++] = new Edge(nodes[6], nodes[8], type3Color, lineWidth);
    edges[index++] = new Edge(nodes[7], nodes[9], type3Color, lineWidth);
    edges[index++] = new Edge(nodes[8], nodes[5], type3Color, lineWidth);
    edges[index++] = new Edge(nodes[9], nodes[6], type3Color, lineWidth);

    // Type 4: Outer Circle Connections (10 connections)
    JSONArray outerCircleColor = edgeColors.getJSONObject("outerCircle").getJSONArray("rgb");
    color type4Color = color(outerCircleColor.getInt(0), outerCircleColor.getInt(1), outerCircleColor.getInt(2));
    
    for (int i = 0; i < 10; i++) {
      edges[index++] = new Edge(nodes[i + 10], nodes[((i + 1) % 10) + 10], type4Color, lineWidth);
    }
  }

  void display() {
    float scale = config.getFloat("canvasScale");
    
    // Draw edges first (so they appear behind nodes)
    for (Edge edge : edges) {
      edge.display(scale);
    }
    
    // Draw nodes on top
    for (Node node : nodes) {
      node.display(scale);
    }
  }
}