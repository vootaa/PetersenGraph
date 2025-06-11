/**
 * Data Structure Inspector
 * Inspects actual JSON structure to understand the data format
 */
class DataStructureInspector {
    PetersenDataReader dataReader;
    
    DataStructureInspector(PetersenDataReader reader) {
        this.dataReader = reader;
    }
    
    /**
     * Inspect and print actual data structures
     */
    void inspectDataStructures() {
        println("\n=== Data Structure Inspection ===");
        
        inspectNodeStructure();
        inspectIntersectionStructure();
        inspectSegmentStructure();
        inspectEdgeStructure();
    }
    
    void inspectNodeStructure() {
        println("\n--- Node Structure Inspection ---");
        ArrayList<JSONObject> nodes = dataReader.getAllNodes();
        
        if (nodes.size() > 0) {
            JSONObject sample = nodes.get(0);
            println("Node sample fields:");
            for (Object key : sample.keys()) {
                String keyStr = (String) key;
                println("  - " + keyStr + ": " + getValueType(sample, keyStr));
            }
            
            // Check polar structure if exists
            if (sample.hasKey("polar")) {
                JSONObject polar = sample.getJSONObject("polar");
                println("  polar sub-fields:");
                for (Object key : polar.keys()) {
                    String keyStr = (String) key;
                    println("    - " + keyStr + ": " + getValueType(polar, keyStr));
                }
            }
        } else {
            println("❌ No node data");
        }
    }
    
    void inspectIntersectionStructure() {
        println("\n--- Intersection Structure Inspection ---");
        ArrayList<JSONObject> intersections = dataReader.getAllIntersections();
        
        if (intersections.size() > 0) {
            JSONObject sample = intersections.get(0);
            println("Intersection sample fields:");
            for (Object key : sample.keys()) {
                String keyStr = (String) key;
                println("  - " + keyStr + ": " + getValueType(sample, keyStr));
            }
        } else {
            println("❌ No intersection data");
        }
    }
    
    void inspectSegmentStructure() {
        println("\n--- Segment Structure Inspection ---");
        ArrayList<JSONObject> segments = dataReader.getAllSegments();
        
        if (segments.size() > 0) {
            JSONObject sample = segments.get(0);
            println("Segment sample fields:");
            for (Object key : sample.keys()) {
                String keyStr = (String) key;
                println("  - " + keyStr + ": " + getValueType(sample, keyStr));
            }
            
            // Print first few segments for analysis
            /*
            println("\nFirst 3 segments complete data:");
            for (int i = 0; i < min(3, segments.size()); i++) {
                println("Segment " + i + ": " + segments.get(i).toString());
            }*/
        } else {
            println("❌ No segment data");
        }
    }
    
    void inspectEdgeStructure() {
        println("\n--- Edge Structure Inspection ---");
        ArrayList<JSONObject> edges = dataReader.getAllEdges();
        
        if (edges.size() > 0) {
            JSONObject sample = edges.get(0);
            println("Edge sample fields:");
            for (Object key : sample.keys()) {
                String keyStr = (String) key;
                println("  - " + keyStr + ": " + getValueType(sample, keyStr));
            }
        } else {
            println("❌ No edge data");
        }
    }
    
    String getValueType(JSONObject obj, String key) {
        try {
            Object value = obj.get(key);
            if (value instanceof String) {
                return "String (\"" + value + "\")";
            } else if (value instanceof Integer) {
                return "Integer (" + value + ")";
            } else if (value instanceof Float) {
                return "Float (" + value + ")";
            } else if (value instanceof JSONObject) {
                return "JSONObject";
            } else if (value instanceof JSONArray) {
                return "JSONArray (length: " + ((JSONArray)value).size() + ")";
            } else {
                return value.getClass().getSimpleName() + " (" + value + ")";
            }
        } catch (Exception e) {
            return "Error: " + e.getMessage();
        }
    }
}