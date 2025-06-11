import java.util.*;

class AnalysisEngine {
    PetersenDataReader dataReader;
    ArrayList<Node> nodes;
    ArrayList<Edge> edges;

    AnalysisEngine(PetersenDataReader reader) {
        this.dataReader = reader;
        this.nodes = new ArrayList<Node>();
        this.edges = new ArrayList<Edge>();
        
        // Convert Petersen data to our analysis format
        convertDataToAnalysisFormat();
    }

    // Convert Petersen data to Node/Edge objects for analysis
    void convertDataToAnalysisFormat() {
        nodes.clear();
        edges.clear();
        
        println("\n=== Data Conversion Started ===");
        
        // First: Convert all nodes
        ArrayList<JSONObject> petersenNodes = dataReader.getAllNodes();
        for (JSONObject nodeObj : petersenNodes) {
            Node node = new Node(nodeObj);
            nodes.add(node);
        }
        println("Converted nodes: " + nodes.size() + " count");
        
        // Second: Convert all intersections as special nodes
        ArrayList<JSONObject> intersections = dataReader.getAllIntersections();
        for (JSONObject intersectionObj : intersections) {
            try {
                // Create a modified JSONObject for intersection
                JSONObject modifiedObj = new JSONObject();
                modifiedObj.setInt("node_id", intersectionObj.getInt("intersection_id") + 1000);
                
                // Copy polar data
                JSONObject polar = intersectionObj.getJSONObject("polar");
                modifiedObj.setJSONObject("polar", polar);
                modifiedObj.setString("layer", "intersection");
                
                Node node = new Node(modifiedObj);
                nodes.add(node);
                
            } catch (Exception e) {
                println("Warning: Error processing intersection - " + e.getMessage());
            }
        }
        println("Converted intersections: " + intersections.size() + " count");
        
        // Third: Convert segments by finding matching nodes for endpoints
        ArrayList<JSONObject> segments = dataReader.getAllSegments();
        int successfulSegments = 0;
        int failedSegments = 0;
        
        for (JSONObject segmentObj : segments) {
            try {
                JSONObject startPolar = segmentObj.getJSONObject("start_polar");
                JSONObject endPolar = segmentObj.getJSONObject("end_polar");
                
                Node startNode = findNodeByPolar(startPolar);
                Node endNode = findNodeByPolar(endPolar);
                
                if (startNode != null && endNode != null) {
                    int segmentId = segmentObj.getInt("segment_id");
                    int parentEdgeId = segmentObj.getInt("parent_edge_id");
                    
                    Edge edge = new Edge(segmentId, startNode, endNode, parentEdgeId);
                    edges.add(edge);
                    successfulSegments++;
                } else {
                    println("Failed to match segment " + segmentObj.getInt("segment_id"));
                    println("  Start polar: " + startPolar.toString());
                    println("  End polar: " + endPolar.toString());
                    failedSegments++;
                }
                
            } catch (Exception e) {
                println("Warning: Error processing segment - " + e.getMessage());
                failedSegments++;
            }
        }
        
        println("Converted segments: " + successfulSegments + " successful, " + failedSegments + " failed");
        println("Total nodes: " + nodes.size());
        println("Total edges: " + edges.size());
        println("=== Data Conversion Completed ===\n");
        
        // Print matching statistics
        printNodeMatchingStatistics();
    }

    /**
     * Find node by polar coordinates with tolerance matching
     */
    Node findNodeByPolar(JSONObject targetPolar) {
        try {
            float targetRadius = Float.parseFloat(targetPolar.getString("radius"));
            float targetAngle = Float.parseFloat(targetPolar.getString("angle_radians"));
            
            // Tolerance for matching (adjust as needed)
            float radiusTolerance = 0.01;
            float angleTolerance = 0.05; // radians
            
            for (Node node : nodes) {
                PVector nodePolar = node.getPolarCoordinate();
                float nodeRadius = nodePolar.x;
                float nodeAngle = normalizeAngle(nodePolar.y);
                float normalizedTargetAngle = normalizeAngle(targetAngle);
                
                // Check radius match
                if (abs(nodeRadius - targetRadius) <= radiusTolerance) {
                    // Check angle match (handle circular boundary)
                    float angleDiff = abs(nodeAngle - normalizedTargetAngle);
                    if (angleDiff > PI) angleDiff = TWO_PI - angleDiff;
                    
                    if (angleDiff <= angleTolerance) {
                        return node;
                    }
                }
            }
            
            return null;
            
        } catch (Exception e) {
            println("Warning: Polar coordinate matching failed - " + e.getMessage());
            return null;
        }
    }

    /**
     * Normalize angle to [0, 2π] range
     */
    float normalizeAngle(float angle) {
        while (angle < 0) angle += TWO_PI;
        while (angle >= TWO_PI) angle -= TWO_PI;
        return angle;
    }

    /**
     * Print detailed statistics about node matching
     */
    void printNodeMatchingStatistics() {
        println("\n--- Node Matching Statistics ---");
        
        // Count different types of nodes
        int regularNodes = 0;
        int intersectionNodes = 0;
        HashMap<String, Integer> layerCounts = new HashMap<String, Integer>();
        
        for (Node node : nodes) {
            String type = node.getType();
            if (type.equals("intersection")) {
                intersectionNodes++;
            } else {
                regularNodes++;
                
                // Count by layer
                if (!layerCounts.containsKey(type)) {
                    layerCounts.put(type, 0);
                }
                layerCounts.put(type, layerCounts.get(type) + 1);
            }
        }
        
        println("Regular nodes: " + regularNodes);
        println("Intersection nodes: " + intersectionNodes);
        
        println("Distribution by layer:");
        for (String layer : layerCounts.keySet()) {
            println("  " + layer + ": " + layerCounts.get(layer) + " count");
        }
        
        // Analyze edge connectivity
        HashMap<Node, Integer> nodeConnections = new HashMap<Node, Integer>();
        for (Edge edge : edges) {
            if (edge.isValid()) {
                Node start = edge.getStartNode();
                Node end = edge.getEndNode();
                
                nodeConnections.put(start, nodeConnections.getOrDefault(start, 0) + 1);
                nodeConnections.put(end, nodeConnections.getOrDefault(end, 0) + 1);
            }
        }
        
        println("\nConnection degree distribution:");
        HashMap<Integer, Integer> degreeCounts = new HashMap<Integer, Integer>();
        for (Node node : nodeConnections.keySet()) {
            int degree = nodeConnections.get(node);
            degreeCounts.put(degree, degreeCounts.getOrDefault(degree, 0) + 1);
        }
        
        for (Integer degree : degreeCounts.keySet()) {
            println("  Degree " + degree + ": " + degreeCounts.get(degree) + " nodes");
        }
        
        // Report unconnected nodes
        int unconnectedNodes = nodes.size() - nodeConnections.size();
        if (unconnectedNodes > 0) {
            println("⚠️  Unconnected nodes: " + unconnectedNodes + " count");
        }
    }
    
    // Find node by ID (including offset intersections)
    Node findNodeById(int nodeId) {
        for (Node node : nodes) {
            if (node.getId() == nodeId) {
                return node;
            }
        }
        return null;
    }

    // Get nodes and edges for UI rendering
    ArrayList<Node> getNodes() { return new ArrayList<Node>(nodes); }
    ArrayList<Edge> getEdges() { return new ArrayList<Edge>(edges); }

    /**
     * Debug method to show unmatched segments
     */
    void debugUnmatchedSegments() {
        println("\n=== Debug Unmatched Segments ===");
        
        ArrayList<JSONObject> segments = dataReader.getAllSegments();
        
        for (int i = 0; i < min(5, segments.size()); i++) {  // Show first 5 segments
            JSONObject segmentObj = segments.get(i);
            
            JSONObject startPolar = segmentObj.getJSONObject("start_polar");
            JSONObject endPolar = segmentObj.getJSONObject("end_polar");
            
            Node startNode = findNodeByPolar(startPolar);
            Node endNode = findNodeByPolar(endPolar);
            
            println("Segment " + segmentObj.getInt("segment_id") + ":");
            println("  Start: " + startPolar.toString() + " -> " + (startNode != null ? "Found node " + startNode.getId() : "Not found"));
            println("  End: " + endPolar.toString() + " -> " + (endNode != null ? "Found node " + endNode.getId() : "Not found"));
        }
    }
}