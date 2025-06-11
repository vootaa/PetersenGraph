/**
 * Static Petersen Graph Data
 * Contains all polar coordinate data needed for drawing, independent of original logical structure
 */
class StaticPetersenData {
    // Basic information
    String version;
    String createdTime;
    JSONObject metadata;
    
    // Node data - sorted by index
    ArrayList<StaticNode> nodesByIndex;
    // Node data - sorted by angle + radius
    ArrayList<StaticNode> nodesByPolar;
    
    // Intersection data - sorted by index
    ArrayList<StaticIntersection> intersectionsByIndex;
    // Intersection data - sorted by angle + radius
    ArrayList<StaticIntersection> intersectionsByPolar;
    
    // Original edge data - sorted by index
    ArrayList<StaticEdge> originalEdgesByIndex;
    // Original edge data - sorted by angle + radius
    ArrayList<StaticEdge> originalEdgesByPolar;
    
    // Split segment data - sorted by index
    ArrayList<StaticSegment> segmentsByIndex;
    // Split segment data - sorted by angle + radius
    ArrayList<StaticSegment> segmentsByPolar;
    
    // Layer group data
    LayerGroupData layerGroups;
    
    StaticPetersenData() {
        nodesByIndex = new ArrayList<StaticNode>();
        nodesByPolar = new ArrayList<StaticNode>();
        intersectionsByIndex = new ArrayList<StaticIntersection>();
        intersectionsByPolar = new ArrayList<StaticIntersection>();
        originalEdgesByIndex = new ArrayList<StaticEdge>();
        originalEdgesByPolar = new ArrayList<StaticEdge>();
        segmentsByIndex = new ArrayList<StaticSegment>();
        segmentsByPolar = new ArrayList<StaticSegment>();
        layerGroups = new LayerGroupData();
        
        version = "1.0";
        createdTime = year() + "-" + month() + "-" + day() + " " + hour() + ":" + minute() + ":" + second();
    }
}

/**
 * Static node data
 */
class StaticNode {
    int nodeId;
    int chainId;
    PolarCoordinate polar;
    String layer;
    float displayRadius;
    
    StaticNode(int nodeId, int chainId, PolarCoordinate polar, String layer, float displayRadius) {
        this.nodeId = nodeId;
        this.chainId = chainId;
        this.polar = polar;
        this.layer = layer;
        this.displayRadius = displayRadius;
    }
}

/**
 * Static intersection data
 */
class StaticIntersection {
    int intersectionId;
    PolarCoordinate polar;
    int edge1Id;
    int edge2Id;
    float displayRadius;
    
    StaticIntersection(int intersectionId, PolarCoordinate polar, 
                      int edge1Id, int edge2Id, float displayRadius) {
        this.intersectionId = intersectionId;
        this.polar = polar;
        this.edge1Id = edge1Id;
        this.edge2Id = edge2Id;
        this.displayRadius = displayRadius;
    }
}

/**
 * Static edge data (original complete edges)
 */
class StaticEdge {
    int edgeId;
    int edgeType;
    PolarCoordinate startPolar;
    PolarCoordinate endPolar;
    float strokeWidth;
    String description;
    ArrayList<Integer> intersectionIds; // List of intersection IDs on this edge
    
    StaticEdge(int edgeId, int edgeType, PolarCoordinate startPolar, PolarCoordinate endPolar,
               float strokeWidth, String description) {
        this.edgeId = edgeId;
        this.edgeType = edgeType;
        this.startPolar = startPolar;
        this.endPolar = endPolar;
        this.strokeWidth = strokeWidth;
        this.description = description;
        this.intersectionIds = new ArrayList<Integer>();
    }
}

/**
 * Static segment data (short segments split by intersections)
 */
class StaticSegment {
    int segmentId;
    int parentEdgeId;
    PolarCoordinate startPolar;
    PolarCoordinate endPolar;
    float strokeWidth;
    boolean isIntersected; // Whether it contains intersections as endpoints
    ArrayList<Integer> endpointIntersectionIds; // Endpoint intersection IDs (if any)
    
    StaticSegment(int segmentId, int parentEdgeId, PolarCoordinate startPolar, PolarCoordinate endPolar,
                  float strokeWidth) {
        this.segmentId = segmentId;
        this.parentEdgeId = parentEdgeId;
        this.startPolar = startPolar;
        this.endPolar = endPolar;
        this.strokeWidth = strokeWidth;
        this.isIntersected = false;
        this.endpointIntersectionIds = new ArrayList<Integer>();
    }
}

/**
 * Layer group data
 */
class LayerGroupData {
    ArrayList<StaticNode> middleNodes;
    ArrayList<StaticNode> innerNodes;
    ArrayList<StaticNode> outerNodes;
    
    ArrayList<StaticSegment> middleToInnerSegments;
    ArrayList<StaticSegment> middleToOuterSegments;
    ArrayList<StaticSegment> innerCircleSegments;
    ArrayList<StaticSegment> outerCircleSegments;
    ArrayList<StaticSegment> intersectionSegments;
    
    LayerGroupData() {
        middleNodes = new ArrayList<StaticNode>();
        innerNodes = new ArrayList<StaticNode>();
        outerNodes = new ArrayList<StaticNode>();
        
        middleToInnerSegments = new ArrayList<StaticSegment>();
        middleToOuterSegments = new ArrayList<StaticSegment>();
        innerCircleSegments = new ArrayList<StaticSegment>();
        outerCircleSegments = new ArrayList<StaticSegment>();
        intersectionSegments = new ArrayList<StaticSegment>();
    }
}