import java.util.Map;
import java.util.HashMap;

/**
 * Petersen Graph Debug Module
 */
class DebugModule {
    boolean showDebugInfo = false;
    boolean debugDataPrinted = false;
    DataExporter dataExporter;
    JSONObject config;
    PolarCoordinateConverter polarConverter;

    private StaticDataGenerator staticGenerator;
    private StaticDataExporter staticExporter;
    
    DebugModule(JSONObject config) {
        this.config = config;
        dataExporter = new DataExporter(config);
        polarConverter = new PolarCoordinateConverter();
        staticGenerator = new StaticDataGenerator();
        staticExporter = new StaticDataExporter();
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
        if (key == 's' || key == 'S') {
            exportStaticData(graph);
        }
    }

    private void exportStaticData(PetersenGraph graph) {
        println("Generating static polar coordinate data...");
        StaticPetersenData staticData = staticGenerator.generateStaticData(graph, config);
    
        String timestamp = year() + "" + month() + "" + day() + "_" + hour() + "" + minute() + "" + second();
        String filename = "petersen_static_data_" + timestamp + ".json";
    
        staticExporter.exportToJSON(staticData, filename);
    
        println("Static data export completed!");
        println("File: " + filename);
        println("Summary:");
        println("  - Nodes: " + staticData.nodesByIndex.size());
        println("  - Intersections: " + staticData.intersectionsByIndex.size());
        println("  - Original Edges: " + staticData.originalEdgesByIndex.size());
        println("  - Segments (after intersection splitting): " + staticData.segmentsByIndex.size());
    }
    
    private PolarCoordinate convertToPolar(float x, float y) {
        return polarConverter.cartesianToPolar(x, y);
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
        printPolarCoordinateAnalysis(graph);

        printPolarCoordinateSummaryByIndex(graph);
        printPolarCoordinateSummaryByAngle(graph);
        
        println("\n=====================================");
        println("DATA OUTPUT COMPLETE");
        println("Press 'D' to toggle debug display, 'P' to reprint data, 'E' to export data, 'O' to toggle output dir, 'I' to toggle intersections");
        println("=====================================");
        
        debugDataPrinted = true;
    }

    private void printPolarCoordinateSummaryByIndex(PetersenGraph graph) {
        println("\n--- POLAR COORDINATE SUMMARY (BY INDEX) ---");
        println("All nodes and intersections in index order:");
        println("Format: Type[ID] | Polar(r, θ°) | Layer/Info");
        
        // Print all nodes (in index order)
        for (int i = 0; i < graph.nodes.size(); i++) {
            Node node = graph.nodes.get(i);
            PolarCoordinate polar = convertToPolar(node.x, node.y);
            String layer = polarConverter.getLayerFromChainId(node.chainId);
            
            println(String.format("Node[%2d] | Polar(r=%.3f, θ=%6.1f°) | %s Layer (ChainID:%d)", 
                            i, polar.radius, polar.getAngleDegrees(), layer, node.chainId));
        }
        
        // Print all intersections (in index order)
        ArrayList<Intersection> intersections = graph.getIntersections();
        if (intersections.size() > 0) {
            println("\nIntersections:");
            for (Intersection intersection : intersections) {
            PolarCoordinate polar = polarConverter.cartesianToPolar(intersection.x, intersection.y);
            println(String.format("Int.[%2d] | Polar(r=%.3f, θ=%6.1f°) | E%d↔E%d", 
                    intersection.intersectionId, polar.radius, polar.getAngleDegrees(),
                    intersection.edge1Id, intersection.edge2Id));
            }
        }
    }

    private void printPolarCoordinateSummaryByAngle(PetersenGraph graph) {
        println("\n--- POLAR COORDINATE SUMMARY (BY ANGLE) ---");
        println("All nodes and intersections sorted by angle:");
        println("Format: Type[ID] | Polar(r, θ°) | Layer/Info");
        
        // Create list containing all points (nodes + intersections)
        ArrayList<PolarPoint> allPoints = new ArrayList<PolarPoint>();
        
        // Add all nodes
        for (int i = 0; i < graph.nodes.size(); i++) {
            Node node = graph.nodes.get(i);
            PolarCoordinate polar = convertToPolar(node.x, node.y);
            String layer = polarConverter.getLayerFromChainId(node.chainId);
            String info = String.format("%s Layer (ChainID:%d)", layer, node.chainId);
            allPoints.add(new PolarPoint("Node", i, polar, info));
        }
        
        // Add all intersections
        ArrayList<Intersection> intersections = graph.getIntersections();
        for (Intersection intersection : intersections) {
            PolarCoordinate polar = polarConverter.cartesianToPolar(intersection.x, intersection.y);
            String info = String.format("E%d↔E%d", intersection.edge1Id, intersection.edge2Id);
            allPoints.add(new PolarPoint("Int.", intersection.intersectionId, polar, info));
        }
        
        // Sort by angle
        allPoints.sort((a, b) -> Float.compare(a.polar.getAngleDegrees(), b.polar.getAngleDegrees()));
        
        // Print sorted results
        for (PolarPoint point : allPoints) {
            println(String.format("%s[%2d] | Polar(r=%.3f, θ=%6.1f°) | %s", 
                            point.type, point.id, point.polar.radius, 
                            point.polar.getAngleDegrees(), point.info));
        }
        
        // Angular distribution statistics
        println("\n--- ANGULAR DISTRIBUTION STATISTICS ---");
        
        // Group statistics by layer
        Map<String, ArrayList<Float>> layerAngles = new HashMap<String, ArrayList<Float>>();
        layerAngles.put("Middle", new ArrayList<Float>());
        layerAngles.put("Inner", new ArrayList<Float>());
        layerAngles.put("Outer", new ArrayList<Float>());
        layerAngles.put("Intersections", new ArrayList<Float>());
        
        for (PolarPoint point : allPoints) {
            if (point.type.equals("Node")) {
                Node node = graph.nodes.get(point.id);
                String layer = polarConverter.getLayerFromChainId(node.chainId);
                layerAngles.get(layer).add(point.polar.getAngleDegrees());
            } else {
                layerAngles.get("Intersections").add(point.polar.getAngleDegrees());
            }
        }
        
        // Print angular distribution for each layer
        for (String layer : new String[]{"Middle", "Inner", "Outer", "Intersections"}) {
            ArrayList<Float> angles = layerAngles.get(layer);
            if (angles.size() > 0) {
                angles.sort(null);
                println(String.format("%s: %d points", layer, angles.size()));
                
                // Calculate angular intervals
                if (angles.size() > 1) {
                    println("  Angular intervals:");
                    for (int i = 0; i < angles.size(); i++) {
                        float currentAngle = angles.get(i);
                        float nextAngle = (i + 1 < angles.size()) ? angles.get(i + 1) : angles.get(0) + 360;
                        float interval = nextAngle - currentAngle;
                        if (interval > 180) interval = 360 - interval; // Handle crossing 0°
                        
                        println(String.format("    %.1f° → %.1f° (interval: %.1f°)", 
                                        currentAngle, nextAngle % 360, interval));
                    }
                }
                
                // Calculate statistics
                float minAngle = angles.get(0);
                float maxAngle = angles.get(angles.size() - 1);
                float avgInterval = 360.0 / angles.size();
                
                println(String.format("  Range: %.1f° to %.1f° | Expected interval: %.1f°", 
                                minAngle, maxAngle, avgInterval));
            }
        }
        
        // Radial distribution statistics
        println("\n--- RADIAL DISTRIBUTION STATISTICS ---");
        
        // Group by radius
        Map<String, ArrayList<Float>> layerRadii = new HashMap<String, ArrayList<Float>>();
        layerRadii.put("Middle", new ArrayList<Float>());
        layerRadii.put("Inner", new ArrayList<Float>());
        layerRadii.put("Outer", new ArrayList<Float>());
        layerRadii.put("Intersections", new ArrayList<Float>());
        
        for (PolarPoint point : allPoints) {
            if (point.type.equals("Node")) {
                Node node = graph.nodes.get(point.id);
                String layer = polarConverter.getLayerFromChainId(node.chainId);
                layerRadii.get(layer).add(point.polar.radius);
            } else {
                layerRadii.get("Intersections").add(point.polar.radius);
            }
        }
        
        // Print radius statistics
        for (String layer : new String[]{"Middle", "Inner", "Outer", "Intersections"}) {
            ArrayList<Float> radii = layerRadii.get(layer);
            if (radii.size() > 0) {
                float minRadius = radii.stream().min(Float::compare).get();
                float maxRadius = radii.stream().max(Float::compare).get();
                float avgRadius = (float) radii.stream().mapToDouble(Float::doubleValue).average().orElse(0.0);
                
                println(String.format("%s: min=%.4f, max=%.4f, avg=%.4f (variation: %.6f)", 
                                layer, minRadius, maxRadius, avgRadius, maxRadius - minRadius));
            }
        }
    }

    private void printPolarCoordinateAnalysis(PetersenGraph graph) {
        println("\n--- POLAR COORDINATE ANALYSIS ---");
        println("Node positions in both Cartesian and Polar coordinates:");
        println("Format: [Index] ChainID | Cartesian(x, y) | Polar(r, θ) | Layer | Radius Accuracy");
        
        for (int i = 0; i < graph.nodes.size(); i++) {
            Node node = graph.nodes.get(i);
            PolarCoordinate polar = convertToPolar(node.x, node.y);
            String layer = polarConverter.getLayerFromChainId(node.chainId);
            
            // Get theoretical radius for comparison
            float theoreticalRadius = polarConverter.getTheoreticalRadius(layer.toLowerCase(), config);
            float radiusError = abs(polar.radius - theoreticalRadius);
            String accuracy = radiusError < 0.001 ? "EXACT" : String.format("±%.4f", radiusError);
            
            println(String.format("[%2d] C%2d | Cart(%.4f, %.4f) | Polar(%s) | %s | %s", 
                            i, node.chainId, node.x, node.y, 
                            polar.toCompactString(), layer, accuracy));
        }
        
        // Intersection polar coordinates
        ArrayList<Intersection> intersections = graph.getIntersections();
        if (intersections.size() > 0) {
            println("\nIntersection positions in polar coordinates:");
            println("Format: [ID] Cartesian(x, y) | Polar(r, θ) | Edge Intersection");
            
            for (Intersection intersection : intersections) {
                PolarCoordinate polar = polarConverter.cartesianToPolar(intersection.x, intersection.y);
                println(String.format("[%2d] Cart(%.4f, %.4f) | Polar(%s) | E%d↔E%d", 
                                intersection.intersectionId, intersection.x, intersection.y,
                                polar.toCompactString(), intersection.edge1Id, intersection.edge2Id));
            }
        }
        
        // Layer radius verification
        println("\nLayer Radius Verification:");
        println("Expected vs Actual radii for each layer:");
        
        String[] layers = {"inner", "middle", "outer"};
        for (String layer : layers) {
            float expectedRadius = polarConverter.getTheoreticalRadius(layer, config);
            println(String.format("%s Layer: Expected r=%.3f", 
                            layer.substring(0, 1).toUpperCase() + layer.substring(1), expectedRadius));
            
            // Find nodes in this layer and check their actual radii
            for (Node node : graph.nodes) {
                String nodeLayer = polarConverter.getLayerFromChainId(node.chainId).toLowerCase();
                if (nodeLayer.equals(layer)) {
                    PolarCoordinate polar = polarConverter.cartesianToPolar(node.x, node.y);
                    float error = abs(polar.radius - expectedRadius);
                    println(String.format("  Node C%d: Actual r=%.4f (error: %.6f)", 
                                    node.chainId, polar.radius, error));
                }
            }
        }
        
        // Angular distribution analysis
        println("\nAngular Distribution Analysis:");
        println("Expected 5-fold symmetry for inner and middle circles (72° intervals):");
        
        for (String layer : new String[]{"middle", "inner"}) {
            println(layer.substring(0, 1).toUpperCase() + layer.substring(1) + " Circle Angular Positions:");
            ArrayList<Float> angles = new ArrayList<Float>();
            
            for (Node node : graph.nodes) {
                String nodeLayer = polarConverter.getLayerFromChainId(node.chainId).toLowerCase();
                if (nodeLayer.equals(layer)) {
                    PolarCoordinate polar = polarConverter.cartesianToPolar(node.x, node.y);
                    angles.add(polar.getAngleDegrees());
                }
            }
            
            // Sort angles
            angles.sort(null);
            
            for (int i = 0; i < angles.size(); i++) {
                float expectedAngle = i * 72.0;
                float actualAngle = angles.get(i);
                
                // Normalize to find closest expected angle
                float minDiff = Float.MAX_VALUE;
                float bestExpected = expectedAngle;
                for (int j = 0; j < 5; j++) {
                    float testExpected = j * 72.0;
                    float diff = abs(actualAngle - testExpected);
                    if (diff > 180) diff = 360 - diff;
                    if (diff < minDiff) {
                        minDiff = diff;
                        bestExpected = testExpected;
                    }
                }
                
                println(String.format("  Position %d: %.1f° (expected ~%.1f°, diff: %.1f°)", 
                                i, actualAngle, bestExpected, minDiff));
            }
        }
    }
    
    // Display node indices
    private void displayNodeIndices(PetersenGraph graph) {
        textAlign(CENTER, CENTER);
        
        for (int i = 0; i < graph.nodes.size(); i++) {
            Node node = graph.nodes.get(i);
            
            float scale = min(width, height) * 0.9;
            float screenX = width/2 + node.x * scale;
            float screenY = height/2 + node.y * scale;
            
            fill(255, 255, 255, 255);
            textSize(16);
            text("C" + str(node.chainId), screenX, screenY);
        }
    }
    
    // Display edge indices
    private void displayEdgeIndices(PetersenGraph graph) {
        textAlign(CENTER, CENTER);
        textSize(12);
        
        for (int i = 0; i < graph.edges.size(); i++) {
            Edge edge = graph.edges.get(i);
            
            float midX = (edge.from.x + edge.to.x) / 2;
            float midY = (edge.from.y + edge.to.y) / 2;
            
            float scale = min(width, height) * 0.9;
            float screenX = width/2 + midX * scale;
            float screenY = height/2 + midY * scale;
            
            float edgeAngle = atan2(edge.to.y - edge.from.y, edge.to.x - edge.from.x);
            float perpAngle = edgeAngle + PI/2;
            
            float offsetX = cos(perpAngle) * 18;
            float offsetY = sin(perpAngle) * 18;
            
            screenX += offsetX;
            screenY += offsetY;
            
            fill(0, 0, 0, 140);
            ellipse(screenX, screenY, 22, 16);
            
            fill(255, 255, 0, 200);
            text("E" + str(edge.edgeId), screenX, screenY);
        }
    }
    
    // Render instruction text
    private void renderInstructions(PetersenGraph graph) {
        fill(255, 255, 255, 120);
        textAlign(LEFT, TOP);
        textSize(14);
        
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
            text("S: Export static data", startX, startY + lineHeight * 6);
            
            textSize(12);
            text("White C#: Chain IDs", startX, startY + lineHeight * 7.5);
            text("Yellow E#: Edge IDs (E0-E29)", startX, startY + lineHeight * 8.5);
            text("Cyan I#: Intersection IDs", startX, startY + lineHeight * 9.5);
            text("Intersections: " + (graph.showIntersections ? "ON" : "OFF"), startX, startY + lineHeight * 10.5);
            
            textSize(11);
            text("Export: " + dataExporter.getOutputDirectory(), startX, startY + lineHeight * 12);
        } else {
            text("Debug Mode: OFF", startX, startY);
            text("D: Enable debug display", startX, startY + lineHeight * 1);
            text("P: Print graph data", startX, startY + lineHeight * 2);
            text("E: Export data files", startX, startY + lineHeight * 3);
            text("O: Toggle output directory", startX, startY + lineHeight * 4);
            text("I: Toggle intersections", startX, startY + lineHeight * 5);
            text("S: Export static data", startX, startY + lineHeight * 6);
            text("Intersections: " + (graph.showIntersections ? "ON" : "OFF"), startX, startY + lineHeight * 7);
            
            textSize(11);
            text("Export: " + dataExporter.getOutputDirectory(), startX, startY + lineHeight * 8);
        }
    }
    
    // Print node data
    private void printNodesData(PetersenGraph graph) {
        println("\n--- NODES DATA ---");
        println("Total Nodes: " + graph.nodes.size());
        println("Format: [Index] ChainID | Cartesian(x, y) | Polar(r, θ) | Color(r, g, b) | Layer");
        
        for (int i = 0; i < graph.nodes.size(); i++) {
            Node node = graph.nodes.get(i);
            String layer = getNodeLayer(node.chainId);
            
            PolarCoordinate polar = polarConverter.cartesianToPolar(node.x, node.y);
            
            println(String.format("[%2d] ChainID:%2d | Cart(%.4f, %.4f) | Polar(%s) | Color(%.1f, %.1f, %.1f) | %s", 
                            i, node.chainId, node.x, node.y, polar.toCompactString(),
                            node.r, node.g, node.b, layer));
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