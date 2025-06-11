/**
 * Static Data Exporter
 * Saves static data as JSON files
 */
class StaticDataExporter {
    
    /**
     * Export to JSON file
     */
    void exportToJSON(StaticPetersenData staticData, String filename) {
        JSONObject json = new JSONObject();
        
        // Basic information
        json.setString("version", staticData.version);
        json.setString("created_time", staticData.createdTime);
        json.setJSONObject("metadata", staticData.metadata);
        
        // Data statistics
        JSONObject stats = new JSONObject();
        stats.setInt("total_nodes", staticData.nodesByIndex.size());
        stats.setInt("total_intersections", staticData.intersectionsByIndex.size());
        stats.setInt("total_original_edges", staticData.originalEdgesByIndex.size());
        stats.setInt("total_segments", staticData.segmentsByIndex.size());
        json.setJSONObject("statistics", stats);
        
        // Node data
        JSONObject nodesData = new JSONObject();
        nodesData.setJSONArray("by_index", exportNodesArray(staticData.nodesByIndex));
        nodesData.setJSONArray("by_polar", exportNodesArray(staticData.nodesByPolar));
        json.setJSONObject("nodes", nodesData);
        
        // Intersection data
        JSONObject intersectionsData = new JSONObject();
        intersectionsData.setJSONArray("by_index", exportIntersectionsArray(staticData.intersectionsByIndex));
        intersectionsData.setJSONArray("by_polar", exportIntersectionsArray(staticData.intersectionsByPolar));
        json.setJSONObject("intersections", intersectionsData);
        
        // Original edge data
        JSONObject edgesData = new JSONObject();
        edgesData.setJSONArray("by_index", exportEdgesArray(staticData.originalEdgesByIndex));
        edgesData.setJSONArray("by_polar", exportEdgesArray(staticData.originalEdgesByPolar));
        json.setJSONObject("original_edges", edgesData);
        
        // Segment data
        JSONObject segmentsData = new JSONObject();
        segmentsData.setJSONArray("by_index", exportSegmentsArray(staticData.segmentsByIndex));
        segmentsData.setJSONArray("by_polar", exportSegmentsArray(staticData.segmentsByPolar));
        json.setJSONObject("segments", segmentsData);
        
        // Layer group data
        json.setJSONObject("layer_groups", exportLayerGroups(staticData.layerGroups));
        
        // Save file
        saveJSONObject(json, "static_data_exports/" + filename);
        println("Static data exported to: " + filename);
        println("Total elements: " + 
                staticData.nodesByIndex.size() + " nodes, " +
                staticData.intersectionsByIndex.size() + " intersections, " +
                staticData.segmentsByIndex.size() + " segments");
    }
    
    private JSONArray exportNodesArray(ArrayList<StaticNode> nodes) {
        JSONArray array = new JSONArray();
        for (StaticNode node : nodes) {
            JSONObject nodeJson = new JSONObject();
            nodeJson.setInt("node_id", node.nodeId);
            nodeJson.setInt("chain_id", node.chainId);
            nodeJson.setJSONObject("polar", exportPolarCoordinate(node.polar));
            nodeJson.setString("layer", node.layer);
            nodeJson.setString("display_radius", formatFloatString(node.displayRadius));
            array.setJSONObject(array.size(), nodeJson);
        }
        return array;
    }
    
    private JSONArray exportIntersectionsArray(ArrayList<StaticIntersection> intersections) {
        JSONArray array = new JSONArray();
        for (StaticIntersection intersection : intersections) {
            JSONObject intJson = new JSONObject();
            intJson.setInt("intersection_id", intersection.intersectionId);
            intJson.setJSONObject("polar", exportPolarCoordinate(intersection.polar));
            intJson.setInt("edge1_id", intersection.edge1Id);
            intJson.setInt("edge2_id", intersection.edge2Id);
            intJson.setString("display_radius", formatFloatString(intersection.displayRadius));
            array.setJSONObject(array.size(), intJson);
        }
        return array;
    }
    
    private JSONArray exportEdgesArray(ArrayList<StaticEdge> edges) {
        JSONArray array = new JSONArray();
        for (StaticEdge edge : edges) {
            JSONObject edgeJson = new JSONObject();
            edgeJson.setInt("edge_id", edge.edgeId);
            edgeJson.setInt("edge_type", edge.edgeType);
            edgeJson.setJSONObject("start_polar", exportPolarCoordinate(edge.startPolar));
            edgeJson.setJSONObject("end_polar", exportPolarCoordinate(edge.endPolar));
            edgeJson.setString("stroke_width", formatFloatString(edge.strokeWidth));
            edgeJson.setString("description", edge.description);
            
            JSONArray intersectionIds = new JSONArray();
            for (int i = 0; i < edge.intersectionIds.size(); i++) {
                intersectionIds.setInt(i, edge.intersectionIds.get(i));
            }
            edgeJson.setJSONArray("intersection_ids", intersectionIds);
            
            array.setJSONObject(array.size(), edgeJson);
        }
        return array;
    }
    
    private JSONArray exportSegmentsArray(ArrayList<StaticSegment> segments) {
        JSONArray array = new JSONArray();
        for (StaticSegment segment : segments) {
            JSONObject segJson = new JSONObject();
            segJson.setInt("segment_id", segment.segmentId);
            segJson.setInt("parent_edge_id", segment.parentEdgeId);
            segJson.setJSONObject("start_polar", exportPolarCoordinate(segment.startPolar));
            segJson.setJSONObject("end_polar", exportPolarCoordinate(segment.endPolar));
            segJson.setString("stroke_width", formatFloatString(segment.strokeWidth));
            segJson.setBoolean("is_intersected", segment.isIntersected);
            
            JSONArray endpointIds = new JSONArray();
            for (int i = 0; i < segment.endpointIntersectionIds.size(); i++) {
                endpointIds.setInt(i, segment.endpointIntersectionIds.get(i));
            }
            segJson.setJSONArray("endpoint_intersection_ids", endpointIds);
            
            array.setJSONObject(array.size(), segJson);
        }
        return array;
    }
    
    private JSONObject exportLayerGroups(LayerGroupData groups) {
        JSONObject groupsJson = new JSONObject();
        
        groupsJson.setJSONArray("middle_nodes", exportNodesArray(groups.middleNodes));
        groupsJson.setJSONArray("inner_nodes", exportNodesArray(groups.innerNodes));
        groupsJson.setJSONArray("outer_nodes", exportNodesArray(groups.outerNodes));
        
        groupsJson.setJSONArray("middle_to_inner_segments", exportSegmentsArray(groups.middleToInnerSegments));
        groupsJson.setJSONArray("middle_to_outer_segments", exportSegmentsArray(groups.middleToOuterSegments));
        groupsJson.setJSONArray("inner_circle_segments", exportSegmentsArray(groups.innerCircleSegments));
        groupsJson.setJSONArray("outer_circle_segments", exportSegmentsArray(groups.outerCircleSegments));
        groupsJson.setJSONArray("intersection_segments", exportSegmentsArray(groups.intersectionSegments));
        
        return groupsJson;
    }
    
    private JSONObject exportPolarCoordinate(PolarCoordinate polar) {
        JSONObject polarJson = new JSONObject();
        polarJson.setString("radius", formatFloatString(polar.radius));
        polarJson.setString("angle_radians", formatFloatString(polar.angle));
        polarJson.setString("angle_degrees", formatFloatString(polar.getAngleDegrees()));
        return polarJson;
    }

    private String formatFloatString(float value) {
        return String.format("%.2f", value);
    }
}