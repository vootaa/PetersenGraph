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
        
        // Group by symmetry (72-degree intervals)
        groupBySymmetry();
        
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

    // Group nodes by 72-degree symmetry based on actual angle groups (with connected boundary nodes)
    void groupBySymmetry() {
        symmetryGroups.clear();
        
        println("\n--- Enhanced 72-Degree Symmetry Grouping (Including Boundary Connections) ---");
        
        // Get sorted angle groups
        ArrayList<Float> sortedAngles = new ArrayList<Float>(angleGroups.keySet());
        Collections.sort(sortedAngles);
        
        // Expected: 20 angle groups → 5 symmetry groups of 4 angle groups each
        if (sortedAngles.size() != 20) {
            println("Warning: Expected 20 angle groups, found " + sortedAngles.size());
        }
        
        // First pass: Group every 4 consecutive angle groups into one symmetry group (core nodes)
        HashMap<Integer, ArrayList<Node>> coreGroups = new HashMap<Integer, ArrayList<Node>>();
        
        for (int i = 0; i < sortedAngles.size(); i++) {
            int symmetryGroup = i / 4;  // 0-3 → group 0, 4-7 → group 1, etc.
            
            if (!coreGroups.containsKey(symmetryGroup)) {
                coreGroups.put(symmetryGroup, new ArrayList<Node>());
            }
            
            // Add all nodes from this angle group to the core group
            Float angleKey = sortedAngles.get(i);
            ArrayList<Node> angleGroupNodes = angleGroups.get(angleKey);
            
            for (Node node : angleGroupNodes) {
                coreGroups.get(symmetryGroup).add(node);
            }
        }
        
        // Second pass: Add boundary nodes connected to core nodes
        for (int group = 0; group < 5; group++) {
            ArrayList<Node> coreNodes = coreGroups.get(group);
            ArrayList<Node> expandedGroup = new ArrayList<Node>();
            
            // Add all core nodes
            for (Node node : coreNodes) {
                expandedGroup.add(node);
            }
            
            // Find connected boundary nodes
            ArrayList<Node> boundaryNodes = findBoundaryNodes(coreNodes);
            for (Node boundaryNode : boundaryNodes) {
                if (!expandedGroup.contains(boundaryNode)) {
                    expandedGroup.add(boundaryNode);
                }
            }
            
            symmetryGroups.put(group, expandedGroup);
        }
        
        // Print enhanced symmetry groups with edge information
        printEnhancedSymmetryGroups();
        
        // Verify and print symmetry groups
        println("\nCreated " + symmetryGroups.size() + " enhanced symmetry groups:");
        for (int group = 0; group < symmetryGroups.size(); group++) {
            if (symmetryGroups.containsKey(group)) {
                ArrayList<Node> groupNodes = symmetryGroups.get(group);
                ArrayList<Node> coreNodes = coreGroups.get(group);
                ArrayList<Node> boundaryNodes = new ArrayList<Node>();
                
                for (Node node : groupNodes) {
                    if (!coreNodes.contains(node)) {
                        boundaryNodes.add(node);
                    }
                }
                
                println("Enhanced Group " + group + ": " + groupNodes.size() + " total nodes");
                println("  Core nodes (" + coreNodes.size() + "): " + getNodeIdList(coreNodes));
                println("  Boundary nodes (" + boundaryNodes.size() + "): " + getNodeIdList(boundaryNodes));
                
                // Count node types
                int regular = 0, intersection = 0;
                for (Node node : groupNodes) {
                    if (node.getType().equals("intersection")) {
                        intersection++;
                    } else {
                        regular++;
                    }
                }
                println("  Node types: " + regular + " regular, " + intersection + " intersection");
            }
        }
        
        // Verify enhanced symmetry intervals
        verifyEnhancedSymmetryStructure();
    }

    // Find boundary nodes connected to core nodes
    ArrayList<Node> findBoundaryNodes(ArrayList<Node> coreNodes) {
        ArrayList<Node> boundaryNodes = new ArrayList<Node>();
        
        for (Edge edge : edges) {
            if (edge.isValid()) {
                Node startNode = edge.getStartNode();
                Node endNode = edge.getEndNode();
                
                boolean startInCore = coreNodes.contains(startNode);
                boolean endInCore = coreNodes.contains(endNode);
                
                // If one node is in core and other is not, the other is a boundary node
                if (startInCore && !endInCore && !boundaryNodes.contains(endNode)) {
                    boundaryNodes.add(endNode);
                }
                if (endInCore && !startInCore && !boundaryNodes.contains(startNode)) {
                    boundaryNodes.add(startNode);
                }
            }
        }
        
        return boundaryNodes;
    }

    // Get related edges for a group (including boundary connections)
    ArrayList<Edge> getGroupRelatedEdges(ArrayList<Node> groupNodes) {
        ArrayList<Edge> relatedEdges = new ArrayList<Edge>();
        
        for (Edge edge : edges) {
            if (edge.isValid()) {
                Node startNode = edge.getStartNode();
                Node endNode = edge.getEndNode();
                
                boolean startInGroup = groupNodes.contains(startNode);
                boolean endInGroup = groupNodes.contains(endNode);
                
                // Include edge if both nodes are in the group OR if it's a boundary connection
                if ((startInGroup && endInGroup) || (startInGroup && !endInGroup) || (!startInGroup && endInGroup)) {
                    relatedEdges.add(edge);
                }
            }
        }
        
        return relatedEdges;
    }

    // Print enhanced symmetry groups with detailed edge information
    void printEnhancedSymmetryGroups() {
        println("\n--- Enhanced Five-fold Symmetry Groups (with Boundary Connections) ---");
        
        for (int group = 0; group < 5; group++) {
            if (symmetryGroups.containsKey(group)) {
                ArrayList<Node> groupNodes = symmetryGroups.get(group);
                ArrayList<Edge> groupEdges = getGroupRelatedEdges(groupNodes);
                
                println("\n=== Enhanced Group " + group + " ===");
                
                // Print nodes
                sortNodesByID(groupNodes);
                print("Nodes (" + groupNodes.size() + "): [");
                for (int i = 0; i < groupNodes.size(); i++) {
                    Node node = groupNodes.get(i);
                    String nodeType = node.getType().equals("intersection") ? "I" : "N";
                    print(nodeType + node.getId());
                    if (i < groupNodes.size() - 1) print(", ");
                }
                println("]");
                
                // Print edges with detailed information
                println("Related Edges (" + groupEdges.size() + "):");
                for (int i = 0; i < groupEdges.size(); i++) {
                    Edge edge = groupEdges.get(i);
                    Node startNode = edge.getStartNode();
                    Node endNode = edge.getEndNode();
                    
                    String startType = startNode.getType().equals("intersection") ? "I" : "N";
                    String endType = endNode.getType().equals("intersection") ? "I" : "N";
                    
                    boolean startInGroup = groupNodes.contains(startNode);
                    boolean endInGroup = groupNodes.contains(endNode);
                    
                    String edgeType;
                    if (startInGroup && endInGroup) {
                        edgeType = "Internal";
                    } else {
                        edgeType = "Boundary";
                    }
                    
                    println("  Edge " + i + ": " + startType + startNode.getId() + " ↔ " + 
                        endType + endNode.getId() + " (" + edgeType + ")");
                }
                
                // Statistics
                int internalEdges = 0, boundaryEdges = 0;
                for (Edge edge : groupEdges) {
                    boolean startInGroup = groupNodes.contains(edge.getStartNode());
                    boolean endInGroup = groupNodes.contains(edge.getEndNode());
                    if (startInGroup && endInGroup) {
                        internalEdges++;
                    } else {
                        boundaryEdges++;
                    }
                }
                
                println("Edge Statistics: " + internalEdges + " internal, " + boundaryEdges + " boundary");
            }
        }
    }

    // Verify enhanced symmetry structure
    void verifyEnhancedSymmetryStructure() {
        println("\n--- Enhanced Symmetry Structure Verification ---");
        
        // Check for overlapping boundary nodes
        ArrayList<Node> allBoundaryNodes = new ArrayList<Node>();
        
        for (int group = 0; group < 5; group++) {
            if (symmetryGroups.containsKey(group)) {
                ArrayList<Node> groupNodes = symmetryGroups.get(group);
                
                // Find which nodes are boundary nodes for this group
                for (Node node : groupNodes) {
                    // Check if this node connects to other groups
                    boolean isBoundary = false;
                    for (Edge edge : edges) {
                        if (edge.isValid()) {
                            Node otherNode = null;
                            if (edge.getStartNode() == node) {
                                otherNode = edge.getEndNode();
                            } else if (edge.getEndNode() == node) {
                                otherNode = edge.getStartNode();
                            }
                            
                            if (otherNode != null && !groupNodes.contains(otherNode)) {
                                isBoundary = true;
                                break;
                            }
                        }
                    }
                    
                    if (isBoundary && !allBoundaryNodes.contains(node)) {
                        allBoundaryNodes.add(node);
                    }
                }
            }
        }
        
        println("Total boundary nodes across all groups: " + allBoundaryNodes.size());
        
        // Check group connectivity
        for (int group = 0; group < 5; group++) {
            if (symmetryGroups.containsKey(group)) {
                ArrayList<Node> groupNodes = symmetryGroups.get(group);
                ArrayList<Edge> groupEdges = getGroupRelatedEdges(groupNodes);
                
                int connectionsToOtherGroups = 0;
                for (Edge edge : groupEdges) {
                    boolean startInGroup = groupNodes.contains(edge.getStartNode());
                    boolean endInGroup = groupNodes.contains(edge.getEndNode());
                    if (!(startInGroup && endInGroup)) {
                        connectionsToOtherGroups++;
                    }
                }
                
                println("Group " + group + " has " + connectionsToOtherGroups + " boundary connections");
            }
        }
    }

    // Helper method to get node ID list as string
    String getNodeIdList(ArrayList<Node> nodeList) {
        if (nodeList.isEmpty()) return "[]";
        
        sortNodesByID(nodeList);
        String result = "[";
        for (int i = 0; i < nodeList.size(); i++) {
            Node node = nodeList.get(i);
            String nodeType = node.getType().equals("intersection") ? "I" : "N";
            result += nodeType + node.getId();
            if (i < nodeList.size() - 1) result += ", ";
        }
        result += "]";
        return result;
    }

    // Verify that symmetry groups follow 72-degree intervals
    void verifySymmetryIntervals(ArrayList<Float> sortedAngles) {
        println("\n--- 72-Degree Interval Verification ---");
        
        if (sortedAngles.size() < 20) {
            println("Not enough angle groups for proper verification");
            return;
        }
        
        // Check intervals between symmetry group centers
        for (int group = 0; group < 5; group++) {
            int startIndex = group * 4;
            int nextGroupStartIndex = ((group + 1) % 5) * 4;
            
            if (startIndex < sortedAngles.size()) {
                // Calculate center of current group
                float groupCenter = calculateGroupCenterAngle(group, sortedAngles);
                
                // Calculate center of next group
                float nextGroupCenter;
                if (group == 4) { // Last group, wrap to first
                    nextGroupCenter = calculateGroupCenterAngle(0, sortedAngles) + 360;
                } else {
                    nextGroupCenter = calculateGroupCenterAngle(group + 1, sortedAngles);
                }
                
                float interval = nextGroupCenter - groupCenter;
                float deviation = abs(interval - 72.0);
                
                println("Group " + group + " → Group " + ((group + 1) % 5) + 
                    ": " + nf(interval, 1, 1) + "° (deviation: " + nf(deviation, 1, 1) + "°)");
            }
        }
    }

    // Calculate center angle of a symmetry group
    float calculateGroupCenterAngle(int group, ArrayList<Float> sortedAngles) {
        int startIndex = group * 4;
        int endIndex = min(startIndex + 3, sortedAngles.size() - 1);
        
        if (startIndex >= sortedAngles.size()) return 0;
        
        float sum = 0;
        int count = 0;
        
        for (int i = startIndex; i <= endIndex && i < sortedAngles.size(); i++) {
            sum += sortedAngles.get(i);
            count++;
        }
        
        return count > 0 ? sum / count : 0;
    }
    
    // Output structured results in array format
    void outputStructuredResults() {
        println("\n--- Enhanced Structured Data Output (copy to code) ---");
        
        // Output radius groups (保持不变)
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
        
        // Output angle groups (保持不变)
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
        
        // Output enhanced symmetry groups (包含边界节点)
        println("\n// Enhanced Five-fold symmetry group data (including boundary nodes and edges)");
        println("enhancedSymmetryGroups = {");
        for (int group = 0; group < 5; group++) {
            if (symmetryGroups.containsKey(group)) {
                ArrayList<Node> groupNodes = symmetryGroups.get(group);
                ArrayList<Edge> groupEdges = getGroupRelatedEdges(groupNodes);
                
                println("  group" + group + ": {");
                
                // Nodes
                print("    nodes: [");
                sortNodesByID(groupNodes);
                for (int j = 0; j < groupNodes.size(); j++) {
                    Node node = groupNodes.get(j);
                    String nodeType = node.getType().equals("intersection") ? "I" : "N";
                    print(nodeType + node.getId());
                    if (j < groupNodes.size() - 1) print(", ");
                }
                println("],");
                
                // Edges
                print("    edges: [");
                for (int j = 0; j < groupEdges.size(); j++) {
                    Edge edge = groupEdges.get(j);
                    Node startNode = edge.getStartNode();
                    Node endNode = edge.getEndNode();
                    
                    String startType = startNode.getType().equals("intersection") ? "I" : "N";
                    String endType = endNode.getType().equals("intersection") ? "I" : "N";
                    
                    print("\"" + startType + startNode.getId() + "-" + endType + endNode.getId() + "\"");
                    if (j < groupEdges.size() - 1) print(", ");
                }
                println("]");
                
                print("  }");
            } else {
                print("  group" + group + ": { nodes: [], edges: [] }");
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
        
        // Analyze radius distribution
        println("\nRadius distribution:");
        ArrayList<Float> sortedRadii = new ArrayList<Float>(radiusGroups.keySet());
        Collections.sort(sortedRadii);
        
        for (Float radius : sortedRadii) {
            ArrayList<Node> groupNodes = radiusGroups.get(radius);
            int regular = 0, intersection = 0;
            
            for (Node node : groupNodes) {
                if (node.getType().equals("intersection")) {
                    intersection++;
                } else {
                    regular++;
                }
            }
            
            println("Radius " + nf(radius, 1, 3) + ": " + groupNodes.size() + " nodes " +
                   "(regular:" + regular + ", intersection:" + intersection + ")");
        }
        
        // Analyze angle distribution summary
        println("\nAngle distribution:");
        ArrayList<Float> sortedAngles = new ArrayList<Float>(angleGroups.keySet());
        Collections.sort(sortedAngles);
        
        for (Float angle : sortedAngles) {
            ArrayList<Node> groupNodes = angleGroups.get(angle);
            int regular = 0, intersection = 0;
            
            for (Node node : groupNodes) {
                if (node.getType().equals("intersection")) {
                    intersection++;
                } else {
                    regular++;
                }
            }
            
            println("Angle " + nf(angle, 1, 1) + "°: " + groupNodes.size() + " nodes " +
                   "(regular:" + regular + ", intersection:" + intersection + ")");
        }
        
        // Verify Petersen graph structure
        verifyPetersenStructure(regularNodes, intersectionNodes);
    }
    
    // Verify expected Petersen graph structure
    void verifyPetersenStructure(int regular, int intersection) {
        println("\n--- Petersen Graph Structure Verification ---");
        
        boolean correctNodes = (regular == 20 && intersection == 20);
        boolean correctRadii = (radiusGroups.size() >= 2 && radiusGroups.size() <= 5);
        boolean correctSymmetry = (symmetryGroups.size() == 5);
        boolean correctAngles = (angleGroups.size() == 20);  // Expected exactly 20 angle groups
        
        println("Node count check: " + (correctNodes ? "✓" : "✗") + 
            " (expected: 20 regular + 20 intersection, actual: " + regular + "+" + intersection + ")");
        println("Radius grouping check: " + (correctRadii ? "✓" : "✗") + 
            " (expected: 2-5 groups, actual: " + radiusGroups.size() + " groups)");
        println("Angle grouping check: " + (correctAngles ? "✓" : "✗") + 
            " (expected: 20 angle groups, actual: " + angleGroups.size() + " groups)");
        println("Symmetry check: " + (correctSymmetry ? "✓" : "✗") + 
            " (expected: 5 groups, actual: " + symmetryGroups.size() + " groups)");
        
        // Additional check for symmetry group sizes
        if (correctSymmetry) {
            boolean evenDistribution = true;
            for (int group = 0; group < 5; group++) {
                if (symmetryGroups.containsKey(group)) {
                    int groupSize = symmetryGroups.get(group).size();
                    if (groupSize < 6 || groupSize > 10) {  // Each group should have ~8 nodes
                        evenDistribution = false;
                    }
                }
            }
            println("Symmetry distribution check: " + (evenDistribution ? "✓" : "✗") + 
                " (each group should have 6-10 nodes)");
        }
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
