class PolarAnalysis {
    ArrayList<Node> nodes;
    ArrayList<Edge> edges;
    
    // Analysis results
    HashMap<Float, ArrayList<Node>> radiusGroups;
    HashMap<Integer, ArrayList<Node>> symmetryGroups;
    
    PolarAnalysis(ArrayList<Node> nodes, ArrayList<Edge> edges) {
        this.nodes = nodes;
        this.edges = edges;
        this.radiusGroups = new HashMap<Float, ArrayList<Node>>();
        this.symmetryGroups = new HashMap<Integer, ArrayList<Node>>();
    }
    
    // Main analysis function
    void performAnalysis() {
        println("\n=== Polar Coordinate Static Data Analysis ===");
        
        // Group by radius
        groupByRadius();
        
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
    
    // Find existing radius group
    Float findRadiusGroup(float radius, float tolerance) {
        for (Float existing : radiusGroups.keySet()) {
            if (abs(existing - radius) <= tolerance) {
                return existing;
            }
        }
        return null;
    }
    
    // Group nodes by 72-degree symmetry
    void groupBySymmetry() {
        symmetryGroups.clear();
        
        for (Node node : nodes) {
            float angle = node.getNormalizedAngleDegrees();
            int group = (int)(angle / 72.0);
            if (group >= 5) group = 4; // Handle edge case at 360°
            
            if (!symmetryGroups.containsKey(group)) {
                symmetryGroups.put(group, new ArrayList<Node>());
            }
            symmetryGroups.get(group).add(node);
        }
    }
    
    // Output structured results in array format
    void outputStructuredResults() {
        println("\n--- Structured Data Output (copy to code) ---");
        
        // Output radius groups
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
                print(groupNodes.get(j).getId());
                if (j < groupNodes.size() - 1) print(", ");
            }
            print("]");
            if (i < sortedRadii.size() - 1) print(",");
            println();
        }
        println("};");
        
        // Output symmetry groups
        println("\n// Five-fold symmetry group data (72-degree intervals)");
        println("symmetryGroups = {");
        for (int group = 0; group < 5; group++) {
            if (symmetryGroups.containsKey(group)) {
                ArrayList<Node> groupNodes = symmetryGroups.get(group);
                print("  group" + group + ": [");
                sortNodesByID(groupNodes);
                for (int j = 0; j < groupNodes.size(); j++) {
                    print(groupNodes.get(j).getId());
                    if (j < groupNodes.size() - 1) print(", ");
                }
                print("]");
            } else {
                print("  group" + group + ": []");
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
        
        // Verify Petersen graph structure
        verifyPetersenStructure(regularNodes, intersectionNodes);
    }
    
    // Verify expected Petersen graph structure
    void verifyPetersenStructure(int regular, int intersection) {
        println("\n--- Petersen Graph Structure Verification ---");
        
        boolean correctNodes = (regular == 20 && intersection == 20);
        boolean correctRadii = (radiusGroups.size() >= 2 && radiusGroups.size() <= 5);
        boolean correctSymmetry = (symmetryGroups.size() == 5);
        
        println("Node count check: " + (correctNodes ? "✓" : "✗") + 
               " (expected: 20 regular + 20 intersection, actual: " + regular + "+" + intersection + ")");
        println("Radius grouping check: " + (correctRadii ? "✓" : "✗") + 
               " (expected: 2-5 groups, actual: " + radiusGroups.size() + " groups)");
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
    
    // Get radius groups for analysis
    HashMap<Float, ArrayList<Node>> getRadiusGroups() {
        return radiusGroups;
    }
    
    // Get symmetry groups for analysis
    HashMap<Integer, ArrayList<Node>> getSymmetryGroups() {
        return symmetryGroups;
    }
}