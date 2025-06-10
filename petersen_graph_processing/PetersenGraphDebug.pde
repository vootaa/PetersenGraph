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
        dataExporter = new DataExporter(config); // Pass config to DataExporter
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
            // Toggle output directory between data/ and exports/
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
    
    // Display node indices - Fixed coordinate transformation
    private void displayNodeIndices(PetersenGraph graph) {
        textAlign(CENTER, CENTER);
        textSize(12);
        
        for (int i = 0; i < graph.nodes.size(); i++) {
            Node node = graph.nodes.get(i);
            
            // Apply same transformation as PetersenGraph.display()
            float scale = min(width, height) * 0.4;
            float screenX = width/2 + node.x * scale;
            float screenY = height/2 + node.y * scale;
            
            // Draw background circle for index
            fill(0, 0, 0, 150);
            ellipse(screenX, screenY - 25, 22, 16);
            
            // Draw index text
            fill(255, 255, 255, 220);
            text(str(i), screenX, screenY - 25);
            
            // Draw ChainID
            fill(200, 200, 200, 180);
            text("C" + str(node.chainId), screenX, screenY + 25);
        }
    }
    
    // Display edge indices - Fixed coordinate transformation
    private void displayEdgeIndices(PetersenGraph graph) {
        textAlign(CENTER, CENTER);
        textSize(10);
        
        for (int i = 0; i < graph.edges.size(); i++) {
            Edge edge = graph.edges.get(i);
            
            // Calculate edge midpoint
            float midX = (edge.from.x + edge.to.x) / 2;
            float midY = (edge.from.y + edge.to.y) / 2;
            
            // Apply same transformation as PetersenGraph.display()
            float scale = min(width, height) * 0.4;
            float screenX = width/2 + midX * scale;
            float screenY = height/2 + midY * scale;
            
            // Draw background
            fill(0, 0, 0, 120);
            ellipse(screenX, screenY, 18, 14);
            
            // Draw edge index
            fill(255, 255, 0, 200);
            text(str(i), screenX, screenY);
        }
    }
    
    // Render instruction text
    private void renderInstructions() {
        fill(255, 255, 255, 100);
        textAlign(LEFT, TOP);
        textSize(12);
        
        if (showDebugInfo) {
            text("Debug Mode: ON", 10, 10);
            text("D: Toggle debug display", 10, 25);
            text("P: Print graph data", 10, 40);
            text("E: Export data files", 10, 55);
            text("O: Toggle output directory", 10, 70);
            text("White numbers: Node indices", 10, 85);
            text("Yellow numbers: Edge indices", 10, 100);
            text("Gray 'C' numbers: Chain IDs", 10, 115);
            text("Export dir: " + dataExporter.getOutputDirectory(), 10, 135);
        } else {
            text("Debug Mode: OFF", 10, 10);
            text("D: Enable debug display", 10, 25);
            text("P: Print graph data", 10, 40);
            text("E: Export data files", 10, 55);
            text("O: Toggle output directory", 10, 70);
            text("Export dir: " + dataExporter.getOutputDirectory(), 10, 90);
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
            case 3: return "Inner Circle";
            case 4: return "Outer Circle";
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