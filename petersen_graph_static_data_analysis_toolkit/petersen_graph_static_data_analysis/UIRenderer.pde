class UIRenderer {
    float scale = 600;
    boolean showSymmetryAnalysis = false;
    int currentSymmetryGroup = 1;  // Default to show second group (group1)
    
    UIRenderer() {
    }
    
    // Main rendering function
    void renderAnalysis(AnalysisEngine engine) {
        pushMatrix();
        translate(width/2, height/2);
        
        if (showSymmetryAnalysis) {
            renderSymmetryAnalysis(engine);
        } else {
            renderStandardView(engine);
        }
        
        popMatrix();
        
        // Draw UI info
        drawUI();
    }
    
    // Standard graph view
    void renderStandardView(AnalysisEngine engine) {
        // Draw radius guide circles for reference
        drawRadiusGuides();

        // Draw edges
        stroke(220, 220, 220, 150);
        strokeWeight(1);
        for (Edge edge : engine.getEdges()) {
            if (edge.isValid()) {
                PVector start = edge.getStartNode().getPosition();
                PVector end = edge.getEndNode().getPosition();
                line(start.x * scale, start.y * scale, end.x * scale, end.y * scale);
            }
        }
        
        // Draw nodes
        noStroke();
        for (Node node : engine.getNodes()) {
            PVector pos = node.getPosition();
            
            // Color by type
            if (node.getType().equals("intersection")) {
                fill(0, 255, 255, 200);
            } else if (node.getType().equals("Middle")) {
                fill(255, 100, 100, 200);
            } else if (node.getType().equals("Inner")) {
                fill(100, 255, 100, 200);
            } else {
                fill(255, 255, 100, 200);
            }
            
            // Increase node size
            float nodeSize = 12;
            if (node.getType().equals("intersection")) {
                nodeSize = 8;  // Intersection points slightly smaller
            }
            
            ellipse(pos.x * scale, pos.y * scale, nodeSize, nodeSize);
            
            // Draw node ID with better visibility
            fill(255);
            stroke(0);
            strokeWeight(1);
            textAlign(CENTER);
            textSize(10);
            text(node.getId(), pos.x * scale, pos.y * scale - 16);
            noStroke();
        }
    }
    
    // Draw radius guide circles
    void drawRadiusGuides() {
        stroke(80, 80, 80, 120);
        strokeWeight(1);
        noFill();
        
        // Draw concentric circles for radius reference
        float[] actualRadii = {0.06, 0.15, 0.30, 0.39, 0.41, 0.48};
        for (float r : actualRadii) {
            ellipse(0, 0, r * scale * 2, r * scale * 2);
        }

        noFill();
    }
    
    // Symmetry analysis view - shows specific symmetry group
    void renderSymmetryAnalysis(AnalysisEngine engine) {
        // Check if PolarAnalysis is available and has been run
        PolarAnalysis polarAnalysis = engine.getPolarAnalysis();
        if (polarAnalysis == null) {
            showAnalysisNotReadyMessage("PolarAnalysis not initialized");
            return;
        }
        
        HashMap<Integer, ArrayList<Node>> symmetryGroups = polarAnalysis.getSymmetryGroups();
        if (symmetryGroups == null || symmetryGroups.isEmpty()) {
            showAnalysisNotReadyMessage("Symmetry groups not available. Press P to run polar analysis first.");
            return;
        }
        
        ArrayList<Node> currentGroupNodes = symmetryGroups.get(currentSymmetryGroup);
        if (currentGroupNodes == null || currentGroupNodes.isEmpty()) {
            showAnalysisNotReadyMessage("Symmetry group " + currentSymmetryGroup + " is empty or not found.");
            return;
        }
        
        // Get all edges related to this group (both internal and external connections)
        ArrayList<Edge> groupEdges = getSymmetryGroupRelatedEdges(engine, currentGroupNodes);
        
        // Draw symmetry guide lines and highlight current group sector
        drawSmartSymmetryGuides(currentGroupNodes);
        
        // Draw all edges in very light gray as background
        stroke(30, 30, 30, 80);
        strokeWeight(1);
        for (Edge edge : engine.getEdges()) {
            if (edge.isValid()) {
                PVector start = edge.getStartNode().getPosition();
                PVector end = edge.getEndNode().getPosition();
                line(start.x * scale, start.y * scale, end.x * scale, end.y * scale);
            }
        }
        
        // Draw edges related to current group highlighted
        stroke(255, 150, 0, 255);
        strokeWeight(2);
        for (Edge edge : groupEdges) {
            if (edge.isValid()) {
                PVector start = edge.getStartNode().getPosition();
                PVector end = edge.getEndNode().getPosition();
                line(start.x * scale, start.y * scale, end.x * scale, end.y * scale);
            }
        }
        
        // Draw all nodes in light gray as background
        noStroke();
        for (Node node : engine.getNodes()) {
            if (!currentGroupNodes.contains(node)) {
                PVector pos = node.getPosition();
                fill(80, 80, 80, 100);
                ellipse(pos.x * scale, pos.y * scale, 6, 6);
            }
        }
        
        // Draw current group nodes highlighted
        for (Node node : currentGroupNodes) {
            PVector pos = node.getPosition();
            
            // Color by node type and radius
            if (node.getType().equals("intersection")) {
                float radius = node.getRadius();
                if (radius < 0.1) {
                    fill(255, 100, 255, 255); // Inner intersection - magenta
                } else if (radius < 0.35) {
                    fill(100, 255, 255, 255); // Middle intersection - cyan
                } else {
                    fill(255, 255, 100, 255); // Outer intersection - yellow
                }
            } else {
                // Regular nodes
                String layer = node.getType();
                if (layer.equals("Inner") || node.getRadius() < 0.2) {
                    fill(255, 100, 100, 255); // Inner nodes - red
                } else if (layer.equals("Middle") || node.getRadius() < 0.35) {
                    fill(100, 255, 100, 255); // Middle nodes - green
                } else {
                    fill(100, 100, 255, 255); // Outer nodes - blue
                }
            }
            
            float nodeSize = node.getType().equals("intersection") ? 10 : 15;
            ellipse(pos.x * scale, pos.y * scale, nodeSize, nodeSize);
            
            // Draw node ID with type indicator
            fill(255);
            stroke(0);
            strokeWeight(1);
            textAlign(CENTER);
            textSize(10);
            String nodeLabel = node.getType().equals("intersection") ? "I" + node.getId() : "N" + node.getId();
            text(nodeLabel, pos.x * scale, pos.y * scale - 18);
            noStroke();
        }
        
        // Draw enhanced analysis info
        drawEnhancedSymmetryInfo(currentGroupNodes, groupEdges, polarAnalysis);
    }
    
    // Show message when analysis is not ready
    void showAnalysisNotReadyMessage(String message) {
        fill(255, 100, 100, 200);
        textAlign(CENTER);
        textSize(16);
        text(message, 0, -20);
        
        fill(255, 255, 100, 200);
        textSize(14);
        text("Press P to run Polar Analysis first", 0, 10);
        
        // Still draw the basic structure
        drawRadiusGuides();
        
        // Draw basic symmetry lines
        stroke(100, 100, 100, 120);
        strokeWeight(1);
        for (int i = 0; i < 5; i++) {
            float angle = radians(i * 72);
            float x = cos(angle) * scale * 0.6;
            float y = sin(angle) * scale * 0.6;
            line(0, 0, x, y);
        }
    }
    
    // Get all edges related to a symmetry group (internal and external connections)
    ArrayList<Edge> getSymmetryGroupRelatedEdges(AnalysisEngine engine, ArrayList<Node> groupNodes) {
        ArrayList<Edge> relatedEdges = new ArrayList<Edge>();
        
        for (Edge edge : engine.getEdges()) {
            if (edge.isValid()) {
                boolean startInGroup = groupNodes.contains(edge.getStartNode());
                boolean endInGroup = groupNodes.contains(edge.getEndNode());
                
                // Include edge if at least one node is in the group
                if (startInGroup || endInGroup) {
                    relatedEdges.add(edge);
                }
            }
        }
        
        return relatedEdges;
    }
    
    // Draw smart symmetry guide lines highlighting current group
    void drawSmartSymmetryGuides(ArrayList<Node> currentGroupNodes) {
        // Draw all 5 symmetry sector lines
        stroke(100, 100, 100, 120);
        strokeWeight(1);
        
        for (int i = 0; i < 5; i++) {
            float angle = radians(i * 72);
            float x = cos(angle) * scale * 0.6;
            float y = sin(angle) * scale * 0.6;
            line(0, 0, x, y);
        }
        
        // Draw radius guides
        drawRadiusGuides();
    }
    
    // Draw enhanced symmetry analysis info
    void drawEnhancedSymmetryInfo(ArrayList<Node> nodes, ArrayList<Edge> edges, PolarAnalysis polarAnalysis) {
        pushMatrix();
        translate(-width/2 + 20, -height/2 + 20);
        
        fill(0, 0, 0, 200);
        rect(0, 0, 320, 180);
        
        fill(255);
        textAlign(LEFT);
        textSize(12);
        text("Symmetry Group Analysis - Group " + currentSymmetryGroup, 10, 20);
        
        // Count node types in current group
        int regularNodes = 0, intersectionNodes = 0;
        for (Node node : nodes) {
            if (node.getType().equals("intersection")) {
                intersectionNodes++;
            } else {
                regularNodes++;
            }
        }
        
        text("Nodes: " + nodes.size() + " (Regular:" + regularNodes + ", Intersect:" + intersectionNodes + ")", 10, 40);
        text("Related Edges: " + edges.size(), 10, 60);
        
        // Show angle range for current group
        HashMap<Float, ArrayList<Node>> angleGroups = polarAnalysis.getAngleGroups();
        ArrayList<Float> groupAngles = new ArrayList<Float>();
        
        for (Float angle : angleGroups.keySet()) {
            ArrayList<Node> angleNodes = angleGroups.get(angle);
            for (Node node : angleNodes) {
                if (nodes.contains(node)) {
                    if (!groupAngles.contains(angle)) {
                        groupAngles.add(angle);
                    }
                    break;
                }
            }
        }
        
        Collections.sort(groupAngles);
        if (groupAngles.size() > 0) {
            text("Angle Range: " + nf(groupAngles.get(0), 1, 0) + "° - " + 
                 nf(groupAngles.get(groupAngles.size()-1), 1, 0) + "°", 10, 80);
            
            text("Angles: ", 10, 100);
            String angleStr = "";
            for (int i = 0; i < groupAngles.size(); i++) {
                angleStr += nf(groupAngles.get(i), 1, 0) + "°";
                if (i < groupAngles.size() - 1) angleStr += ", ";
            }
            text(angleStr, 60, 100);
        }
        
        text("Controls:", 10, 130);
        text("V - Toggle view  |  1-5 - Select group", 10, 150);
        text("P - Polar analysis  |  +/- - Zoom", 10, 170);
        
        popMatrix();
    }
    
    // Draw UI information
    void drawUI() {
        // Status info
        fill(0, 0, 0, 180);
        rect(10, height - 160, 240, 150);
        
        fill(255);
        textAlign(LEFT);
        textSize(12);
        text("Controls:", 20, height - 140);
        text("P - Polar analysis", 20, height - 120);
        text("G - Polygon component analysis", 20, height - 100);
        text("V - Toggle view", 20, height - 80);
        text("1-5 - Select symmetry group", 20, height - 60);
        text("+ / - Zoom in/out", 20, height - 40);
        text("0 - Reset zoom", 20, height - 20);
        
        // Show current scale
        fill(255, 255, 0);
        text("Zoom: " + nf(scale/100.0, 1, 1) + "x", width - 100, height - 20);
        
        // Show current view mode
        fill(100, 255, 100);
        if (showSymmetryAnalysis) {
            text("View: Symmetry Group " + currentSymmetryGroup, width - 140, height - 40);
        } else {
            text("View: Standard", width - 100, height - 40);
        }
    }
    
    // Toggle symmetry analysis view
    void toggleSymmetryView() {
        showSymmetryAnalysis = !showSymmetryAnalysis;
        println("View toggled: " + (showSymmetryAnalysis ? "Symmetry Group " + currentSymmetryGroup : "Standard View"));
        
        // If switching to symmetry view, provide guidance
        if (showSymmetryAnalysis) {
            println("Note: If symmetry group is not found, run Polar Analysis first (press P)");
        }
    }
    
    // Set current symmetry group (0-4)
    void setSymmetryGroup(int group) {
        if (group >= 0 && group <= 4) {
            currentSymmetryGroup = group;
            println("Switched to symmetry group " + group);
        }
    }
    
    // Adjust scale
    void adjustScale(float factor) {
        scale *= factor;
        scale = constrain(scale, 400, 800);  // Expand zoom range
        //println("Scale adjusted to: " + nf(scale/100.0, 1, 1) + "x");
    }
}