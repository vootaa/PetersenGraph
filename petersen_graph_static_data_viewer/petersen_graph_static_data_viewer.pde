EnhancedDataReader dataReader;
PerformanceMonitor monitor;

void setup() {
  size(1400, 1000);
  colorMode(RGB, 255);
  background(245, 245, 250); //  Light gray background
  
  println("Petersen Graph Static Data Viewer");
  println("Window size: " + width + "x" + height);
  
  // Initialize components
  String dataFile = "../petersen_graph_processing/static_data_exports/petersen_static_data_2025611_9258.json";
  println("Loading data from: " + dataFile);

  dataReader = new EnhancedDataReader(dataFile);
  monitor = new PerformanceMonitor();

  if (dataReader.reader.data == null) {
    println("ERROR: Data not loaded!");
    displayErrorMessage();
    return;
  }
  
  // Print data statistics
  dataReader.printStatistics();
  
  // Draw complete interface
  drawInterface();
  
  // Output performance summary
  monitor.printSummary();
}


void drawInterface() {
  println("\n=== Drawing Petersen Graph Interface ===");
  
  ArrayList<Node> testNodes = dataReader.getNodesByIndex();
  ArrayList<OriginalEdge> testEdges = dataReader.getOriginalEdgesByIndex();

  println("Loaded " + testNodes.size() + " nodes and " + testEdges.size() + " edges");

  if (testNodes.size() == 0) {
    println("ERROR: No nodes loaded!");
    displayErrorMessage();
    return;
  }

  // Clear background
  background(245, 245, 250);
  
  // Draw header
  drawHeader();
  
  // Draw main graphs in grid layout
  drawMainGraphs();
  
  // Draw performance info
  drawPerformanceInfo();
  
  // Draw legend
  drawLegend();
  
  // Draw controls hint
  drawControlsHint();
}

void performanceComparison() {
  monitor.startTiming("Data Loading - Index Order");
  ArrayList<Node> nodesIndex = dataReader.getNodesByIndex();
  ArrayList<OriginalEdge> edgesIndex = dataReader.getOriginalEdgesByIndex();
  monitor.endTiming("Data Loading - Index Order");
  
  monitor.startTiming("Data Loading - Polar Order");
  ArrayList<Node> nodesPolar = dataReader.getNodesByPolar();
  ArrayList<OriginalEdge> edgesPolar = dataReader.getOriginalEdgesByPolar();
  monitor.endTiming("Data Loading - Polar Order");
  
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
  
  monitor.startTiming("Subset Creation - 1/5 data");
  ArrayList<Node> subset = dataReader.getSubset(nodesPolar, 0.2);
  monitor.endTiming("Subset Creation - 1/5 data");
}


void draw() {
  // Static interface - no continuous drawing needed
}

void keyPressed() {
  if (key == ' ') {
    println("\n=== Refreshing Interface ===");
    drawInterface();
  }
  if (key == 's' || key == 'S') {
    save("petersen_graph_analysis_" + year() + month() + day() + "_" + hour() + minute() + ".png");
    println("Screenshot saved with timestamp");
  }
  if (key == 'h' || key == 'H') {
    println("\n=== Help ===");
    println("SPACE - Refresh display");
    println("S - Save screenshot");
    println("H - Show this help");
  }
}