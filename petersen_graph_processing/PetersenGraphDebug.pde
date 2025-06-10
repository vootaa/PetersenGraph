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
        println("Petersen Graph loaded. Press 'D' for debug info, 'P' to print data, 'E' to export files.");
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
            dataExporter.exportToCSV(graph, "petersen_nodes.csv", "petersen_edges.csv");
        }
        if (key == 'o' || key == 'O') {
            String currentDir = dataExporter.getOutputDirectory();
            if (currentDir.equals("data/")) {
                dataExporter.setOutputDirectory("exports/");
            } else {
                dataExporter.setOutputDirectory("data/");
            }
        }
    }
    
    // Render debug information
    void renderDebugInfo(PetersenGraph graph) {
        if (showDebugInfo) {
            displayNodeIndices(graph);
            displayEdgeIndices(graph);
        }
        renderInstructions();
    }
    
    // Print complete graph data
    void printCompleteGraphData(PetersenGraph graph) {
        println("=====================================");
        println("PETERSEN GRAPH COMPLETE DATA");
        println("=====================================");
        
        printNodesData(graph);
        printEdgesData(graph);
        printConnectionStatistics(graph);
        printNodeDegrees(graph);
        
        println("\n=====================================");
        println("DATA OUTPUT COMPLETE");
        println("Press 'D' to toggle debug display, 'P' to reprint data, 'E' to export data, 'O' to toggle output dir");
        println("=====================================");
        
        debugDataPrinted = true;
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
    
    // Display node indices - Fixed coordinate transformation and larger fonts
    private void displayNodeIndices(PetersenGraph graph) {
        textAlign(CENTER, CENTER);
        textSize(16); // Increased from 12 to 16
        
        for (int i = 0; i < graph.nodes.size(); i++) {
            Node node = graph.nodes.get(i);
            
            // Apply same transformation as PetersenGraph.display()
            float scale = min(width, height) * 0.9; // Match PetersenGraph scale
            float screenX = width/2 + node.x * scale;
            float screenY = height/2 + node.y * scale;
            
            // Draw background circle for index
            fill(0, 0, 0, 180);
            ellipse(screenX, screenY - 35, 28, 20); // Larger background
            
            // Draw index text
            fill(255, 255, 255, 255);
            text(str(i), screenX, screenY - 35);
            
            // Draw ChainID
            fill(200, 200, 200, 220);
            textSize(14); // Slightly smaller for ChainID
            text("C" + str(node.chainId), screenX, screenY + 35);
            textSize(16); // Reset to main size
        }
    }
    
    // Display edge indices - Fixed coordinate transformation and larger fonts
    private void displayEdgeIndices(PetersenGraph graph) {
        textAlign(CENTER, CENTER);
        textSize(14); // Increased from 10 to 14
        
        for (int i = 0; i < graph.edges.size(); i++) {
            Edge edge = graph.edges.get(i);
            
            // Calculate edge midpoint
            float midX = (edge.from.x + edge.to.x) / 2;
            float midY = (edge.from.y + edge.to.y) / 2;
            
            // Apply same transformation as PetersenGraph.display()
            float scale = min(width, height) * 0.9; // Match PetersenGraph scale
            float screenX = width/2 + midX * scale;
            float screenY = height/2 + midY * scale;
            
            // Draw background
            fill(0, 0, 0, 150);
            ellipse(screenX, screenY, 24, 18); // Larger background
            
            // Draw edge index
            fill(255, 255, 0, 255);
            text(str(i), screenX, screenY);
        }
    }
    
    // Render instruction text with larger fonts
    private void renderInstructions() {
        fill(255, 255, 255, 120);
        textAlign(LEFT, TOP);
        textSize(16); // Increased from 12 to 16
        
        if (showDebugInfo) {
            text("Debug Mode: ON", 15, 15);
            text("D: Toggle debug display", 15, 35);
            text("P: Print graph data", 15, 55);
            text("E: Export data files", 15, 75);
            text("O: Toggle output directory", 15, 95);
            text("White numbers: Node indices", 15, 115);
            text("Yellow numbers: Edge indices", 15, 135);
            text("Gray 'C' numbers: Chain IDs", 15, 155);
            text("Export dir: " + dataExporter.getOutputDirectory(), 15, 180);
        } else {
            text("Debug Mode: OFF", 15, 15);
            text("D: Enable debug display", 15, 35);
            text("P: Print graph data", 15, 55);
            text("E: Export data files", 15, 75);
            text("O: Toggle output directory", 15, 95);
            text("Export dir: " + dataExporter.getOutputDirectory(), 15, 120);
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