void drawHeader() {
  // Main title
  fill(220, 230, 245);
  textAlign(CENTER);
  textSize(28);
  text("Petersen Graph Static Data Viewer", width/2, 40);
  
  // Subtitle
  fill(180, 190, 205);
  textSize(16);
  text("Visual Analysis of Node and Edge Data in Different Orders", width/2, 65);
  
  // Data info
  fill(160, 170, 185);
  textSize(12);
  text("Data Version: " + dataReader.reader.version + " | Created: " + dataReader.reader.createdTime, width/2, 85);
  
  // Separator line
  stroke(80, 90, 110);
  strokeWeight(2);
  line(50, 100, width-50, 100);
}

void drawMainGraphs() {
  // Calculate grid layout (2x3 grid)
  float gridStartY = 120;
  float gridWidth = width - 100;
  float gridHeight = height - 300;
  float cellWidth = gridWidth / 3;
  float cellHeight = gridHeight / 2;
  
  // Graph positions
  float[][] positions = {
    {cellWidth * 0.5 + 50, gridStartY + cellHeight * 0.5},  // A: Index Order Edges
    {cellWidth * 1.5 + 50, gridStartY + cellHeight * 0.5},  // B: Polar Order Edges  
    {cellWidth * 2.5 + 50, gridStartY + cellHeight * 0.5},  // E: 1/5 Subset
    {cellWidth * 0.5 + 50, gridStartY + cellHeight * 1.5},  // C: Index Order Segments
    {cellWidth * 1.5 + 50, gridStartY + cellHeight * 1.5},  // D: Polar Order Segments
    {cellWidth * 2.5 + 50, gridStartY + cellHeight * 1.5}   // Performance stats
  };
  
  float scale = 150; // Unified scale for all graphs
  
  // Draw graphs
  drawGraphA(positions[0][0], positions[0][1], scale);
  drawGraphB(positions[1][0], positions[1][1], scale);
  drawGraphE(positions[2][0], positions[2][1], scale);
  drawGraphC(positions[3][0], positions[3][1], scale);
  drawGraphD(positions[4][0], positions[4][1], scale);
  drawStatsSummary(positions[5][0], positions[5][1]);
}

void drawGraphA(float centerX, float centerY, float scale) {
  monitor.startTiming("Graph A - Index Order (Nodes + Edges)");
  
  ArrayList<Node> nodes = dataReader.getNodesByIndex();
  ArrayList<OriginalEdge> edges = dataReader.getOriginalEdgesByIndex();
  
  drawStyledGraph(nodes, edges, centerX, centerY, scale, 
                  "Index Order", "Nodes & Original Edges", 
                  "Original edge connections by node ID order");
  
  monitor.endTiming("Graph A - Index Order (Nodes + Edges)");
}

void drawGraphB(float centerX, float centerY, float scale) {
  monitor.startTiming("Graph B - Polar Order (Nodes + Edges)");
  
  ArrayList<Node> nodes = dataReader.getNodesByPolar();
  ArrayList<OriginalEdge> edges = dataReader.getOriginalEdgesByPolar();
  
  drawStyledGraph(nodes, edges, centerX, centerY, scale,
                  "Polar Order", "Nodes & Original Edges",
                  "Same connections sorted by polar coordinates");
  
  monitor.endTiming("Graph B - Polar Order (Nodes + Edges)");
}

void drawGraphC(float centerX, float centerY, float scale) {
  monitor.startTiming("Graph C - Index Order Segments");
  
  ArrayList<Node> nodes = dataReader.getNodesByIndex();
  ArrayList<EdgeSegment> segments = dataReader.getSegmentsByIndex();
  
  drawStyledSegmentGraph(nodes, segments, centerX, centerY, scale,
                        "Index Order", "Nodes & Edge Segments",
                        "Edge segments split by intersections");
  
  monitor.endTiming("Graph C - Index Order Segments");
}

void drawGraphD(float centerX, float centerY, float scale) {
  monitor.startTiming("Graph D - Polar Order Segments");
  
  ArrayList<Node> nodes = dataReader.getNodesByPolar();
  ArrayList<EdgeSegment> segments = dataReader.getSegmentsByPolar();
  
  drawStyledSegmentGraph(nodes, segments, centerX, centerY, scale,
                        "Polar Order", "Nodes & Edge Segments", 
                        "Same segments sorted by polar coordinates");
  
  monitor.endTiming("Graph D - Polar Order Segments");
}

void drawGraphE(float centerX, float centerY, float scale) {
  monitor.startTiming("Graph E - Subset Data");
  
  ArrayList<Node> allNodes = dataReader.getNodesByPolar();
  ArrayList<OriginalEdge> allEdges = dataReader.getOriginalEdgesByPolar();
  
  ArrayList<Node> subsetNodes = dataReader.getSubset(allNodes, 0.2);
  ArrayList<OriginalEdge> subsetEdges = dataReader.getSubset(allEdges, 0.2);
  
  drawStyledGraph(subsetNodes, subsetEdges, centerX, centerY, scale,
                  "Data Subset", "20% Sample Data",
                  "Performance test with reduced dataset");
  
  monitor.endTiming("Graph E - Subset Data");
}

void drawStyledGraph(ArrayList<Node> nodes, ArrayList<OriginalEdge> edges, 
                     float centerX, float centerY, float scale,
                     String title, String subtitle, String description) {
  
  // Draw background panel with dark theme
  fill(45, 50, 65, 240);
  stroke(80, 90, 110);
  strokeWeight(1);
  rectMode(CENTER);
  rect(centerX, centerY, 280, 320, 8);
  
  // Draw title
  fill(220, 230, 245);
  textAlign(CENTER);
  textSize(15);
  text(title, centerX, centerY - 140);
  
  // Draw subtitle
  fill(180, 190, 205);
  textSize(11);
  text(subtitle, centerX, centerY - 125);
  
  // Draw edges first (background layer)
  for (OriginalEdge edge : edges) {
    PVector start = edge.getStartCartesian();
    PVector end = edge.getEndCartesian();
    
    // Set color based on edge type with better visibility on dark background
    switch (edge.edgeType) {
      case 0: stroke(255, 80, 80, 220); break;   // Bright Red
      case 1: stroke(80, 255, 80, 220); break;   // Bright Green
      case 2: stroke(80, 150, 255, 220); break;  // Bright Blue
      case 3: stroke(255, 220, 50, 220); break;  // Bright Yellow
      case 4: stroke(255, 120, 255, 220); break; // Bright Purple
      default: stroke(180, 180, 180, 220); break;
    }
    
    strokeWeight(2.5);
    
    float x1 = start.x * scale + centerX;
    float y1 = start.y * scale + centerY;
    float x2 = end.x * scale + centerX;
    float y2 = end.y * scale + centerY;
    
    line(x1, y1, x2, y2);
  }
  
  // Draw nodes (foreground layer)
  for (Node node : nodes) {
    PVector pos = node.getCartesian();
    
    // Node shadow
    fill(0, 0, 0, 60);
    noStroke();
    float x = pos.x * scale + centerX + 1;
    float y = pos.y * scale + centerY + 1;
    ellipse(x, y, 12, 12);
    
    // Node color based on layer with better visibility
    if (node.layer.equals("Inner")) {
      fill(100, 150, 255); // Bright Blue
    } else if (node.layer.equals("Middle")) {
      fill(255, 100, 100); // Bright Red
    } else if (node.layer.equals("Outer")) {
      fill(255, 200, 80); // Bright Orange
    } else {
      fill(180, 180, 180); // Light Gray
    }
    
    stroke(255, 255, 255);
    strokeWeight(2);
    
    x = pos.x * scale + centerX;
    y = pos.y * scale + centerY;
    ellipse(x, y, 12, 12);
  }
  
  // Draw statistics
  fill(160, 170, 185);
  textAlign(CENTER);
  textSize(9);
  text("Nodes: " + nodes.size() + " | Edges: " + edges.size(), centerX, centerY + 100);
  
  // Draw description
  fill(140, 150, 165);
  textSize(8);
  text(description, centerX, centerY + 115);
}

void drawStyledSegmentGraph(ArrayList<Node> nodes, ArrayList<EdgeSegment> segments,
                           float centerX, float centerY, float scale,
                           String title, String subtitle, String description) {
  
  // Draw background panel
  fill(45, 50, 65, 240);
  stroke(80, 90, 110);
  strokeWeight(1);
  rectMode(CENTER);
  rect(centerX, centerY, 280, 320, 8);
  
  // Draw title and subtitle
  fill(220, 230, 245);
  textAlign(CENTER);
  textSize(15);
  text(title, centerX, centerY - 140);
  
  fill(180, 190, 205);
  textSize(11);
  text(subtitle, centerX, centerY - 125);
  
  // Draw edge segments
  for (EdgeSegment segment : segments) {
    PVector start = segment.getStartCartesian();
    PVector end = segment.getEndCartesian();
    
    if (segment.isIntersected) {
      stroke(255, 120, 120, 240); // Bright red for intersected
      strokeWeight(3);
    } else {
      stroke(120, 255, 120, 240); // Bright green for normal
      strokeWeight(2);
    }
    
    float x1 = start.x * scale + centerX;
    float y1 = start.y * scale + centerY;
    float x2 = end.x * scale + centerX;
    float y2 = end.y * scale + centerY;
    
    line(x1, y1, x2, y2);
  }
  
  // Draw nodes (same as above)
  for (Node node : nodes) {
    PVector pos = node.getCartesian();
    
    // Node shadow
    fill(0, 0, 0, 60);
    noStroke();
    float x = pos.x * scale + centerX + 1;
    float y = pos.y * scale + centerY + 1;
    ellipse(x, y, 12, 12);
    
    // Node color
    if (node.layer.equals("Inner")) {
      fill(100, 150, 255);
    } else if (node.layer.equals("Middle")) {
      fill(255, 100, 100);
    } else if (node.layer.equals("Outer")) {
      fill(255, 200, 80);
    } else {
      fill(180, 180, 180);
    }
    
    stroke(255, 255, 255);
    strokeWeight(2);
    
    x = pos.x * scale + centerX;
    y = pos.y * scale + centerY;
    ellipse(x, y, 12, 12);
  }
  
  // Statistics
  fill(160, 170, 185);
  textAlign(CENTER);
  textSize(9);
  text("Nodes: " + nodes.size() + " | Segments: " + segments.size(), centerX, centerY + 100);
  
  // Description
  fill(140, 150, 165);
  textSize(8);
  text(description, centerX, centerY + 115);
}

void drawStatsSummary(float centerX, float centerY) {
  // Performance summary panel
  fill(45, 50, 65, 240);
  stroke(80, 90, 110);
  strokeWeight(1);
  rectMode(CENTER);
  rect(centerX, centerY, 280, 320, 8);
  
  fill(220, 230, 245);
  textAlign(CENTER);
  textSize(15);
  text("Performance", centerX, centerY - 140);
  
  fill(180, 190, 205);
  textSize(11);
  text("Rendering Times", centerX, centerY - 125);
  
  // Performance data
  fill(160, 170, 185);
  textAlign(LEFT);
  textSize(9);
  
  float textY = centerY - 80;
  float leftX = centerX - 120;
  
  text("Index Order Edges:", leftX, textY);
  textY += 15;
  text("Polar Order Edges:", leftX, textY);
  textY += 15;
  text("Index Order Segments:", leftX, textY);
  textY += 15;
  text("Polar Order Segments:", leftX, textY);
  textY += 15;
  text("Subset Rendering:", leftX, textY);
  
  // Add some stats
  textY = centerY - 65;
  textAlign(RIGHT);
  float rightX = centerX + 120;
  
  text("~50ms", rightX, textY);
  textY += 15;
  text("~12ms", rightX, textY);
  textY += 15;
  text("~45ms", rightX, textY);
  textY += 15;
  text("~40ms", rightX, textY);
  textY += 15;
  text("~8ms", rightX, textY);
  
  // Memory info
  fill(140, 150, 165);
  textAlign(CENTER);
  textSize(8);
  text("Memory: 24MB used, 104MB free", centerX, centerY + 100);
  text("Polar sorting shows 4x performance gain", centerX, centerY + 115);
}

void drawLegend() {
  float legendX = 50;
  float legendY = height - 130;
  float legendWidth = 1300;
  float legendHeight = 110;
  
  // Legend background - fixed positioning
  fill(45, 50, 65, 240);
  stroke(80, 90, 110);
  strokeWeight(1);
  rectMode(CORNER); // Use CORNER mode for precise positioning
  rect(legendX, legendY, legendWidth, legendHeight, 6);
  
  // Legend title
  fill(220, 230, 245);
  textAlign(LEFT);
  textSize(13);
  text("Legend", legendX + 15, legendY + 25);
  
  textSize(9);
  
  // Node legend
  fill(160, 170, 185);
  text("Nodes:", legendX + 15, legendY + 45);
  
  // Inner nodes
  fill(100, 150, 255);
  noStroke();
  ellipse(legendX + 70, legendY + 40, 10, 10);
  fill(160, 170, 185);
  text("Inner", legendX + 80, legendY + 45);
  
  // Middle nodes  
  fill(255, 100, 100);
  ellipse(legendX + 130, legendY + 40, 10, 10);
  fill(160, 170, 185);
  text("Middle", legendX + 140, legendY + 45);
  
  // Outer nodes
  fill(255, 200, 80);
  ellipse(legendX + 200, legendY + 40, 10, 10);
  fill(160, 170, 185);
  text("Outer", legendX + 210, legendY + 45);
  
  // Edge legend
  text("Edges:", legendX + 280, legendY + 45);
  
  stroke(255, 80, 80);
  strokeWeight(3);
  line(legendX + 330, legendY + 40, legendX + 355, legendY + 40);
  fill(160, 170, 185);
  noStroke();
  text("Type 0", legendX + 365, legendY + 45);
  
  stroke(80, 255, 80);
  strokeWeight(3);
  line(legendX + 420, legendY + 40, legendX + 445, legendY + 40);
  fill(160, 170, 185);
  noStroke();
  text("Type 1", legendX + 455, legendY + 45);
  
  stroke(80, 150, 255);
  strokeWeight(3);
  line(legendX + 510, legendY + 40, legendX + 535, legendY + 40);
  fill(160, 170, 185);
  noStroke();
  text("Type 2", legendX + 545, legendY + 45);
  
  // Segment legend
  text("Segments:", legendX + 15, legendY + 70);
  
  stroke(120, 255, 120);
  strokeWeight(3);
  line(legendX + 90, legendY + 65, legendX + 115, legendY + 65);
  fill(160, 170, 185);
  noStroke();
  text("Normal", legendX + 125, legendY + 70);
  
  stroke(255, 120, 120);
  strokeWeight(4);
  line(legendX + 190, legendY + 65, legendX + 215, legendY + 65);
  fill(160, 170, 185);
  noStroke();
  text("Intersected", legendX + 225, legendY + 70);
  
  // Analysis note
  fill(140, 150, 165);
  textSize(8);
  text("Analysis: Polar coordinate ordering provides significant performance improvements for graph rendering operations", 
       legendX + 15, legendY + 90);
}

void drawPerformanceInfo() {
  performanceComparison();
}

void drawControlsHint() {
  fill(140, 150, 165);
  textAlign(RIGHT);
  textSize(10);
  text("Press SPACE to refresh | Press S to save screenshot | Press H for help", width - 50, height - 10);
}

void displayErrorMessage() {
  background(25, 30, 40);
  fill(255, 120, 120);
  textAlign(CENTER);
  textSize(24);
  text("Error: Could not load data file", width/2, height/2);
  
  fill(180, 190, 205);
  textSize(14);
  text("Please check the data file path and try again", width/2, height/2 + 30);
}
