class EnhancedDataReader {
  private PetersenDataReader reader;
  
  EnhancedDataReader(String filename) {
    reader = new PetersenDataReader();
    if (!reader.loadFromFile(filename)) {
      println("Failed to load data file: " + filename);
    }
  }
  
  // Get nodes in ID order
  ArrayList<Node> getNodesByIndex() {
    ArrayList<Node> nodes = new ArrayList<Node>();
    ArrayList<JSONObject> jsonNodes = reader.getAllNodes();
    for (JSONObject nodeData : jsonNodes) {
      nodes.add(new Node(nodeData));
    }
    return nodes;
  }
  
  // Get nodes in polar coordinate order
  ArrayList<Node> getNodesByPolar() {
    ArrayList<Node> nodes = new ArrayList<Node>();
    ArrayList<JSONObject> jsonNodes = reader.getNodesByPolar();
    for (JSONObject nodeData : jsonNodes) {
      nodes.add(new Node(nodeData));
    }
    return nodes;
  }
  
  // Get original edges in ID order
  ArrayList<OriginalEdge> getOriginalEdgesByIndex() {
    ArrayList<OriginalEdge> edges = new ArrayList<OriginalEdge>();
    ArrayList<JSONObject> jsonEdges = reader.getAllEdges();
    for (JSONObject edgeData : jsonEdges) {
      edges.add(new OriginalEdge(edgeData));
    }
    return edges;
  }
  
  // Get original edges in polar coordinate order
  ArrayList<OriginalEdge> getOriginalEdgesByPolar() {
    ArrayList<OriginalEdge> edges = new ArrayList<OriginalEdge>();
    ArrayList<JSONObject> jsonEdges = reader.edgesByPolar;
    for (JSONObject edgeData : jsonEdges) {
      edges.add(new OriginalEdge(edgeData));
    }
    return edges;
  }
  
  // Get intersections in ID order
  ArrayList<Intersection> getIntersectionsByIndex() {
    ArrayList<Intersection> intersections = new ArrayList<Intersection>();
    ArrayList<JSONObject> jsonIntersections = reader.getAllIntersections();
    for (JSONObject intersectionData : jsonIntersections) {
      intersections.add(new Intersection(intersectionData));
    }
    return intersections;
  }
  
  // Get intersections in polar coordinate order
  ArrayList<Intersection> getIntersectionsByPolar() {
    ArrayList<Intersection> intersections = new ArrayList<Intersection>();
    ArrayList<JSONObject> jsonIntersections = reader.intersectionsByPolar;
    for (JSONObject intersectionData : jsonIntersections) {
      intersections.add(new Intersection(intersectionData));
    }
    return intersections;
  }
  
  // Get edge segments in ID order
  ArrayList<EdgeSegment> getSegmentsByIndex() {
    ArrayList<EdgeSegment> segments = new ArrayList<EdgeSegment>();
    ArrayList<JSONObject> jsonSegments = reader.getAllSegments();
    for (JSONObject segmentData : jsonSegments) {
      segments.add(new EdgeSegment(segmentData));
    }
    return segments;
  }
  
  // Get edge segments in polar coordinate order
  ArrayList<EdgeSegment> getSegmentsByPolar() {
    ArrayList<EdgeSegment> segments = new ArrayList<EdgeSegment>();
    ArrayList<JSONObject> jsonSegments = reader.segmentsByPolar;
    for (JSONObject segmentData : jsonSegments) {
      segments.add(new EdgeSegment(segmentData));
    }
    return segments;
  }
  
  // Get data statistics
  void printStatistics() {
    reader.printStatistics();
  }
  
  // Get data subset
  <T> ArrayList<T> getSubset(ArrayList<T> list, float fraction) {
    int count = (int)(list.size() * fraction);
    ArrayList<T> subset = new ArrayList<T>();
    for (int i = 0; i < Math.min(count, list.size()); i++) {
      subset.add(list.get(i));
    }
    return subset;
  }
}