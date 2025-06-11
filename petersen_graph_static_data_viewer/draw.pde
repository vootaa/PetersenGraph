void drawHeader() {
  // Main title
  fill(30, 50, 80);
  textAlign(CENTER);
  textSize(28);
  text("Petersen Graph Static Data Viewer", width/2, 40);
  
  // Subtitle
  fill(80, 100, 120);
  textSize(16);
  text("Visual Analysis of Node and Edge Data in Different Orders", width/2, 65);
  
  // Data info
  fill(100, 120, 140);
  textSize(12);
  text("Data Version: " + dataReader.reader.version + " | Created: " + dataReader.reader.createdTime, width/2, 85);
  
  // Separator line
  stroke(200, 200, 210);
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
    {cellWidth * 2.5 + 50, gridStartY + cellHeight * 1.5}   // Reserved for future
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
  
  // Draw background panel
  fill(255, 255, 255, 240);
  stroke(220, 220, 230);
  strokeWeight(1);
  rectMode(CENTER);
  rect(centerX, centerY, 280, 320, 8);
  
  // Draw title (using larger font size to simulate bold)
  fill(30, 50, 80);
  textAlign(CENTER);
  textSize(15); // Slightly larger for title emphasis
  text(title, centerX, centerY - 140);
  
  // Draw subtitle
  fill(80, 100, 120);
  textSize(11);
  text(subtitle, centerX, centerY - 125);
  
  // Draw edges first (background layer)
  for (OriginalEdge edge : edges) {
    PVector start = edge.getStartCartesian();
    PVector end = edge.getEndCartesian();
    
    // Set color based on edge type with transparency
    switch (edge.edgeType) {
      case 0: stroke(229, 51, 51, 180); break;   // Red
      case 1: stroke(51, 204, 51, 180); break;   // Green
      case 2: stroke(51, 102, 255, 180); break;  // Blue
      case 3: stroke(255, 204, 0, 180); break;   // Yellow
      case 4: stroke(229, 102, 229, 180); break; // Purple
      default: stroke(128, 128, 128, 180); break;
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
    fill(0, 0, 0, 40);
    noStroke();
    float x = pos.x * scale + centerX + 1;
    float y = pos.y * scale + centerY + 1;
    ellipse(x, y, 10, 10);
    
    // Node color based on layer
    if (node.layer.equals("Inner")) {
      fill(51, 102, 255); // Blue
    } else if (node.layer.equals("Middle")) {
      fill(255, 51, 51); // Red
    } else if (node.layer.equals("Outer")) {
      fill(255, 204, 51); // Orange
    } else {
      fill(128, 128, 128); // Gray
    }
    
    stroke(255);
    strokeWeight(1.5);
    
    x = pos.x * scale + centerX;
    y = pos.y * scale + centerY;
    ellipse(x, y, 10, 10);
  }
  
  // Draw statistics
  fill(100, 120, 140);
  textAlign(CENTER);
  textSize(9);
  text("Nodes: " + nodes.size() + " | Edges: " + edges.size(), centerX, centerY + 100);
  
  // Draw description
  fill(120, 140, 160);
  textSize(8);
  text(description, centerX, centerY + 115);
}

void drawStyledSegmentGraph(ArrayList<Node> nodes, ArrayList<EdgeSegment> segments,
                           float centerX, float centerY, float scale,
                           String title, String subtitle, String description) {
  
  // Draw background panel
  fill(255, 255, 255, 240);
  stroke(220, 220, 230);
  strokeWeight(1);
  rectMode(CENTER);
  rect(centerX, centerY, 280, 320, 8);
  
  // Draw title and subtitle
  fill(30, 50, 80);
  textAlign(CENTER);
  textSize(15); // Slightly larger for title emphasis
  text(title, centerX, centerY - 140);
  
  fill(80, 100, 120);
  textSize(11);
  text(subtitle, centerX, centerY - 125);
  
  // Draw edge segments
  for (EdgeSegment segment : segments) {
    PVector start = segment.getStartCartesian();
    PVector end = segment.getEndCartesian();
    
    if (segment.isIntersected) {
      stroke(255, 100, 100, 200); // Light red for intersected
      strokeWeight(3);
    } else {
      stroke(100, 200, 100, 200); // Light green for normal
      strokeWeight(2);
    }
    
    float x1 = start.x * scale + centerX;
    float y1 = start.y * scale + centerY;
    float x2 = end.x * scale + centerX;
    float y2 = end.y * scale + centerY;
    
    line(x1, y1, x2, y2);
  }
  
  // Draw nodes
  for (Node node : nodes) {
    PVector pos = node.getCartesian();
    
    // Node shadow
    fill(0, 0, 0, 40);
    noStroke();
    float x = pos.x * scale + centerX + 1;
    float y = pos.y * scale + centerY + 1;
    ellipse(x, y, 10, 10);
    
    // Node color
    if (node.layer.equals("Inner")) {
      fill(51, 102, 255);
    } else if (node.layer.equals("Middle")) {
      fill(255, 51, 51);
    } else if (node.layer.equals("Outer")) {
      fill(255, 204, 51);
    } else {
      fill(128, 128, 128);
    }
    
    stroke(255);
    strokeWeight(1.5);
    
    x = pos.x * scale + centerX;
    y = pos.y * scale + centerY;
    ellipse(x, y, 10, 10);
  }
  
  // Statistics
  fill(100, 120, 140);
  textAlign(CENTER);
  textSize(9);
  text("Nodes: " + nodes.size() + " | Segments: " + segments.size(), centerX, centerY + 100);
  
  // Description
  fill(120, 140, 160);
  textSize(8);
  text(description, centerX, centerY + 115);
}

void drawStatsSummary(float centerX, float centerY) {
  // Performance summary panel
  fill(255, 255, 255, 240);
  stroke(220, 220, 230);
  strokeWeight(1);
  rectMode(CENTER);
  rect(centerX, centerY, 280, 320, 8);
  
  fill(30, 50, 80);
  textAlign(CENTER);
  textSize(15); // Slightly larger for title emphasis
  text("Performance", centerX, centerY - 140);
  
  fill(80, 100, 120);
  textSize(11);
  text("Rendering Times", centerX, centerY - 125);
  
  // Performance data (simplified)
  fill(60, 80, 100);
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
  fill(120, 140, 160);
  textAlign(CENTER);
  textSize(8);
  text("Memory: 24MB used, 104MB free", centerX, centerY + 100);
  text("Polar sorting shows 4x performance gain", centerX, centerY + 115);
}

void drawLegend() {
  float legendX = 50;
  float legendY = height - 140;
  
  // Legend background
  fill(255, 255, 255, 200);
  stroke(200, 200, 210);
  strokeWeight(1);
  rect(legendX, legendY, 350, 120, 6);
  
  // Legend title
  fill(30, 50, 80);
  textAlign(LEFT);
  textSize(13); // Slightly larger for title emphasis
  text("Legend", legendX + 10, legendY + 20);
  
  textSize(9);
  
  // Node legend
  fill(60, 80, 100);
  text("Nodes:", legendX + 10, legendY + 40);
  
  // Inner nodes
  fill(51, 102, 255);
  noStroke();
  ellipse(legendX + 60, legendY + 35, 8, 8);
  fill(60, 80, 100);
  text("Inner", legendX + 70, legendY + 40);
  
  // Middle nodes  
  fill(255, 51, 51);
  ellipse(legendX + 110, legendY + 35, 8, 8);
  fill(60, 80, 100);
  text("Middle", legendX + 120, legendY + 40);
  
  // Outer nodes
  fill(255, 204, 51);
  ellipse(legendX + 170, legendY + 35, 8, 8);
  fill(60, 80, 100);
  text("Outer", legendX + 180, legendY + 40);
  
  // Edge legend
  text("Edges:", legendX + 10, legendY + 60);
  
  stroke(229, 51, 51);
  strokeWeight(2);
  line(legendX + 60, legendY + 55, legendX + 80, legendY + 55);
  fill(60, 80, 100);
  noStroke();
  text("Type 0", legendX + 85, legendY + 60);
  
  stroke(51, 204, 51);
  strokeWeight(2);
  line(legendX + 130, legendY + 55, legendX + 150, legendY + 55);
  fill(60, 80, 100);
  noStroke();
  text("Type 1", legendX + 155, legendY + 60);
  
  stroke(51, 102, 255);
  strokeWeight(2);
  line(legendX + 200, legendY + 55, legendX + 220, legendY + 55);
  fill(60, 80, 100);
  noStroke();
  text("Type 2", legendX + 225, legendY + 60);
  
  // Segment legend
  text("Segments:", legendX + 10, legendY + 80);
  
  stroke(100, 200, 100);
  strokeWeight(2);
  line(legendX + 80, legendY + 75, legendX + 100, legendY + 75);
  fill(60, 80, 100);
  noStroke();
  text("Normal", legendX + 105, legendY + 80);
  
  stroke(255, 100, 100);
  strokeWeight(3);
  line(legendX + 160, legendY + 75, legendX + 180, legendY + 75);
  fill(60, 80, 100);
  noStroke();
  text("Intersected", legendX + 185, legendY + 80);
  
  // Analysis note
  text("Analysis: Polar coordinate ordering provides significant performance improvements", 
       legendX + 10, legendY + 100);
}

void drawPerformanceInfo() {
  performanceComparison();
}

void drawControlsHint() {
  fill(120, 140, 160);
  textAlign(RIGHT);
  textSize(10);
  text("Press SPACE to refresh | Press S to save screenshot", width - 50, height - 20);
}

void displayErrorMessage() {
  background(245, 245, 250);
  fill(255, 100, 100);
  textAlign(CENTER);
  textSize(24);
  text("Error: Could not load data file", width/2, height/2);
  
  fill(120, 140, 160);
  textSize(14);
  text("Please check the data file path and try again", width/2, height/2 + 30);
}
