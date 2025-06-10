/**
 * Petersen Graph Debug Module
 */
class DebugModule {
    boolean showDebugInfo = false;
    boolean debugDataPrinted = false;
    DataExporter dataExporter;
    JSONObject config;
    
    DebugModule(JSONObject config) {
        this.config = config;
        dataExporter = new DataExporter(config);
    }
    
    // Initialize debug functionality
    void initialize(PetersenGraph graph) {
        println("Petersen Graph loaded. Press 'D' for debug info, 'P' to print data, 'E' to export files, 'I' to toggle intersections.");
        println("Export directory: " + dataExporter.getOutputDirectory());
    }
    
    // Process keyboard input
    void handleKeyPressed(PetersenGraph graph) {
        if (key == 'd' || key == 'D') {
            showDebugInfo = !showDebugInfo;
            println("Debug info display: " + (showDebugInfo ? "ON" : "OFF"));
        }
        if (key == 'p' || key == 'P') {
            printCompleteGraphData(graph);
        }
        if (key == 'e' || key == 'E') {
            dataExporter.exportToJSON(graph, "petersen_graph_data.json");
            dataExporter.exportToCSV(graph, "petersen_nodes.csv", "petersen_edges.csv", "petersen_intersections.csv");
        }
        if (key == 'o' || key == 'O') {
            String currentDir = dataExporter.getOutputDirectory();
            if (currentDir.equals("data/")) {
                dataExporter.setOutputDirectory("exports/");
            } else {
                dataExporter.setOutputDirectory("data/");
            }
        }
        if (key == 'i' || key == 'I') {
            graph.toggleIntersections();
        }
    }
    
    // Render debug information
    void renderDebugInfo(PetersenGraph graph) {
        if (showDebugInfo) {
            displayNodeIndices(graph);
            displayEdgeIndices(graph);

            if (graph.showIntersections) {
                displayIntersectionIndices(graph);
            }
        }
        renderInstructions(graph);
    }
    
    private void displayIntersectionIndices(PetersenGraph graph) {
        textAlign(CENTER, CENTER);
        textSize(10);
        
        ArrayList<Intersection> intersections = graph.getIntersections();
        for (Intersection intersection : intersections) {
            // Apply same transformation as PetersenGraph.display()
            float scale = min(width, height) * 0.9;
            float screenX = width/2 + intersection.x * scale;
            float screenY = height/2 + intersection.y * scale;

            float invertedR = 1.0 - intersection.r;
            float invertedG = 1.0 - intersection.g;
            float invertedB = 1.0 - intersection.b;
            
            fill(invertedR * 255, invertedG * 255, invertedB * 255, 255);
            text("i." + str(intersection.intersectionId), screenX, screenY);
        }
    }
    
    // Print complete graph data
    void printCompleteGraphData(PetersenGraph graph) {
        println("=====================================");
        println("PETERSEN GRAPH COMPLETE DATA");
        println("=====================================");
        
        printNodesData(graph);
        printEdgesData(graph);
        graph.printIntersectionData();
        printConnectionStatistics(graph);
        printNodeDegrees(graph);
        
        println("\n=====================================");
        println("DATA OUTPUT COMPLETE");
        println("Press 'D' to toggle debug display, 'P' to reprint data, 'E' to export data, 'O' to toggle output dir, 'I' to toggle intersections");
        println("=====================================");
        
        debugDataPrinted = true;
    }
    
    // Display node indices - Fixed to show ChainID in center and prevent overlap
    private void displayNodeIndices(PetersenGraph graph) {
        textAlign(CENTER, CENTER);
        
        for (int i = 0; i < graph.nodes.size(); i++) {
            Node node = graph.nodes.get(i);
            
            // Apply same transformation as PetersenGraph.display()
            float scale = min(width, height) * 0.9;
            float screenX = width/2 + node.x * scale;
            float screenY = height/2 + node.y * scale;
            
            // Simply draw ChainID directly on the node (no background)
            fill(255, 255, 255, 255); // White text
            textSize(16); // Slightly larger for better visibility
            text("C" + str(node.chainId), screenX, screenY);
        }
    }
    
    
    // Display edge indices - Improved positioning to reduce overlap
    private void displayEdgeIndices(PetersenGraph graph) {
        textAlign(CENTER, CENTER);
        textSize(12);
        
        for (int i = 0; i < graph.edges.size(); i++) {
            Edge edge = graph.edges.get(i);
            
            // Calculate edge midpoint
            float midX = (edge.from.x + edge.to.x) / 2;
            float midY = (edge.from.y + edge.to.y) / 2;
            
            // Apply same transformation as PetersenGraph.display()
            float scale = min(width, height) * 0.9;
            float screenX = width/2 + midX * scale;
            float screenY = height/2 + midY * scale;
            
            // Offset edge labels slightly to reduce overlap
            float edgeAngle = atan2(edge.to.y - edge.from.y, edge.to.x - edge.from.x);
            float perpAngle = edgeAngle + PI/2;
            
            // Small offset perpendicular to edge
            float offsetX = cos(perpAngle) * 18;
            float offsetY = sin(perpAngle) * 18;
            
            screenX += offsetX;
            screenY += offsetY;
            
            // Draw smaller background for edge index
            fill(0, 0, 0, 140);
            ellipse(screenX, screenY, 22, 16);
            
            // Draw edge index
            fill(255, 255, 0, 200);
            text("E" + str(edge.edgeId), screenX, screenY);
        }
    }
    
    // Render instruction text - Updated with intersection controls
    private void renderInstructions(PetersenGraph graph) {
        fill(255, 255, 255, 120);
        textAlign(LEFT, TOP);
        textSize(14);
        
        // Position instructions in top-right corner to avoid graph overlap
        float startX = width - 270;
        float startY = 15;
        float lineHeight = 18;
        
        if (showDebugInfo) {
            text("Debug Mode: ON", startX, startY);
            text("D: Toggle debug display", startX, startY + lineHeight * 1);
            text("P: Print graph data", startX, startY + lineHeight * 2);
            text("E: Export data files", startX, startY + lineHeight * 3);
            text("O: Toggle output directory", startX, startY + lineHeight * 4);
            text("I: Toggle intersections", startX, startY + lineHeight * 5);
            
            textSize(12);
            text("White C#: Chain IDs", startX, startY + lineHeight * 6.5);
            text("Yellow E#: Edge IDs (E0-E29)", startX, startY + lineHeight * 7.5);
            text("Cyan I#: Intersection IDs", startX, startY + lineHeight * 8.5);
            text("Intersections: " + (graph.showIntersections ? "ON" : "OFF"), startX, startY + lineHeight * 9.5);
            
            textSize(11);
            text("Export: " + dataExporter.getOutputDirectory(), startX, startY + lineHeight * 11);
        } else {
            text("Debug Mode: OFF", startX, startY);
            text("D: Enable debug display", startX, startY + lineHeight * 1);
            text("P: Print graph data", startX, startY + lineHeight * 2);
            text("E: Export data files", startX, startY + lineHeight * 3);
            text("O: Toggle output directory", startX, startY + lineHeight * 4);
            text("I: Toggle intersections", startX, startY + lineHeight * 5);
            text("Intersections: " + (graph.showIntersections ? "ON" : "OFF"), startX, startY + lineHeight * 6);
            
            textSize(11);
            text("Export: " + dataExporter.getOutputDirectory(), startX, startY + lineHeight * 8);
        }
    }
    
    // Print node data
    private void printNodesData(PetersenGraph graph) {
        println("\n--- NODES DATA ---");
        println("Total Nodes: " + graph.nodes.size());
        println("Format: [Index] ChainID | Position(x, y) | Color(r, g, b) | Layer");
        
        for (int i = 0; i < graph.nodes.size(); i++) {
            Node node = graph.nodes.get(i);
            String layer = getNodeLayer(node.chainId);
            
            println(String.format("[%2d] ChainID:%2d | Position(%.4f, %.4f) | Color(%.1f, %.1f, %.1f) | %s", 
                            i, node.chainId, node.x, node.y, node.r, node.g, node.b, layer));
        }
    }
    
    // Print edge data
    private void printEdgesData(PetersenGraph graph) {
        println("\n--- EDGES DATA ---");
        println("Total Edges: " + graph.edges.size());
        println("Format: [Index] Type | From->To (ChainIDs) | Color(r, g, b) | Description");
        
        for (int i = 0; i < graph.edges.size(); i++) {
            Edge edge = graph.edges.get(i);
            String description = getEdgeTypeDescription(edge.type);
            
            println(String.format("[%2d] Type:%d | %2d->%2d | Color(%.1f, %.1f, %.1f) | %s", 
                            i, edge.type, edge.from.chainId, edge.to.chainId, 
                            edge.r, edge.g, edge.b, description));
        }
    }
    
    // Print connection statistics
    private void printConnectionStatistics(PetersenGraph graph) {
        println("\n--- CONNECTION STATISTICS ---");
        int[] typeCount = new int[5];
        for (Edge edge : graph.edges) {
            typeCount[edge.type]++;
        }
        
        for (int i = 0; i < typeCount.length; i++) {
            println("Type " + i + " (" + getEdgeTypeDescription(i) + "): " + typeCount[i] + " edges");
        }
        
        ArrayList<Intersection> intersections = graph.getIntersections();
        println("\nIntersections: " + intersections.size() + " edge crossings");
    }
    
    // Print degree of each node
    private void printNodeDegrees(PetersenGraph graph) {
        println("\n--- NODE DEGREES ---");
        int[] nodeDegrees = new int[graph.nodes.size()];
        for (Edge edge : graph.edges) {
            nodeDegrees[getNodeIndex(edge.from, graph)]++;
            nodeDegrees[getNodeIndex(edge.to, graph)]++;
        }
        
        for (int i = 0; i < nodeDegrees.length; i++) {
            println("Node " + i + " (ChainID:" + graph.nodes.get(i).chainId + "): degree " + nodeDegrees[i]);
        }
    }
    
    // Utility methods
    private String getNodeLayer(int chainId) {
        if (chainId >= 0 && chainId <= 4) return "Middle";
        else if (chainId >= 5 && chainId <= 9) return "Inner";
        else if (chainId >= 10 && chainId <= 19) return "Outer";
        return "Unknown";
    }
    
    private String getEdgeTypeDescription(int type) {
        switch(type) {
            case 0: return "Middle to Inner";
            case 1: return "Middle to Outer A";
            case 2: return "Middle to Outer B";
            case 3: return "Inner Circle (Pentagram)";
            case 4: return "Outer Circle (Loop)";
            default: return "Unknown";
        }
    }
    
    private int getNodeIndex(Node node, PetersenGraph graph) {
        for (int i = 0; i < graph.nodes.size(); i++) {
            if (graph.nodes.get(i) == node) {
                return i;
            }
        }
        return -1;
    }
}