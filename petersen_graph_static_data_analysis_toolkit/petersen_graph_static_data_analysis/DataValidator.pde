/**
 * Data Validation and Safety Wrapper
 * Validates JSON data integrity before processing
 */
class DataValidator {
    PetersenDataReader dataReader;
    DataStructureInspector inspector;
    boolean isDataValid = false;
    String validationError = "";
    
    DataValidator(PetersenDataReader reader) {
        this.dataReader = reader;
        this.inspector = new DataStructureInspector(reader);
    }
    
    /**
     * Perform comprehensive data validation
     */
    boolean validateData() {
        println("\n=== Data Validation Starting ===");
        
        try {
            // First inspect actual data structure
            inspector.inspectDataStructures();
            
            // Check basic structure
            if (!validateBasicStructure()) return false;
            
            // Check data arrays
            if (!validateDataArrays()) return false;
            
            // Sample data validation with flexible field checking
            if (!validateSampleDataFlexible()) return false;
            
            // Check data consistency
            if (!validateDataConsistency()) return false;
            
            isDataValid = true;
            println("✅ Data validation passed");
            return true;
            
        } catch (Exception e) {
            validationError = "Exception occurred during validation: " + e.getMessage();
            println("❌ " + validationError);
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Validate basic JSON structure
     */
    boolean validateBasicStructure() {
        try {
            if (dataReader.data == null) {
                validationError = "JSON data is null";
                println("❌ " + validationError);
                return false;
            }
            
            // Check required top-level fields
            String[] requiredFields = {"nodes", "intersections", "segments", "statistics"};
            for (String field : requiredFields) {
                if (!dataReader.data.hasKey(field)) {
                    validationError = "Missing required field: " + field;
                    println("❌ " + validationError);
                    return false;
                }
            }
            
            println("✅ Basic structure validation passed");
            return true;
            
        } catch (Exception e) {
            validationError = "Basic structure validation failed: " + e.getMessage();
            println("❌ " + validationError);
            return false;
        }
    }
    
    /**
     * Validate data arrays are not empty
     */
    boolean validateDataArrays() {
        try {
            ArrayList<JSONObject> nodes = dataReader.getAllNodes();
            ArrayList<JSONObject> intersections = dataReader.getAllIntersections();
            ArrayList<JSONObject> segments = dataReader.getAllSegments();
            
            if (nodes.size() == 0) {
                validationError = "Node data is empty";
                println("❌ " + validationError);
                return false;
            }
            
            if (intersections.size() == 0) {
                validationError = "Intersection data is empty";
                println("❌ " + validationError);
                return false;
            }
            
            if (segments.size() == 0) {
                validationError = "Segment data is empty";
                println("❌ " + validationError);
                return false;
            }
            
            println("✅ Data array validation passed");
            println("  - Node count: " + nodes.size());
            println("  - Intersection count: " + intersections.size());
            println("  - Segment count: " + segments.size());
            
            return true;
            
        } catch (Exception e) {
            validationError = "Data array validation failed: " + e.getMessage();
            println("❌ " + validationError);
            return false;
        }
    }
    
    /**
     * Flexible sample data validation that adapts to actual structure
     */
    boolean validateSampleDataFlexible() {
        try {
            // Sample node validation
            if (!validateSampleNodeFlexible()) return false;
            
            // Sample intersection validation
            if (!validateSampleIntersectionFlexible()) return false;
            
            // Sample segment validation with flexible field names
            if (!validateSampleSegmentFlexible()) return false;
            
            println("✅ Sample data validation passed");
            return true;
            
        } catch (Exception e) {
            validationError = "Sample data validation failed: " + e.getMessage();
            println("❌ " + validationError);
            return false;
        }
    }
    
    /**
     * Flexible node validation
     */
    boolean validateSampleNodeFlexible() {
        ArrayList<JSONObject> nodes = dataReader.getAllNodes();
        if (nodes.size() == 0) return false;
        
        JSONObject sampleNode = nodes.get(0);
        
        // Check for node ID field (could be node_id or id)
        if (!sampleNode.hasKey("node_id") && !sampleNode.hasKey("id")) {
            validationError = "Node missing ID field (node_id or id)";
            println("❌ " + validationError);
            return false;
        }
        
        if (!sampleNode.hasKey("polar")) {
            validationError = "Node missing polar field";
            println("❌ " + validationError);
            return false;
        }
        
        // Validate polar structure
        JSONObject polar = sampleNode.getJSONObject("polar");
        String[] polarFields = {"radius", "angle_radians", "angle_degrees"};
        
        for (String field : polarFields) {
            if (!polar.hasKey(field)) {
                validationError = "Node polar missing " + field + " field";
                println("❌ " + validationError);
                return false;
            }
            
            // Test string to float conversion
            try {
                Float.parseFloat(polar.getString(field));
            } catch (Exception e) {
                validationError = "Node polar." + field + " is not a valid number string: " + polar.getString(field);
                println("❌ " + validationError);
                return false;
            }
        }
        
        println("✅ Node sample validation passed");
        return true;
    }
    
    /**
     * Flexible intersection validation
     */
    boolean validateSampleIntersectionFlexible() {
        ArrayList<JSONObject> intersections = dataReader.getAllIntersections();
        if (intersections.size() == 0) return false;
        
        JSONObject sampleIntersection = intersections.get(0);
        
        if (!sampleIntersection.hasKey("intersection_id") && !sampleIntersection.hasKey("id")) {
            validationError = "Intersection missing ID field (intersection_id or id)";
            println("❌ " + validationError);
            return false;
        }
        
        if (!sampleIntersection.hasKey("polar")) {
            validationError = "Intersection missing polar field";
            println("❌ " + validationError);
            return false;
        }
        
        println("✅ Intersection sample validation passed");
        return true;
    }
    
    /**
     * Flexible segment validation that checks for various possible field names
     */
    boolean validateSampleSegmentFlexible() {
        ArrayList<JSONObject> segments = dataReader.getAllSegments();
        if (segments.size() == 0) return false;
        
        JSONObject sampleSegment = segments.get(0);
        
        // Print available fields for debugging
        println("Actual fields in segment sample:");
        for (Object key : sampleSegment.keys()) {
            println("  - " + key);
        }
        
        // Check for segment ID (could be segment_id, id, etc.)
        if (!hasAnyKey(sampleSegment, new String[]{"segment_id", "id"})) {
            validationError = "Segment missing ID field";
            println("❌ " + validationError);
            return false;
        }
        
        // Check for node reference fields (various possible names)
        String[] possibleStartFields = {"start_node_id", "from_node", "source", "start_id"};
        String[] possibleEndFields = {"end_node_id", "to_node", "target", "end_id"};
        
        if (!hasAnyKey(sampleSegment, possibleStartFields)) {
            validationError = "Segment missing start node field (tried: " + java.util.Arrays.toString(possibleStartFields) + ")";
            println("❌ " + validationError);
            return false;
        }
        
        if (!hasAnyKey(sampleSegment, possibleEndFields)) {
            validationError = "Segment missing end node field (tried: " + java.util.Arrays.toString(possibleEndFields) + ")";
            println("❌ " + validationError);
            return false;
        }
        
        println("✅ Segment sample validation passed");
        return true;
    }
    
    /**
     * Helper method to check if object has any of the given keys
     */
    boolean hasAnyKey(JSONObject obj, String[] keys) {
        for (String key : keys) {
            if (obj.hasKey(key)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Validate data consistency
     */
    boolean validateDataConsistency() {
        try {
            JSONObject stats = dataReader.data.getJSONObject("statistics");
            
            int expectedNodes = stats.getInt("total_nodes");
            int expectedIntersections = stats.getInt("total_intersections");
            int expectedSegments = stats.getInt("total_segments");
            
            int actualNodes = dataReader.getAllNodes().size();
            int actualIntersections = dataReader.getAllIntersections().size();
            int actualSegments = dataReader.getAllSegments().size();
            
            if (actualNodes != expectedNodes) {
                validationError = "Node count mismatch: expected " + expectedNodes + ", actual " + actualNodes;
                println("❌ " + validationError);
                return false;
            }
            
            if (actualIntersections != expectedIntersections) {
                validationError = "Intersection count mismatch: expected " + expectedIntersections + ", actual " + actualIntersections;
                println("❌ " + validationError);
                return false;
            }
            
            if (actualSegments != expectedSegments) {
                validationError = "Segment count mismatch: expected " + expectedSegments + ", actual " + actualSegments;
                println("❌ " + validationError);
                return false;
            }
            
            println("✅ Data consistency validation passed");
            return true;
            
        } catch (Exception e) {
            validationError = "Data consistency validation failed: " + e.getMessage();
            println("❌ " + validationError);
            return false;
        }
    }
    
    // Rest of the methods remain the same...
    boolean isValid() { return isDataValid; }
    String getError() { return validationError; }
    
    void printValidationReport() {
        println("\n=== Data Validation Report ===");
        
        if (isDataValid) {
            println("✅ Data validation successful");
            println("Data can be safely used for analysis");
        } else {
            println("❌ Data validation failed");
            println("Error: " + validationError);
            println("Please check the integrity of the JSON data file");
        }
        
        println("===============================");
    }
}