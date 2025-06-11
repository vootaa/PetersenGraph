/**
 * Petersen Graph Static Data Reader
 * Provides utilities for loading and accessing exported JSON data
 */
class PetersenDataReader {
    JSONObject data;
    String version;
    String createdTime;
    
    // Cached collections
    ArrayList<JSONObject> nodesByIndex;
    ArrayList<JSONObject> nodesByPolar;
    ArrayList<JSONObject> intersectionsByIndex;
    ArrayList<JSONObject> intersectionsByPolar;
    ArrayList<JSONObject> edgesByIndex;
    ArrayList<JSONObject> edgesByPolar;
    ArrayList<JSONObject> segmentsByIndex;
    ArrayList<JSONObject> segmentsByPolar;
    
    /**
     * Load data from JSON file
     */
    boolean loadFromFile(String filename) {
        try {
            data = loadJSONObject(filename);
            if (data == null) return false;
            
            // Extract basic info
            version = data.getString("version", "unknown");
            createdTime = data.getString("created_time", "unknown");
            
            // Cache collections for faster access
            cacheCollections();
            
            println("Loaded Petersen graph data version " + version);
            println("Created: " + createdTime);
            printStatistics();
            
            return true;
        } catch (Exception e) {
            println("Error loading data: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Cache JSON arrays as ArrayLists for easier access
     */
    private void cacheCollections() {
        // Nodes
        nodesByIndex = jsonArrayToList(data.getJSONObject("nodes").getJSONArray("by_index"));
        nodesByPolar = jsonArrayToList(data.getJSONObject("nodes").getJSONArray("by_polar"));
        
        // Intersections  
        intersectionsByIndex = jsonArrayToList(data.getJSONObject("intersections").getJSONArray("by_index"));
        intersectionsByPolar = jsonArrayToList(data.getJSONObject("intersections").getJSONArray("by_polar"));
        
        // Edges
        edgesByIndex = jsonArrayToList(data.getJSONObject("original_edges").getJSONArray("by_index"));
        edgesByPolar = jsonArrayToList(data.getJSONObject("original_edges").getJSONArray("by_polar"));
        
        // Segments
        segmentsByIndex = jsonArrayToList(data.getJSONObject("segments").getJSONArray("by_index"));
        segmentsByPolar = jsonArrayToList(data.getJSONObject("segments").getJSONArray("by_polar"));
    }
    
    /**
     * Convert JSONArray to ArrayList<JSONObject>
     */
    private ArrayList<JSONObject> jsonArrayToList(JSONArray array) {
        ArrayList<JSONObject> list = new ArrayList<JSONObject>();
        for (int i = 0; i < array.size(); i++) {
            list.add(array.getJSONObject(i));
        }
        return list;
    }
    
    /**
     * Print data statistics
     */
    void printStatistics() {
        JSONObject stats = data.getJSONObject("statistics");
        println("Statistics:");
        println("  Nodes: " + stats.getInt("total_nodes"));
        println("  Intersections: " + stats.getInt("total_intersections"));
        println("  Original Edges: " + stats.getInt("total_original_edges"));
        println("  Segments: " + stats.getInt("total_segments"));
    }
    
    // ========== NODE ACCESS ==========
    
    /**
     * Get all nodes (by creation order)
     */
    ArrayList<JSONObject> getAllNodes() {
        return nodesByIndex;
    }
    
    /**
     * Get all nodes sorted by polar coordinates
     */
    ArrayList<JSONObject> getNodesByPolar() {
        return nodesByPolar;
    }
    
    /**
     * Get node by ID
     */
    JSONObject getNodeById(int nodeId) {
        for (JSONObject node : nodesByIndex) {
            if (node.getInt("node_id") == nodeId) {
                return node;
            }
        }
        return null;
    }
    
    /**
     * Get nodes by layer
     */
    ArrayList<JSONObject> getNodesByLayer(String layer) {
        ArrayList<JSONObject> result = new ArrayList<JSONObject>();
        for (JSONObject node : nodesByIndex) {
            if (node.getString("layer").equals(layer)) {
                result.add(node);
            }
        }
        return result;
    }
    
    // ========== INTERSECTION ACCESS ==========
    
    /**
     * Get all intersections
     */
    ArrayList<JSONObject> getAllIntersections() {
        return intersectionsByIndex;
    }
    
    /**
     * Get intersection by ID
     */
    JSONObject getIntersectionById(int intersectionId) {
        for (JSONObject intersection : intersectionsByIndex) {
            if (intersection.getInt("intersection_id") == intersectionId) {
                return intersection;
            }
        }
        return null;
    }
    
    // ========== EDGE ACCESS ==========
    
    /**
     * Get all original edges
     */
    ArrayList<JSONObject> getAllEdges() {
        return edgesByIndex;
    }
    
    /**
     * Get edge by ID
     */
    JSONObject getEdgeById(int edgeId) {
        for (JSONObject edge : edgesByIndex) {
            if (edge.getInt("edge_id") == edgeId) {
                return edge;
            }
        }
        return null;
    }
    
    /**
     * Get edges by type
     */
    ArrayList<JSONObject> getEdgesByType(int edgeType) {
        ArrayList<JSONObject> result = new ArrayList<JSONObject>();
        for (JSONObject edge : edgesByIndex) {
            if (edge.getInt("edge_type") == edgeType) {
                result.add(edge);
            }
        }
        return result;
    }
    
    // ========== SEGMENT ACCESS ==========
    
    /**
     * Get all segments
     */
    ArrayList<JSONObject> getAllSegments() {
        return segmentsByIndex;
    }
    
    /**
     * Get segment by ID
     */
    JSONObject getSegmentById(int segmentId) {
        for (JSONObject segment : segmentsByIndex) {
            if (segment.getInt("segment_id") == segmentId) {
                return segment;
            }
        }
        return null;
    }
    
    /**
     * Get segments by parent edge
     */
    ArrayList<JSONObject> getSegmentsByParentEdge(int parentEdgeId) {
        ArrayList<JSONObject> result = new ArrayList<JSONObject>();
        for (JSONObject segment : segmentsByIndex) {
            if (segment.getInt("parent_edge_id") == parentEdgeId) {
                result.add(segment);
            }
        }
        return result;
    }
    
    /**
     * Get only intersected segments
     */
    ArrayList<JSONObject> getIntersectedSegments() {
        ArrayList<JSONObject> result = new ArrayList<JSONObject>();
        for (JSONObject segment : segmentsByIndex) {
            if (segment.getBoolean("is_intersected")) {
                result.add(segment);
            }
        }
        return result;
    }
    
    // ========== LAYER GROUP ACCESS ==========
    
    /**
     * Get layer groups data
     */
    JSONObject getLayerGroups() {
        return data.getJSONObject("layer_groups");
    }
    
    /**
     * Get nodes by layer from layer groups
     */
    ArrayList<JSONObject> getLayerGroupNodes(String layerType) {
        JSONObject layerGroups = getLayerGroups();
        String key = layerType.toLowerCase() + "_nodes";
        return jsonArrayToList(layerGroups.getJSONArray(key));
    }
    
    /**
     * Get segments by type from layer groups
     */
    ArrayList<JSONObject> getLayerGroupSegments(String segmentType) {
        JSONObject layerGroups = getLayerGroups();
        return jsonArrayToList(layerGroups.getJSONArray(segmentType));
    }
    
    // ========== COORDINATE UTILITIES ==========
    
    /**
     * Extract polar coordinate from JSON object
     */
    PVector getPolarCoordinate(JSONObject obj, String key) {
        JSONObject polar = obj.getJSONObject(key);
        float radius = Float.parseFloat(polar.getString("radius"));
        float angle = Float.parseFloat(polar.getString("angle_radians"));
        return new PVector(radius, angle);
    }
    
    /**
     * Convert polar to cartesian coordinates
     */
    PVector polarToCartesian(PVector polar) {
        float x = polar.x * cos(polar.y);
        float y = polar.x * sin(polar.y);
        return new PVector(x, y);
    }
    
    /**
     * Convert polar to cartesian with scaling
     */
    PVector polarToCartesian(PVector polar, float scale) {
        PVector cartesian = polarToCartesian(polar);
        cartesian.mult(scale);
        return cartesian;
    }
    
    // ========== METADATA ACCESS ==========
    
    /**
     * Get metadata object
     */
    JSONObject getMetadata() {
        return data.getJSONObject("metadata");
    }
    
    /**
     * Get color array from metadata
     */
    color getColor(String path) {
        String[] parts = path.split("\\.");
        JSONObject current = getMetadata();
        
        for (int i = 0; i < parts.length - 1; i++) {
            current = current.getJSONObject(parts[i]);
        }
        
        JSONArray colorArray = current.getJSONArray(parts[parts.length - 1]);
        return color(
            (float)colorArray.getDouble(0) * 255,
            (float)colorArray.getDouble(1) * 255, 
            (float)colorArray.getDouble(2) * 255
        );
    }
    
    // ========== EXAMPLE USAGE ==========
    
    /**
     * Example: Print all middle layer nodes
     */
    void printMiddleNodes() {
        println("\nMiddle Layer Nodes:");
        ArrayList<JSONObject> middleNodes = getNodesByLayer("Middle");
        for (JSONObject node : middleNodes) {
            int id = node.getInt("node_id");
            PVector polar = getPolarCoordinate(node, "polar");
            println("Node " + id + ": radius=" + polar.x + ", angle=" + degrees(polar.y) + "°");
        }
    }
    
    /**
     * Example: Print intersection details
     */
    void printIntersectionDetails() {
        println("\nIntersection Details:");
        for (JSONObject intersection : getAllIntersections()) {
            int id = intersection.getInt("intersection_id");
            int edge1 = intersection.getInt("edge1_id");
            int edge2 = intersection.getInt("edge2_id");
            PVector polar = getPolarCoordinate(intersection, "polar");
            
            println("Intersection " + id + ": edges " + edge1 + "↔" + edge2 + 
                   " at (" + polar.x + ", " + degrees(polar.y) + "°)");
        }
    }
    
    /**
     * Example: Analyze edge types
     */
    void analyzeEdgeTypes() {
        println("\nEdge Type Analysis:");
        for (int type = 0; type <= 4; type++) {
            ArrayList<JSONObject> edges = getEdgesByType(type);
            if (edges.size() > 0) {
                String description = edges.get(0).getString("description");
                println("Type " + type + " (" + description + "): " + edges.size() + " edges");
            }
        }
    }
}

// ========== USAGE EXAMPLE ==========

// Global reader instance
PetersenDataReader reader;

void setupDataReader() {
    reader = new PetersenDataReader();
    
    // Load data file
    if (reader.loadFromFile("static_data_exports/petersen_static_data_latest.json")) {
        // Run example analyses
        reader.printMiddleNodes();
        reader.printIntersectionDetails();
        reader.analyzeEdgeTypes();
        
        // Example: Get specific colors
        color bgColor = reader.getColor("backgroundColor.rgb");
        color middleNodeColor = reader.getColor("nodes.colors.middle");
        
        println("\nColors:");
        println("Background: " + hex(bgColor));
        println("Middle nodes: " + hex(middleNodeColor));
    }
}

// Example rendering function
void renderFromData(PetersenDataReader reader, float scale, float centerX, float centerY) {
    if (reader.data == null) return;
    
    // Draw all segments
    stroke(255);
    strokeWeight(1);
    for (JSONObject segment : reader.getAllSegments()) {
        PVector start = reader.getPolarCoordinate(segment, "start_polar");
        PVector end = reader.getPolarCoordinate(segment, "end_polar");
        
        PVector startCart = reader.polarToCartesian(start, scale);
        PVector endCart = reader.polarToCartesian(end, scale);
        
        line(centerX + startCart.x, centerY + startCart.y,
             centerX + endCart.x, centerY + endCart.y);
    }
    
    // Draw all nodes
    fill(255, 0, 0);
    noStroke();
    for (JSONObject node : reader.getAllNodes()) {
        PVector polar = reader.getPolarCoordinate(node, "polar");
        PVector cart = reader.polarToCartesian(polar, scale);
        
        float radius = Float.parseFloat(node.getString("display_radius")) * scale;
        ellipse(centerX + cart.x, centerY + cart.y, radius * 2, radius * 2);
    }
    
    // Draw intersections
    fill(0, 255, 255);
    for (JSONObject intersection : reader.getAllIntersections()) {
        PVector polar = reader.getPolarCoordinate(intersection, "polar");
        PVector cart = reader.polarToCartesian(polar, scale);
        
        float radius = Float.parseFloat(intersection.getString("display_radius")) * scale;
        ellipse(centerX + cart.x, centerY + cart.y, radius * 2, radius * 2);
    }
}
