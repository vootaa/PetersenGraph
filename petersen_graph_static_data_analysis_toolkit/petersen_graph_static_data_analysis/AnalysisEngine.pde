import java.util.*;

class AnalysisEngine {
    PetersenDataReader dataReader;
    ArrayList<Node> nodes;
    ArrayList<Edge> edges;
    
    // Analysis modules
    PolarAnalysis polarAnalysis;
    PolygonAnalysis polygonAnalysis;

    AnalysisEngine(PetersenDataReader reader) {
        this.dataReader = reader;
        this.nodes = new ArrayList<Node>();
        this.edges = new ArrayList<Edge>();
        
        // Convert Petersen data to our analysis format
        convertDataToAnalysisFormat();
        
        // Initialize analysis modules
        this.polarAnalysis = new PolarAnalysis(nodes, edges);
        this.polygonAnalysis = new PolygonAnalysis(nodes, edges);
    }

    // Convert Petersen data to Node/Edge objects for analysis
    void convertDataToAnalysisFormat() {
        nodes.clear();
        edges.clear();
        
        // Convert nodes
        ArrayList<JSONObject> petersenNodes = dataReader.getAllNodes();
        for (JSONObject nodeObj : petersenNodes) {
            Node node = new Node(nodeObj);
            nodes.add(node);
        }
        
        // Convert intersections as special nodes
        ArrayList<JSONObject> intersections = dataReader.getAllIntersections();
        for (JSONObject intersectionObj : intersections) {
            // Create a modified JSONObject for intersection
            JSONObject modifiedObj = new JSONObject();
            modifiedObj.setInt("id", intersectionObj.getInt("intersection_id") + 1000);
            modifiedObj.setFloat("x", intersectionObj.getJSONObject("cartesian").getFloat("x"));
            modifiedObj.setFloat("y", intersectionObj.getJSONObject("cartesian").getFloat("y"));
            modifiedObj.setString("type", "intersection");
            
            Node node = new Node(modifiedObj);
            nodes.add(node);
        }
        
        // Convert segments as edges
        ArrayList<JSONObject> segments = dataReader.getAllSegments();
        for (JSONObject segmentObj : segments) {
            int segmentId = segmentObj.getInt("segment_id");
            int startNodeId = segmentObj.getInt("start_node_id");
            int endNodeId = segmentObj.getInt("end_node_id");
            int parentEdgeId = segmentObj.getInt("parent_edge_id");
            
            Node startNode = findNodeById(startNodeId);
            Node endNode = findNodeById(endNodeId);
            
            if (startNode != null && endNode != null) {
                Edge edge = new Edge(segmentId, startNode, endNode, parentEdgeId);
                edges.add(edge);
            }
        }
        
        println("Data conversion completed: " + nodes.size() + " nodes, " + edges.size() + " edges");
    }
    
    // Find node by ID (including offset intersections)
    Node findNodeById(int nodeId) {
        for (Node node : nodes) {
            if (node.getId() == nodeId || node.getId() == nodeId + 1000) {
                return node;
            }
        }
        return null;
    }

    // Perform complete polar coordinate analysis
    void performPolarAnalysis() {
        polarAnalysis.performAnalysis();
    }
    
    // Perform complete polygon analysis
    void performPolygonAnalysis() {
        polygonAnalysis.performAnalysis();
    }
    
    // Perform complete analysis (both polar and polygon)
    void performCompleteAnalysis() {
        println("\n==========================================");
        println("   PETERSEN GRAPH COMPLETE STRUCTURE ANALYSIS");
        println("==========================================");
        
        performPolarAnalysis();
        performPolygonAnalysis();
        
        println("\n==========================================");
        println("            ANALYSIS COMPLETED");
        println("==========================================");
    }
    
    // Get analysis modules for UI rendering
    PolarAnalysis getPolarAnalysis() { return polarAnalysis; }
    PolygonAnalysis getPolygonAnalysis() { return polygonAnalysis; }
    
    // Get nodes and edges for UI rendering
    ArrayList<Node> getNodes() { return new ArrayList<Node>(nodes); }
    ArrayList<Edge> getEdges() { return new ArrayList<Edge>(edges); }
}