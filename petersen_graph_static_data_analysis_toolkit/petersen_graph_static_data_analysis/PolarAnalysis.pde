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
            float angle = node.getNormalizedAngleDegrees();
            Float groupKey = findAngleGroup(angle, tolerance);
            
            if (groupKey == null) {
                groupKey = angle;
                angleGroups.put(groupKey, new ArrayList<Node>());
            }
            angleGroups.get(groupKey).add(node);
        }
        
        // Output angle grouping results
        ArrayList<Float> sortedAngles = new ArrayList<Float>(angleGroups.keySet());
        Collections.sort(sortedAngles);
        
        println("Found " + angleGroups.size() + " angle groups (including all node types):");
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
        
        // Output angle groups
        println("\n// Angle group data (all nodes)");
        println("angleGroups = {");
        ArrayList<Float> sortedAngles = new ArrayList<Float>(angleGroups.keySet());
        Collections.sort(sortedAngles);
        
        for (int i = 0; i < sortedAngles.size(); i++) {
            Float angle = sortedAngles.get(i);
            ArrayList<Node> groupNodes = angleGroups.get(angle);
            
            print("  " + nf(angle, 1, 1) + "°: [");
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
        
        // Output symmetry groups
        println("\n// Five-fold symmetry group data (72-degree intervals)");
        println("symmetryGroups = {");
        for (int group = 0; group < 5; group++) {
            if (symmetryGroups.containsKey(group)) {
                ArrayList<Node> groupNodes = symmetryGroups.get(group);
                print("  group" + group + ": [");
                sortNodesByID(groupNodes);
                for (int j = 0; j < groupNodes.size(); j++) {
                    Node node = groupNodes.get(j);
                    String nodeType = node.getType().equals("intersection") ? "I" : "N";
                    print(nodeType + node.getId());
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
        boolean correctAngles = (angleGroups.size() >= 1);
        
        println("Node count check: " + (correctNodes ? "✓" : "✗") + 
               " (expected: 20 regular + 20 intersection, actual: " + regular + "+" + intersection + ")");
        println("Radius grouping check: " + (correctRadii ? "✓" : "✗") + 
               " (expected: 2-5 groups, actual: " + radiusGroups.size() + " groups)");
        println("Angle grouping check: " + (correctAngles ? "✓" : "✗") + 
               " (" + angleGroups.size() + " distinct angle groups found)");
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
    
    // Get angle groups for analysis
    HashMap<Float, ArrayList<Node>> getAngleGroups() {
        return angleGroups;
    }
    
    // Get symmetry groups for analysis
    HashMap<Integer, ArrayList<Node>> getSymmetryGroups() {
        return symmetryGroups;
    }
}