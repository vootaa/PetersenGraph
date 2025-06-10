/**
 * Intersection Calculator for Petersen Graph
 * Calculates all edge-edge intersection points
 */
class IntersectionCalculator {
  ArrayList<Intersection> intersections;
  JSONObject config;
  
  IntersectionCalculator(JSONObject config) {
    this.config = config;
    this.intersections = new ArrayList<Intersection>();
  }
  
  void calculateIntersections(PetersenGraph graph) {
    intersections.clear();
    int intersectionId = 0;
    
    // Get intersection color from config (default to cyan if not specified)
    float[] intersectionColor = {0.0, 1.0, 1.0}; // Cyan default
    float intersectionRadius = 0.015; // Slightly smaller than nodes
    
    if (config.hasKey("intersections")) {
      JSONObject intersectionConfig = config.getJSONObject("intersections");
      if (intersectionConfig.hasKey("color")) {
        JSONArray colorArray = intersectionConfig.getJSONArray("color");
        intersectionColor[0] = colorArray.getFloat(0);
        intersectionColor[1] = colorArray.getFloat(1);
        intersectionColor[2] = colorArray.getFloat(2);
      }
      if (intersectionConfig.hasKey("radius")) {
        intersectionRadius = intersectionConfig.getFloat("radius");
      }
    }
    
    // Check all pairs of edges for intersections
    for (int i = 0; i < graph.edges.size(); i++) {
      for (int j = i + 1; j < graph.edges.size(); j++) {
        Edge edge1 = graph.edges.get(i);
        Edge edge2 = graph.edges.get(j);
        
        // Skip if edges share a common node
        if (sharesNode(edge1, edge2)) {
          continue;
        }
        
        PVector intersection = calculateLineIntersection(edge1, edge2);
        if (intersection != null) {
          intersections.add(new Intersection(
            intersectionId++,
            intersection.x,
            intersection.y,
            edge1.edgeId,
            edge2.edgeId,
            edge1,
            edge2,
            intersectionColor[0],
            intersectionColor[1],
            intersectionColor[2],
            intersectionRadius
          ));
        }
      }
    }
    
    println("Found " + intersections.size() + " edge intersections");
  }
  
  boolean sharesNode(Edge edge1, Edge edge2) {
    return (edge1.from == edge2.from || edge1.from == edge2.to || 
            edge1.to == edge2.from || edge1.to == edge2.to);
  }
  
  PVector calculateLineIntersection(Edge edge1, Edge edge2) {
    // Line 1: from (x1,y1) to (x2,y2)
    float x1 = edge1.from.x;
    float y1 = edge1.from.y;
    float x2 = edge1.to.x;
    float y2 = edge1.to.y;
    
    // Line 2: from (x3,y3) to (x4,y4)
    float x3 = edge2.from.x;
    float y3 = edge2.from.y;
    float x4 = edge2.to.x;
    float y4 = edge2.to.y;
    
    // Calculate the denominator
    float denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    
    // If denominator is 0, lines are parallel
    if (abs(denom) < 1e-10) {
      return null;
    }
    
    // Calculate intersection point
    float t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom;
    float u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom;
    
    // Check if intersection is within both line segments
    if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
      float intersectionX = x1 + t * (x2 - x1);
      float intersectionY = y1 + t * (y2 - y1);
      return new PVector(intersectionX, intersectionY);
    }
    
    return null;
  }
  
  void displayIntersections() {
    for (Intersection intersection : intersections) {
      intersection.display();
    }
  }
  
  ArrayList<Intersection> getIntersections() {
    return intersections;
  }
  
  void printIntersectionData() {
    println("\n--- INTERSECTION DATA ---");
    println("Total Intersections: " + intersections.size());
    println("Format: [ID] Position(x, y) | Edges(E1->E2) | Color(r, g, b)");
    
    for (Intersection intersection : intersections) {
      println(String.format("[%2d] Position(%.4f, %.4f) | Edges(E%d->E%d) | Color(%.1f, %.1f, %.1f)", 
                           intersection.intersectionId, 
                           intersection.x, 
                           intersection.y,
                           intersection.edge1Id,
                           intersection.edge2Id,
                           intersection.r, 
                           intersection.g, 
                           intersection.b));
    }
  }
}