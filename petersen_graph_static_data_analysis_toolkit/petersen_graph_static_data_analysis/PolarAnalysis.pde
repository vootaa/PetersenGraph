class PolarAnalysis {
    ArrayList<Node> nodes;
    ArrayList<Edge> edges;
    
    // Analysis results
    HashMap<Float, ArrayList<Node>> radiusGroups;
    HashMap<Integer, ArrayList<Node>> symmetryGroups;
    HashMap<Float, ArrayList<Node>> angleGroups;  
    
    PolarAnalysis(ArrayList<Node> nodes, ArrayList<Edge> edges) {
        this.nodes = nodes;
        this.edges = edges;
        this.radiusGroups = new HashMap<Float, ArrayList<Node>>();
        this.symmetryGroups = new HashMap<Integer, ArrayList<Node>>();
        this.angleGroups = new HashMap<Float, ArrayList<Node>>(); 
    }
    
    // Main analysis function
    void performAnalysis() {
        println("\n=== Polar Coordinate Static Data Analysis ===");
        
        // Group by radius
        groupByRadius();
        
        // Group by angle ranges (including all nodes)
        groupByAngle();
        
        // Group by symmetry (72-degree intervals, new method)
        groupBySymmetryNew();
        
        // Output structured results
        outputStructuredResults();
        
        // Analyze node distribution
        analyzeNodeDistribution();
    }
    
    // Group nodes by radius with tolerance
    void groupByRadius() {
        radiusGroups.clear();
        float tolerance = 0.01;
        
        for (Node node : nodes) {
            float radius = node.getRadius();
            Float groupKey = findRadiusGroup(radius, tolerance);
            
            if (groupKey == null) {
                groupKey = radius;
                radiusGroups.put(groupKey, new ArrayList<Node>());
            }
            radiusGroups.get(groupKey).add(node);
        }
    }
    
    // Group nodes by angle with tolerance (including all node types)
    void groupByAngle() {
        angleGroups.clear();
        float tolerance = 5.0;  // 5 degree tolerance
        
        println("\n--- Angle Grouping Analysis (All Nodes) ---");
        
        for (Node node : nodes) {
            // Include all nodes: regular nodes and intersections
            float rawAngle = node.getNormalizedAngleDegrees();
            float roundedAngle = round(rawAngle);
            
            Float groupKey = findAngleGroup(roundedAngle, tolerance);
            
            if (groupKey == null) {
                groupKey = roundedAngle;
                angleGroups.put(groupKey, new ArrayList<Node>());
            }
            angleGroups.get(groupKey).add(node);
        }
        
        // Output angle grouping results
        ArrayList<Float> sortedAngles = new ArrayList<Float>(angleGroups.keySet());
        Collections.sort(sortedAngles);
        
        println("Found " + angleGroups.size() + " angle groups (rounded to integers):");
        for (Float angle : sortedAngles) {
            ArrayList<Node> groupNodes = angleGroups.get(angle);
            
            // Count node types
            int regularNodes = 0;
            int intersectionNodes = 0;
            for (Node node : groupNodes) {
                if (node.getType().equals("intersection")) {
                    intersectionNodes++;
                } else {
                    regularNodes++;
                }
            }
            
            print("Angle " + nf(angle, 1, 1) + "°: " + groupNodes.size() + " nodes ");
            print("(regular:" + regularNodes + ", intersection:" + intersectionNodes + ") [");
            
            sortNodesByID(groupNodes);
            for (int i = 0; i < groupNodes.size(); i++) {
                Node node = groupNodes.get(i);
                String nodeType = node.getType().equals("intersection") ? "I" : "N";
                print(nodeType + node.getId());
                if (i < groupNodes.size() - 1) print(", ");
            }
            println("]");
        }
        
        // Analyze angle intervals
        analyzeAngleIntervals(sortedAngles);
    }
    
    // Find existing angle group
    Float findAngleGroup(float angle, float tolerance) {
        for (Float existing : angleGroups.keySet()) {
            float diff = abs(existing - angle);
            // Handle 360 degree boundary
            if (diff > 180) diff = 360 - diff;
            if (diff <= tolerance) {
                return existing;
            }
        }
        return null;
    }
    
    // Analyze intervals between angle groups
    void analyzeAngleIntervals(ArrayList<Float> sortedAngles) {
        println("\n--- Angle Interval Analysis ---");
        
        if (sortedAngles.size() < 2) {
            println("Not enough angle groups for interval analysis");
            return;
        }
        
        ArrayList<Float> intervals = new ArrayList<Float>();
        
        for (int i = 0; i < sortedAngles.size(); i++) {
            float currentAngle = sortedAngles.get(i);
            float nextAngle = (i == sortedAngles.size() - 1) ? 
                             (sortedAngles.get(0) + 360) : sortedAngles.get(i + 1);
            
            float interval = nextAngle - currentAngle;
            intervals.add(interval);
            
            println("Interval " + i + ": " + nf(currentAngle, 1, 1) + "° → " + 
                   nf(nextAngle % 360, 1, 1) + "° = " + nf(interval, 1, 1) + "°");
        }
        
        // Analyze interval distribution
        analyzeIntervalDistribution(intervals);
    }
    
    // Analyze interval distribution patterns
    void analyzeIntervalDistribution(ArrayList<Float> intervals) {
        println("\n--- Interval Distribution Patterns ---");
        
        // Calculate statistics
        float totalInterval = 0;
        float minInterval = Float.MAX_VALUE;
        float maxInterval = Float.MIN_VALUE;
        
        for (float interval : intervals) {
            totalInterval += interval;
            minInterval = min(minInterval, interval);
            maxInterval = max(maxInterval, interval);
        }
        
        float avgInterval = totalInterval / intervals.size();
        
        println("Total intervals: " + intervals.size());
        println("Average interval: " + nf(avgInterval, 1, 1) + "°");
        println("Min interval: " + nf(minInterval, 1, 1) + "°");
        println("Max interval: " + nf(maxInterval, 1, 1) + "°");
        println("Expected for even distribution: " + nf(360.0 / intervals.size(), 1, 1) + "°");
        
        // Check if close to multiples of 72 degrees
        println("\nInterval pattern analysis:");
        for (int i = 0; i < intervals.size(); i++) {
            float interval = intervals.get(i);
            float ratio72 = interval / 72.0;
            float ratio36 = interval / 36.0;
            float ratio18 = interval / 18.0;
            
            println("Interval " + i + ": " + nf(interval, 1, 1) + "° " +
                   "(72°×" + nf(ratio72, 1, 2) + ", 36°×" + nf(ratio36, 1, 2) + 
                   ", 18°×" + nf(ratio18, 1, 2) + ")");
        }
    }
    
    // Find existing radius group
    Float findRadiusGroup(float radius, float tolerance) {
        for (Float existing : radiusGroups.keySet()) {
            if (abs(existing - radius) <= tolerance) {
                return existing;
            }
        }
        return null;
    }

    // NEW: Group by symmetry using 72-degree sectors with 5 angle groups per sector
    void groupBySymmetryNew() {
        symmetryGroups.clear();
        
        println("\n--- New 72-Degree Symmetry Grouping (5 angle groups per sector) ---");
        
        // Get sorted angle groups
        ArrayList<Float> sortedAngles = new ArrayList<Float>(angleGroups.keySet());
        Collections.sort(sortedAngles);
        
        println("Total angle groups found: " + sortedAngles.size());
        
        if (sortedAngles.size() < 20) {
            println("Warning: Expected at least 20 angle groups, found " + sortedAngles.size());
            println("Cannot create proper 5-fold symmetry grouping");
            return;
        }
        
        // Create 5 symmetry groups, each containing 5 consecutive angle groups
        // This ensures each group spans approximately 72 degrees (including boundaries)
        int angleGroupsPerSymmetryGroup = 5;
        int totalSymmetryGroups = 5;
        
        for (int group = 0; group < totalSymmetryGroups; group++) {
            ArrayList<Node> groupNodes = new ArrayList<Node>();
            
            // Calculate angle range for this group
            int startAngleIndex = group * angleGroupsPerSymmetryGroup;
            
            println("\n=== Symmetry Group " + group + " ===");
            print("Angle groups: ");
            
            for (int i = 0; i < angleGroupsPerSymmetryGroup; i++) {
                int angleIndex = (startAngleIndex + i) % sortedAngles.size();
                Float angleKey = sortedAngles.get(angleIndex);
                
                print(nf(angleKey, 1, 0) + "° ");
                
                // Add all nodes from this angle group
                ArrayList<Node> angleGroupNodes = angleGroups.get(angleKey);
                for (Node node : angleGroupNodes) {
                    if (!groupNodes.contains(node)) {
                        groupNodes.add(node);
                    }
                }
            }
            println();
            
            symmetryGroups.put(group, groupNodes);
            
            // Print group contents
            sortNodesByID(groupNodes);
            print("Nodes (" + groupNodes.size() + "): [");
            for (int i = 0; i < groupNodes.size(); i++) {
                Node node = groupNodes.get(i);
                String nodeType = node.getType().equals("intersection") ? "I" : "N";
                print(nodeType + node.getId());
                if (i < groupNodes.size() - 1) print(", ");
            }
            println("]");
            
            // Count node types
            int regularNodes = 0, intersectionNodes = 0;
            for (Node node : groupNodes) {
                if (node.getType().equals("intersection")) {
                    intersectionNodes++;
                } else {
                    regularNodes++;
                }
            }
            println("Node types: " + regularNodes + " regular, " + intersectionNodes + " intersection");
            
            // Find internal edges (both endpoints in this group)
            ArrayList<Edge> internalEdges = getGroupInternalEdges(groupNodes);
            println("Internal edges: " + internalEdges.size());
            
            // Print internal edges
            for (int i = 0; i < internalEdges.size(); i++) {
                Edge edge = internalEdges.get(i);
                Node startNode = edge.getStartNode();
                Node endNode = edge.getEndNode();
                
                String startType = startNode.getType().equals("intersection") ? "I" : "N";
                String endType = endNode.getType().equals("intersection") ? "I" : "N";
                
                println("  Edge " + i + ": " + startType + startNode.getId() + " ↔ " + 
                       endType + endNode.getId());
            }
        }
        
        // Verify symmetry grouping
        verifyNewSymmetryGrouping();
    }
    
    // Get internal edges for a group (both endpoints must be in the group)
    ArrayList<Edge> getGroupInternalEdges(ArrayList<Node> groupNodes) {
        ArrayList<Edge> internalEdges = new ArrayList<Edge>();
        
        for (Edge edge : edges) {
            if (edge.isValid()) {
                Node startNode = edge.getStartNode();
                Node endNode = edge.getEndNode();
                
                boolean startInGroup = groupNodes.contains(startNode);
                boolean endInGroup = groupNodes.contains(endNode);
                
                // Only include edges where both endpoints are in the group
                if (startInGroup && endInGroup) {
                    internalEdges.add(edge);
                }
            }
        }
        
        return internalEdges;
    }
    
    // Verify new symmetry grouping
    void verifyNewSymmetryGrouping() {
        println("\n--- New Symmetry Grouping Verification ---");
        
        int totalNodes = 0;
        int totalInternalEdges = 0;
        
        for (int group = 0; group < 5; group++) {
            if (symmetryGroups.containsKey(group)) {
                ArrayList<Node> groupNodes = symmetryGroups.get(group);
                ArrayList<Edge> internalEdges = getGroupInternalEdges(groupNodes);
                
                totalNodes += groupNodes.size();
                totalInternalEdges += internalEdges.size();
                
                println("Group " + group + ": " + groupNodes.size() + " nodes, " + 
                       internalEdges.size() + " internal edges");
            }
        }
        
        println("\nTotal verification:");
        println("Total nodes in all groups: " + totalNodes);
        println("Total nodes in graph: " + nodes.size());
        println("Total internal edges: " + totalInternalEdges);
        println("Total edges in graph: " + edges.size());
        
        // Check for overlapping nodes
        ArrayList<Node> allGroupedNodes = new ArrayList<Node>();
        for (int group = 0; group < 5; group++) {
            if (symmetryGroups.containsKey(group)) {
                for (Node node : symmetryGroups.get(group)) {
                    allGroupedNodes.add(node);
                }
            }
        }
        
        println("Nodes appear " + (totalNodes > nodes.size() ? "multiple times" : "once") + " in groups");
        
        if (totalNodes > nodes.size()) {
            println("Note: Some nodes appear in multiple groups due to angle boundary overlaps");
        }
    }
    
    // Output structured results in array format
    void outputStructuredResults() {
        println("\n--- New Structured Data Output (5 angle groups per symmetry group) ---");
        
        // Output radius groups (unchanged)
        println("\n// Radius group data");
        println("radiusGroups = {");
        ArrayList<Float> sortedRadii = new ArrayList<Float>(radiusGroups.keySet());
        Collections.sort(sortedRadii);
        
        for (int i = 0; i < sortedRadii.size(); i++) {
            Float radius = sortedRadii.get(i);
            ArrayList<Node> groupNodes = radiusGroups.get(radius);
            
            print("  " + nf(radius, 1, 3) + ": [");
            sortNodesByID(groupNodes);
            for (int j = 0; j < groupNodes.size(); j++) {
                Node node = groupNodes.get(j);
                String nodeType = node.getType().equals("intersection") ? "I" : "N";
                print(nodeType + node.getId());
                if (j < groupNodes.size() - 1) print(", ");
            }
            print("]");
            if (i < sortedRadii.size() - 1) print(",");
            println();
        }
        println("};");
        
        // Output angle groups (unchanged)
        println("\n// Angle group data (all nodes, integer degrees)");
        println("angleGroups = {");
        ArrayList<Float> sortedAngles = new ArrayList<Float>(angleGroups.keySet());
        Collections.sort(sortedAngles);
        
        for (int i = 0; i < sortedAngles.size(); i++) {
            Float angle = sortedAngles.get(i);
            ArrayList<Node> groupNodes = angleGroups.get(angle);
            
            print("  " + nf(angle, 1, 0) + "°: [");
            sortNodesByID(groupNodes);
            for (int j = 0; j < groupNodes.size(); j++) {
                Node node = groupNodes.get(j);
                String nodeType = node.getType().equals("intersection") ? "I" : "N";
                print(nodeType + node.getId());
                if (j < groupNodes.size() - 1) print(", ");
            }
            print("]");
            if (i < sortedAngles.size() - 1) print(",");
            println();
        }
        println("};");
        
        // Output NEW symmetry groups
        println("\n// New Five-fold symmetry group data (5 angle groups per symmetry group)");
        println("newSymmetryGroups = {");
        for (int group = 0; group < 5; group++) {
            if (symmetryGroups.containsKey(group)) {
                ArrayList<Node> groupNodes = symmetryGroups.get(group);
                ArrayList<Edge> internalEdges = getGroupInternalEdges(groupNodes);
                
                println("  group" + group + ": {");
                
                // All nodes in this group
                print("    nodes: [");
                sortNodesByID(groupNodes);
                for (int j = 0; j < groupNodes.size(); j++) {
                    Node node = groupNodes.get(j);
                    String nodeType = node.getType().equals("intersection") ? "I" : "N";
                    print(nodeType + node.getId());
                    if (j < groupNodes.size() - 1) print(", ");
                }
                println("],");
                
                // Internal edges (both endpoints in group)
                print("    internalEdges: [");
                for (int j = 0; j < internalEdges.size(); j++) {
                    Edge edge = internalEdges.get(j);
                    Node startNode = edge.getStartNode();
                    Node endNode = edge.getEndNode();
                    
                    String startType = startNode.getType().equals("intersection") ? "I" : "N";
                    String endType = endNode.getType().equals("intersection") ? "I" : "N";
                    
                    print("\"" + startType + startNode.getId() + "-" + endType + endNode.getId() + "\"");
                    if (j < internalEdges.size() - 1) print(", ");
                }
                println("],");
                
                // Statistics
                int regular = 0, intersection = 0;
                for (Node node : groupNodes) {
                    if (node.getType().equals("intersection")) {
                        intersection++;
                    } else {
                        regular++;
                    }
                }
                
                println("    nodeCount: " + groupNodes.size() + ",");
                println("    regularNodes: " + regular + ",");
                println("    intersectionNodes: " + intersection + ",");
                println("    internalEdgeCount: " + internalEdges.size());
                
                print("  }");
            } else {
                print("  group" + group + ": { nodes: [], internalEdges: [], nodeCount: 0, regularNodes: 0, intersectionNodes: 0, internalEdgeCount: 0 }");
            }
            if (group < 4) print(",");
            println();
        }
        println("};");
    }
    
    // Analyze node distribution
    void analyzeNodeDistribution() {
        println("\n--- Node Distribution Analysis ---");
        
        // Count nodes by type and radius
        int regularNodes = 0;
        int intersectionNodes = 0;
        
        for (Node node : nodes) {
            if (node.getType().equals("intersection")) {
                intersectionNodes++;
            } else {
                regularNodes++;
            }
        }
        
        println("Regular nodes: " + regularNodes);
        println("Intersection nodes: " + intersectionNodes);
        println("Total nodes: " + nodes.size());
        
        // Verify Petersen graph structure
        verifyPetersenStructure(regularNodes, intersectionNodes);
    }
    
    // Verify expected Petersen graph structure
    void verifyPetersenStructure(int regular, int intersection) {
        println("\n--- Petersen Graph Structure Verification ---");
        
        boolean correctNodes = (regular == 20 && intersection == 20);
        boolean correctRadii = (radiusGroups.size() >= 2 && radiusGroups.size() <= 5);
        boolean correctSymmetry = (symmetryGroups.size() == 5);
        boolean correctAngles = (angleGroups.size() == 20);
        
        println("Node count check: " + (correctNodes ? "✓" : "✗") + 
            " (expected: 20 regular + 20 intersection, actual: " + regular + "+" + intersection + ")");
        println("Radius grouping check: " + (correctRadii ? "✓" : "✗") + 
            " (expected: 2-5 groups, actual: " + radiusGroups.size() + " groups)");
        println("Angle grouping check: " + (correctAngles ? "✓" : "✗") + 
            " (expected: 20 angle groups, actual: " + angleGroups.size() + " groups)");
        println("Symmetry check: " + (correctSymmetry ? "✓" : "✗") + 
            " (expected: 5 groups, actual: " + symmetryGroups.size() + " groups)");
    }
    
    // Helper method to sort nodes by ID
    void sortNodesByID(ArrayList<Node> nodeList) {
        for (int i = 0; i < nodeList.size() - 1; i++) {
            for (int j = i + 1; j < nodeList.size(); j++) {
                if (nodeList.get(i).getId() > nodeList.get(j).getId()) {
                    Node temp = nodeList.get(i);
                    nodeList.set(i, nodeList.get(j));
                    nodeList.set(j, temp);
                }
            }
        }
    }
    
    // Get symmetry group nodes for UI rendering
    ArrayList<Node> getSymmetryGroup(int group) {
        return symmetryGroups.get(group);
    }
    
    // Get internal edges for UI rendering (NEW METHOD)
    ArrayList<Edge> getGroupRelatedEdges(ArrayList<Node> groupNodes) {
        return getGroupInternalEdges(groupNodes);
    }
    
    // Get radius groups for analysis
    HashMap<Float, ArrayList<Node>> getRadiusGroups() {
        return radiusGroups;
    }
    
    // Get angle groups for analysis
    HashMap<Float, ArrayList<Node>> getAngleGroups() {
        return angleGroups;
    }
    
    // Get symmetry groups for analysis
    HashMap<Integer, ArrayList<Node>> getSymmetryGroups() {
        return symmetryGroups;
    }
}
