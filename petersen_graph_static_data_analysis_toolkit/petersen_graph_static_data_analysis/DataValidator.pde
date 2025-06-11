/**
 * Data Validation and Safety Wrapper
 * Validates JSON data integrity before processing
 */
class DataValidator {
    PetersenDataReader dataReader;
    boolean isDataValid = false;
    String validationError = "";
    
    DataValidator(PetersenDataReader reader) {
        this.dataReader = reader;
    }
    
    /**
     * Perform comprehensive data validation
     */
    boolean validateData() {
        println("\n=== Data Validation Started ===");
        
        try {
            // Check basic structure
            if (!validateBasicStructure()) return false;
            
            // Check data arrays
            if (!validateDataArrays()) return false;
            
            // Sample data validation
            if (!validateSampleData()) return false;
            
            // Check data consistency
            if (!validateDataConsistency()) return false;
            
            isDataValid = true;
            println("✅ Data validation passed");
            return true;
            
        } catch (Exception e) {
            validationError = "Exception occurred during validation: " + e.getMessage();
            println("❌ " + validationError);
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
                validationError = "Nodes data is empty";
                println("❌ " + validationError);
                return false;
            }
            
            if (intersections.size() == 0) {
                validationError = "Intersections data is empty";
                println("❌ " + validationError);
                return false;
            }
            
            if (segments.size() == 0) {
                validationError = "Segments data is empty";
                println("❌ " + validationError);
                return false;
            }
            
            println("✅ Data arrays validation passed");
            println("  - Node count: " + nodes.size());
            println("  - Intersection count: " + intersections.size());
            println("  - Segment count: " + segments.size());
            
            return true;
            
        } catch (Exception e) {
            validationError = "Data arrays validation failed: " + e.getMessage();
            println("❌ " + validationError);
            return false;
        }
    }
    
    /**
     * Validate sample data structures
     */
    boolean validateSampleData() {
        try {
            // Sample node validation
            if (!validateSampleNode()) return false;
            
            // Sample intersection validation
            if (!validateSampleIntersection()) return false;
            
            // Sample segment validation
            if (!validateSampleSegment()) return false;
            
            println("✅ Sample data validation passed");
            return true;
            
        } catch (Exception e) {
            validationError = "Sample data validation failed: " + e.getMessage();
            println("❌ " + validationError);
            return false;
        }
    }
    
    /**
     * Validate sample node structure
     */
    boolean validateSampleNode() {
        ArrayList<JSONObject> nodes = dataReader.getAllNodes();
        if (nodes.size() == 0) return false;
        
        JSONObject sampleNode = nodes.get(0);
        
        // Check required fields
        if (!sampleNode.hasKey("node_id")) {
            validationError = "Node missing node_id field";
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
                validationError = "Node polar." + field + " is not a valid number string";
                println("❌ " + validationError);
                return false;
            }
        }
        
        println("✅ Node sample validation passed");
        return true;
    }
    
    /**
     * Validate sample intersection structure
     */
    boolean validateSampleIntersection() {
        ArrayList<JSONObject> intersections = dataReader.getAllIntersections();
        if (intersections.size() == 0) return false;
        
        JSONObject sampleIntersection = intersections.get(0);
        
        if (!sampleIntersection.hasKey("intersection_id")) {
            validationError = "Intersection missing intersection_id field";
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
     * Validate sample segment structure
     */
    boolean validateSampleSegment() {
        ArrayList<JSONObject> segments = dataReader.getAllSegments();
        if (segments.size() == 0) return false;
        
        JSONObject sampleSegment = segments.get(0);
        
        String[] requiredFields = {"segment_id", "start_node_id", "end_node_id", "parent_edge_id"};
        
        for (String field : requiredFields) {
            if (!sampleSegment.hasKey(field)) {
                validationError = "Segment missing " + field + " field";
                println("❌ " + validationError);
                return false;
            }
        }
        
        println("✅ Segment sample validation passed");
        return true;
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
    
    /**
     * Get validation status
     */
    boolean isValid() {
        return isDataValid;
    }
    
    /**
     * Get validation error message
     */
    String getError() {
        return validationError;
    }
    
    /**
     * Print detailed validation report
     */
    void printValidationReport() {
        println("\n=== Data Validation Report ===");
        
        if (isDataValid) {
            println("✅ Data validation successful");
            println("Data is safe for analysis");
        } else {
            println("❌ Data validation failed");
            println("Error: " + validationError);
            println("Please check the integrity of the JSON data file");
        }
        
        println("===============================");
    }
}