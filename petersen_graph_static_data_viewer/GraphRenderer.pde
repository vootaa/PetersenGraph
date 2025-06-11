class GraphRenderer {
  private float offsetX, offsetY;
  private float scale;
  
  GraphRenderer(float offsetX, float offsetY, float scale) {
    this.offsetX = offsetX;
    this.offsetY = offsetY;
    this.scale = scale;
  }
  
  // Draw nodes
  void drawNodes(ArrayList<Node> nodes) {
    for (Node node : nodes) {
      PVector pos = node.getCartesian();
      
      // Set color based on layer
      if (node.layer.equals("Inner")) {
        fill(51, 102, 255); // Blue
      } else if (node.layer.equals("Middle")) {
        fill(255, 51, 51); // Red
      } else if (node.layer.equals("Outer")) {
        fill(255, 204, 51); // Orange
      }
      
      noStroke();
      float radius = node.displayRadius * scale * 1000; // Adjust display size
      ellipse(pos.x * scale + offsetX, pos.y * scale + offsetY, radius, radius);
    }
  }
  
  // Draw original edges
  void drawOriginalEdges(ArrayList<OriginalEdge> edges) {
    for (OriginalEdge edge : edges) {
      PVector start = edge.getStartCartesian();
      PVector end = edge.getEndCartesian();
      
      // Set color based on edge type
      switch (edge.edgeType) {
        case 0: stroke(229, 51, 51); break;   // type0: Red
        case 1: stroke(51, 204, 51); break;   // type1: Green
        case 2: stroke(51, 102, 255); break;  // type2: Blue
        case 3: stroke(255, 204, 0); break;   // type3: Yellow
        case 4: stroke(229, 102, 229); break; // type4: Purple
        default: stroke(128); break;
      }
      
      strokeWeight(2);
      line(
        start.x * scale + offsetX, start.y * scale + offsetY,
        end.x * scale + offsetX, end.y * scale + offsetY
      );
    }
  }
  
  // Draw intersections
  void drawIntersections(ArrayList<Intersection> intersections) {
    fill(0, 255, 255); // Cyan
    noStroke();
    
    for (Intersection intersection : intersections) {
      PVector pos = intersection.getCartesian();
      float radius = intersection.displayRadius * scale * 1000;
      ellipse(pos.x * scale + offsetX, pos.y * scale + offsetY, radius, radius);
    }
  }
  
  // Draw edge segments
  void drawEdgeSegments(ArrayList<EdgeSegment> segments) {
    stroke(0, 150, 0);
    strokeWeight(1);
    
    for (EdgeSegment segment : segments) {
      PVector start = segment.getStartCartesian();
      PVector end = segment.getEndCartesian();
      
      // Use different color for segments split by intersections
      if (segment.isIntersected) {
        stroke(255, 0, 0);
      } else {
        stroke(0, 150, 0);
      }
      
      line(
        start.x * scale + offsetX, start.y * scale + offsetY,
        end.x * scale + offsetX, end.y * scale + offsetY
      );
    }
  }
  
  // Draw title
  void drawTitle(String title, float x, float y) {
    fill(0);
    textAlign(CENTER);
    textSize(14);
    text(title, x, y);
  }
  
  // Draw statistics
  void drawStats(String stats, float x, float y) {
    fill(100);
    textAlign(LEFT);
    textSize(10);
    text(stats, x, y);
  }
}