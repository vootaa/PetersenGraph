// Node data model
class Node {
  int nodeId;
  PVector polar;  // angle_radians, radius
  float angleDegrees;
  int chainId;
  float displayRadius;
  String layer;
  
  Node(JSONObject nodeData) {
    this.nodeId = nodeData.getInt("node_id");
    this.chainId = nodeData.getInt("chain_id");
    this.displayRadius = nodeData.getFloat("display_radius");
    this.layer = nodeData.getString("layer");
    
    JSONObject polarData = nodeData.getJSONObject("polar");
    this.angleDegrees = polarData.getFloat("angle_degrees");
    this.polar = new PVector(
      polarData.getFloat("angle_radians"),
      polarData.getFloat("radius")
    );
  }
  
  // Convert to Cartesian coordinates
  PVector getCartesian() {
    float x = polar.y * cos(polar.x);
    float y = polar.y * sin(polar.x);
    return new PVector(x, y);
  }
}

// Original edge data model
class OriginalEdge {
  int edgeId;
  PVector startPolar, endPolar;
  ArrayList<Integer> intersectionIds;
  String description;
  int edgeType;
  
  OriginalEdge(JSONObject edgeData) {
    this.edgeId = edgeData.getInt("edge_id");
    this.description = edgeData.getString("description");
    this.edgeType = edgeData.getInt("edge_type");
    
    JSONObject startData = edgeData.getJSONObject("start_polar");
    this.startPolar = new PVector(
      startData.getFloat("angle_radians"),
      startData.getFloat("radius")
    );
    
    JSONObject endData = edgeData.getJSONObject("end_polar");
    this.endPolar = new PVector(
      endData.getFloat("angle_radians"),
      endData.getFloat("radius")
    );
    
    this.intersectionIds = new ArrayList<Integer>();
    JSONArray intersections = edgeData.getJSONArray("intersection_ids");
    for (int i = 0; i < intersections.size(); i++) {
      intersectionIds.add(intersections.getInt(i));
    }
  }
  
  PVector getStartCartesian() {
    return new PVector(startPolar.y * cos(startPolar.x), startPolar.y * sin(startPolar.x));
  }
  
  PVector getEndCartesian() {
    return new PVector(endPolar.y * cos(endPolar.x), endPolar.y * sin(endPolar.x));
  }
}

// Intersection data model
class Intersection {
  int intersectionId;
  PVector polar;
  int edge1Id, edge2Id;
  float displayRadius;
  
  Intersection(JSONObject intersectionData) {
    this.intersectionId = intersectionData.getInt("intersection_id");
    this.edge1Id = intersectionData.getInt("edge1_id");
    this.edge2Id = intersectionData.getInt("edge2_id");
    this.displayRadius = intersectionData.getFloat("display_radius");
    
    JSONObject polarData = intersectionData.getJSONObject("polar");
    this.polar = new PVector(
      polarData.getFloat("angle_radians"),
      polarData.getFloat("radius")
    );
  }
  
  PVector getCartesian() {
    return new PVector(polar.y * cos(polar.x), polar.y * sin(polar.x));
  }
}

// Edge segment data model
class EdgeSegment {
  int segmentId;
  int parentEdgeId;
  PVector startPolar, endPolar;
  boolean isIntersected;
  ArrayList<Integer> endpointIntersectionIds;
  
  EdgeSegment(JSONObject segmentData) {
    this.segmentId = segmentData.getInt("segment_id");
    this.parentEdgeId = segmentData.getInt("parent_edge_id");
    this.isIntersected = segmentData.getBoolean("is_intersected");
    
    JSONObject startData = segmentData.getJSONObject("start_polar");
    this.startPolar = new PVector(
      startData.getFloat("angle_radians"),
      startData.getFloat("radius")
    );
    
    JSONObject endData = segmentData.getJSONObject("end_polar");
    this.endPolar = new PVector(
      endData.getFloat("angle_radians"),
      endData.getFloat("radius")
    );
    
    this.endpointIntersectionIds = new ArrayList<Integer>();
    JSONArray endpoints = segmentData.getJSONArray("endpoint_intersection_ids");
    for (int i = 0; i < endpoints.size(); i++) {
      endpointIntersectionIds.add(endpoints.getInt(i));
    }
  }
  
  PVector getStartCartesian() {
    return new PVector(startPolar.y * cos(startPolar.x), startPolar.y * sin(startPolar.x));
  }
  
  PVector getEndCartesian() {
    return new PVector(endPolar.y * cos(endPolar.x), endPolar.y * sin(endPolar.x));
  }
}