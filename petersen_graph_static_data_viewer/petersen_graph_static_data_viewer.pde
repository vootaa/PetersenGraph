EnhancedDataReader dataReader;
PerformanceMonitor monitor;

void setup() {
  size(1400, 1000);
  background(255);
  
  // Initialize components
  String dataFile = "../petersen_graph_processing/static_data_exports/petersen_static_data_2025611_9258.json";
  println("Loading data from: " + dataFile);

  dataReader = new EnhancedDataReader(dataFile);
  monitor = new PerformanceMonitor();

  if (dataReader.reader.data == null) {
    println("ERROR: Data not loaded!");
    return;
  }
  
  // Print data statistics
  dataReader.printStatistics();
  
  // Draw all graphs
  drawAllGraphs();
  
  // Output performance summary
  monitor.printSummary();
}

void drawAllGraphs() {
  println("\n=== Drawing All Graphs ===");

  ArrayList<Node> testNodes = dataReader.getNodesByIndex();
  ArrayList<OriginalEdge> testEdges = dataReader.getOriginalEdgesByIndex();

  println("Loaded " + testNodes.size() + " nodes and " + testEdges.size() + " edges");

  if (testNodes.size() == 0) {
    println("ERROR: No nodes loaded!");
    return;
  }
  
  // a) Draw nodes and edges in index order
  drawGraphA();
  
  // b) Draw nodes and edges in polar order
  drawGraphB();
  
  // c) Draw nodes, intersections and edge segments in index order
  drawGraphC();
  
  // d) Draw nodes, intersections and edge segments in polar order
  drawGraphD();
  
  // e) Draw 1/5 data in polar order
  drawGraphE();
  
  // f) Performance comparison test
  performanceComparison();
}

void drawGraphA() {
  monitor.startTiming("Graph A - Index Order (Nodes + Edges)");
  
  ArrayList<Node> nodes = dataReader.getNodesByIndex();
  ArrayList<OriginalEdge> edges = dataReader.getOriginalEdgesByIndex();
  
  println("Drawing Graph A: " + nodes.size() + " nodes, " + edges.size() + " edges");
  
  GraphRenderer renderer = new GraphRenderer(200, 200, 100);
  renderer.drawTitle("A) Index Order - Nodes & Edges", 200, 180);
  
  renderer.drawOriginalEdges(edges);
  renderer.drawNodes(nodes);
  
  renderer.drawStats("Nodes: " + nodes.size() + ", Edges: " + edges.size(), 50, 350);
  
  monitor.endTiming("Graph A - Index Order (Nodes + Edges)");
}

void drawGraphB() {
  monitor.startTiming("Graph B - Polar Order (Nodes + Edges)");
  
  ArrayList<Node> nodes = dataReader.getNodesByPolar();
  ArrayList<OriginalEdge> edges = dataReader.getOriginalEdgesByPolar();
  
  println("Drawing Graph B: " + nodes.size() + " nodes, " + edges.size() + " edges");
  
  GraphRenderer renderer = new GraphRenderer(600, 200, 100);
  renderer.drawTitle("B) Polar Order - Nodes & Edges", 600, 180);
  
  renderer.drawOriginalEdges(edges);
  renderer.drawNodes(nodes);
  
  renderer.drawStats("Nodes: " + nodes.size() + ", Edges: " + edges.size(), 450, 350);
  
  monitor.endTiming("Graph B - Polar Order (Nodes + Edges)");
}

void drawGraphC() {
  monitor.startTiming("Graph C - Index Order (Nodes + Intersections + Segments)");
  
  ArrayList<Node> nodes = dataReader.getNodesByIndex();
  ArrayList<Intersection> intersections = dataReader.getIntersectionsByIndex();
  ArrayList<EdgeSegment> segments = dataReader.getSegmentsByIndex();
  
  println("Drawing Graph C: " + nodes.size() + " nodes, " + intersections.size() + " intersections, " + segments.size() + " segments");
  
  GraphRenderer renderer = new GraphRenderer(200, 600, 100);
  renderer.drawTitle("C) Index Order - Nodes, Intersections & Segments", 200, 580);
  
  renderer.drawEdgeSegments(segments);
  renderer.drawIntersections(intersections);
  renderer.drawNodes(nodes);
  
  renderer.drawStats("Nodes: " + nodes.size() + ", Intersections: " + intersections.size() + 
                    ", Segments: " + segments.size(), 50, 750);
  
  monitor.endTiming("Graph C - Index Order (Nodes + Intersections + Segments)");
}

void drawGraphD() {
  monitor.startTiming("Graph D - Polar Order (Nodes + Intersections + Segments)");
  
  ArrayList<Node> nodes = dataReader.getNodesByPolar();
  ArrayList<Intersection> intersections = dataReader.getIntersectionsByPolar();
  ArrayList<EdgeSegment> segments = dataReader.getSegmentsByPolar();
  
  println("Drawing Graph D: " + nodes.size() + " nodes, " + intersections.size() + " intersections, " + segments.size() + " segments");
  
  GraphRenderer renderer = new GraphRenderer(600, 600, 100);
  renderer.drawTitle("D) Polar Order - Nodes, Intersections & Segments", 600, 580);
  
  renderer.drawEdgeSegments(segments);
  renderer.drawIntersections(intersections);
  renderer.drawNodes(nodes);
  
  renderer.drawStats("Nodes: " + nodes.size() + ", Intersections: " + intersections.size() + 
                    ", Segments: " + segments.size(), 450, 750);
  
  monitor.endTiming("Graph D - Polar Order (Nodes + Intersections + Segments)");
}

void drawGraphE() {
  monitor.startTiming("Graph E - 1/5 Subset (Polar Order)");
  
  ArrayList<Node> allNodes = dataReader.getNodesByPolar();
  ArrayList<OriginalEdge> allEdges = dataReader.getOriginalEdgesByPolar();
  
  ArrayList<Node> subsetNodes = dataReader.getSubset(allNodes, 0.2);
  ArrayList<OriginalEdge> subsetEdges = dataReader.getSubset(allEdges, 0.2);
  
  println("Drawing Graph E: " + subsetNodes.size() + "/" + allNodes.size() + " nodes, " + subsetEdges.size() + "/" + allEdges.size() + " edges");
  
  GraphRenderer renderer = new GraphRenderer(1000, 400, 100);
  renderer.drawTitle("E) 1/5 Subset - Polar Order", 1000, 380);
  
  renderer.drawOriginalEdges(subsetEdges);
  renderer.drawNodes(subsetNodes);
  
  renderer.drawStats("Nodes: " + subsetNodes.size() + "/" + allNodes.size() + 
                    ", Edges: " + subsetEdges.size() + "/" + allEdges.size(), 850, 550);
  
  monitor.endTiming("Graph E - 1/5 Subset (Polar Order)");
}

void performanceComparison() {
  println("\n=== Performance Comparison Tests ===");
  
  // Test data loading performance
  monitor.startTiming("Data Loading - Index Order");
  ArrayList<Node> nodesIndex = dataReader.getNodesByIndex();
  ArrayList<OriginalEdge> edgesIndex = dataReader.getOriginalEdgesByIndex();
  monitor.endTiming("Data Loading - Index Order");
  
  monitor.startTiming("Data Loading - Polar Order");
  ArrayList<Node> nodesPolar = dataReader.getNodesByPolar();
  ArrayList<OriginalEdge> edgesPolar = dataReader.getOriginalEdgesByPolar();
  monitor.endTiming("Data Loading - Polar Order");
  
  // Test data processing performance
  monitor.startTiming("Coordinate Conversion - Index Order");
  for (Node node : nodesIndex) {
    PVector cart = node.getCartesian();
  }
  monitor.endTiming("Coordinate Conversion - Index Order");
  
  monitor.startTiming("Coordinate Conversion - Polar Order");
  for (Node node : nodesPolar) {
    PVector cart = node.getCartesian();
  }
  monitor.endTiming("Coordinate Conversion - Polar Order");
  
  // Test subset creation performance
  monitor.startTiming("Subset Creation - 1/5 data");
  ArrayList<Node> subset = dataReader.getSubset(nodesPolar, 0.2);
  monitor.endTiming("Subset Creation - 1/5 data");
  
  println("Performance comparison completed.");
}

void draw() {
  // Static drawing, no need for repeated drawing
}

void keyPressed() {
  if (key == ' ') {
    background(255);
    drawAllGraphs();
  }
}