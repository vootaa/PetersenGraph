/**
 * Static Data Generator
 * Converts PetersenGraph to static polar coordinate data
 */
class StaticDataGenerator {
    PolarCoordinateConverter converter;
    
    StaticDataGenerator() {
        converter = new PolarCoordinateConverter();
    }
    
    /**
     * Generate complete static data
     */
    StaticPetersenData generateStaticData(PetersenGraph graph, JSONObject config) {
        StaticPetersenData staticData = new StaticPetersenData();
        staticData.metadata = config;
        
        // 1. Generate node data
        generateNodeData(graph, staticData);
        
        // 2. Generate intersection data
        generateIntersectionData(graph, staticData);
        
        // 3. Generate original edge data
        generateEdgeData(graph, staticData);
        
        // 4. Generate segment data
        generateSegmentData(graph, staticData);
        
        // 5. Generate layer group data
        generateLayerGroupData(staticData);
        
        // 6. Execute sorting
        sortAllData(staticData);
        
        return staticData;
    }
    
    /**
     * Generate node data
     */
    private void generateNodeData(PetersenGraph graph, StaticPetersenData staticData) {
        for (int i = 0; i < graph.nodes.size(); i++) {
            Node node = graph.nodes.get(i);
            PolarCoordinate polar = converter.cartesianToPolar(node.x, node.y);
            String layer = converter.getLayerFromChainId(node.chainId);
            
            StaticNode staticNode = new StaticNode(i, node.chainId, polar, layer, 
                                                  getNodeDisplayRadius(staticData.metadata));
            
            staticData.nodesByIndex.add(staticNode);
            staticData.nodesByPolar.add(staticNode);
        }
    }
    
    /**
     * Generate intersection data
     */
    private void generateIntersectionData(PetersenGraph graph, StaticPetersenData staticData) {
        ArrayList<Intersection> intersections = graph.getIntersections();
        for (Intersection intersection : intersections) {
            PolarCoordinate polar = converter.cartesianToPolar(intersection.x, intersection.y);
            
            StaticIntersection staticIntersection = new StaticIntersection(
                intersection.intersectionId, polar,
                intersection.edge1Id, intersection.edge2Id,
                getIntersectionDisplayRadius(staticData.metadata)
            );
            
            staticData.intersectionsByIndex.add(staticIntersection);
            staticData.intersectionsByPolar.add(staticIntersection);
        }
    }
    
    /**
     * Generate original edge data
     */
    private void generateEdgeData(PetersenGraph graph, StaticPetersenData staticData) {
        for (Edge edge : graph.edges) {
            PolarCoordinate startPolar = converter.cartesianToPolar(edge.from.x, edge.from.y);
            PolarCoordinate endPolar = converter.cartesianToPolar(edge.to.x, edge.to.y);
            String description = getEdgeTypeDescription(edge.type);
            
            StaticEdge staticEdge = new StaticEdge(edge.edgeId, edge.type, startPolar, endPolar,
                                                  getEdgeStrokeWidth(staticData.metadata), description);
            
            // Find all intersections on this edge
            ArrayList<Intersection> intersections = graph.getIntersections();
            for (Intersection intersection : intersections) {
                if (intersection.edge1Id == edge.edgeId || intersection.edge2Id == edge.edgeId) {
                    staticEdge.intersectionIds.add(intersection.intersectionId);
                }
            }
            
            staticData.originalEdgesByIndex.add(staticEdge);
            staticData.originalEdgesByPolar.add(staticEdge);
        }
    }
    
    /**
     * Generate segment data
     */
    private void generateSegmentData(PetersenGraph graph, StaticPetersenData staticData) {
        int segmentId = 0;
        
        for (StaticEdge originalEdge : staticData.originalEdgesByIndex) {
            if (originalEdge.intersectionIds.size() == 0) {
                // Edge with no intersections, directly create as one segment
                StaticSegment segment = new StaticSegment(segmentId++, originalEdge.edgeId,
                                                         originalEdge.startPolar, originalEdge.endPolar,
                                                         originalEdge.strokeWidth);
                staticData.segmentsByIndex.add(segment);
                staticData.segmentsByPolar.add(segment);
            } else {
                // Edge with intersections, needs to be split
                ArrayList<PolarCoordinate> segmentPoints = new ArrayList<PolarCoordinate>();
                segmentPoints.add(originalEdge.startPolar);
                
                // Add intersections and sort by angle
                for (int intersectionId : originalEdge.intersectionIds) {
                    StaticIntersection intersection = findIntersectionById(staticData, intersectionId);
                    if (intersection != null) {
                        segmentPoints.add(intersection.polar);
                    }
                }
                segmentPoints.add(originalEdge.endPolar);
                
                // Sort intersections by position along edge
                sortPointsAlongEdge(segmentPoints, originalEdge);
                
                // Create split segments
                for (int i = 0; i < segmentPoints.size() - 1; i++) {
                    StaticSegment segment = new StaticSegment(segmentId++, originalEdge.edgeId,
                                                             segmentPoints.get(i), segmentPoints.get(i + 1),
                                                             originalEdge.strokeWidth);
                    segment.isIntersected = true;
                    
                    // Check if endpoints are intersections
                    checkAndAddIntersectionEndpoints(segment, staticData);
                    
                    staticData.segmentsByIndex.add(segment);
                    staticData.segmentsByPolar.add(segment);
                }
            }
        }
    }
    
    /**
     * Generate layer group data
     */
    private void generateLayerGroupData(StaticPetersenData staticData) {
        // Group nodes by layer
        for (StaticNode node : staticData.nodesByIndex) {
            switch (node.layer) {
                case "Middle":
                    staticData.layerGroups.middleNodes.add(node);
                    break;
                case "Inner":
                    staticData.layerGroups.innerNodes.add(node);
                    break;
                case "Outer":
                    staticData.layerGroups.outerNodes.add(node);
                    break;
            }
        }
        
        // Group segments by type
        for (StaticSegment segment : staticData.segmentsByIndex) {
            StaticEdge parentEdge = findEdgeById(staticData, segment.parentEdgeId);
            if (parentEdge != null) {
                switch (parentEdge.edgeType) {
                    case 0: // Middle to Inner
                        staticData.layerGroups.middleToInnerSegments.add(segment);
                        break;
                    case 1: // Middle to Outer A
                    case 2: // Middle to Outer B
                        staticData.layerGroups.middleToOuterSegments.add(segment);
                        break;
                    case 3: // Inner Circle (Pentagram)
                        staticData.layerGroups.innerCircleSegments.add(segment);
                        break;
                    case 4: // Outer Circle (Loop)
                        staticData.layerGroups.outerCircleSegments.add(segment);
                        break;
                }
                
                if (segment.isIntersected) {
                    staticData.layerGroups.intersectionSegments.add(segment);
                }
            }
        }
    }
    
    /**
     * Sort all data
     */
    private void sortAllData(StaticPetersenData staticData) {
        // Sort by polar coordinates (angle first, radius second)
        java.util.Comparator<Object> polarComparator = (a, b) -> {
            PolarCoordinate polarA = getPolarFromObject(a);
            PolarCoordinate polarB = getPolarFromObject(b);
            
            int angleCompare = Float.compare(polarA.getAngleDegrees(), polarB.getAngleDegrees());
            if (angleCompare != 0) return angleCompare;
            return Float.compare(polarA.radius, polarB.radius);
        };
        
        // Sort nodes
        java.util.Collections.sort(staticData.nodesByPolar, polarComparator);
        
        // Sort intersections
        java.util.Collections.sort(staticData.intersectionsByPolar, polarComparator);
        
        // Sort edges
        java.util.Collections.sort(staticData.originalEdgesByPolar, (a, b) -> {
            StaticEdge edgeA = (StaticEdge) a;
            StaticEdge edgeB = (StaticEdge) b;
            
            // Sort using edge midpoint
            float midAngleA = (edgeA.startPolar.getAngleDegrees() + edgeA.endPolar.getAngleDegrees()) / 2;
            float midAngleB = (edgeB.startPolar.getAngleDegrees() + edgeB.endPolar.getAngleDegrees()) / 2;
            float midRadiusA = (edgeA.startPolar.radius + edgeA.endPolar.radius) / 2;
            float midRadiusB = (edgeB.startPolar.radius + edgeB.endPolar.radius) / 2;
            
            int angleCompare = Float.compare(midAngleA, midAngleB);
            if (angleCompare != 0) return angleCompare;
            return Float.compare(midRadiusA, midRadiusB);
        });
        
        // Sort segments
        java.util.Collections.sort(staticData.segmentsByPolar, (a, b) -> {
            StaticSegment segA = (StaticSegment) a;
            StaticSegment segB = (StaticSegment) b;
            
            float midAngleA = (segA.startPolar.getAngleDegrees() + segA.endPolar.getAngleDegrees()) / 2;
            float midAngleB = (segB.startPolar.getAngleDegrees() + segB.endPolar.getAngleDegrees()) / 2;
            float midRadiusA = (segA.startPolar.radius + segA.endPolar.radius) / 2;
            float midRadiusB = (segB.startPolar.radius + segB.endPolar.radius) / 2;
            
            int angleCompare = Float.compare(midAngleA, midAngleB);
            if (angleCompare != 0) return angleCompare;
            return Float.compare(midRadiusA, midRadiusB);
        });
    }
    
    // Helper methods
    private PolarCoordinate getPolarFromObject(Object obj) {
        if (obj instanceof StaticNode) {
            return ((StaticNode) obj).polar;
        } else if (obj instanceof StaticIntersection) {
            return ((StaticIntersection) obj).polar;
        }
        return new PolarCoordinate(0, 0);
    }
    
    private StaticIntersection findIntersectionById(StaticPetersenData data, int id) {
        for (StaticIntersection intersection : data.intersectionsByIndex) {
            if (intersection.intersectionId == id) return intersection;
        }
        return null;
    }
    
    private StaticEdge findEdgeById(StaticPetersenData data, int id) {
        for (StaticEdge edge : data.originalEdgesByIndex) {
            if (edge.edgeId == id) return edge;
        }
        return null;
    }
    
    private void sortPointsAlongEdge(ArrayList<PolarCoordinate> points, StaticEdge edge) {
        // Sort by parametric position along edge
        PVector start = converter.polarToCartesian(edge.startPolar.radius, edge.startPolar.angle);
        PVector end = converter.polarToCartesian(edge.endPolar.radius, edge.endPolar.angle);
        
        java.util.Collections.sort(points, (a, b) -> {
            PVector pointA = converter.polarToCartesian(a.radius, a.angle);
            PVector pointB = converter.polarToCartesian(b.radius, b.angle);
            
            float tA = calculateParametricPosition(start, end, pointA);
            float tB = calculateParametricPosition(start, end, pointB);
            
            return Float.compare(tA, tB);
        });
    }
    
    private float calculateParametricPosition(PVector start, PVector end, PVector point) {
        PVector edge = PVector.sub(end, start);
        PVector toPoint = PVector.sub(point, start);
        return PVector.dot(toPoint, edge) / PVector.dot(edge, edge);
    }
    
    private void checkAndAddIntersectionEndpoints(StaticSegment segment, StaticPetersenData data) {
        for (StaticIntersection intersection : data.intersectionsByIndex) {
            if (polarEquals(segment.startPolar, intersection.polar) || 
                polarEquals(segment.endPolar, intersection.polar)) {
                segment.endpointIntersectionIds.add(intersection.intersectionId);
            }
        }
    }
    
    private boolean polarEquals(PolarCoordinate a, PolarCoordinate b) {
        return abs(a.radius - b.radius) < 0.0001 && abs(a.getAngleDegrees() - b.getAngleDegrees()) < 0.001;
    }
    
    private float getNodeDisplayRadius(JSONObject config) {
        try {
            if (config != null && config.hasKey("nodes")) {
                JSONObject nodes = config.getJSONObject("nodes");
                if (nodes.hasKey("display_radius")) {
                    return nodes.getFloat("display_radius");
                }
            }
        } catch (Exception e) {
            println("Warning: Failed to read node display_radius from config, using default value");
        }
        return 0.02f;
    }
    
    private float getIntersectionDisplayRadius(JSONObject config) {
        try {
            if (config != null && config.hasKey("intersections")) {
                JSONObject intersections = config.getJSONObject("intersections");
                if (intersections.hasKey("radius")) {
                    return intersections.getFloat("radius");
                }
            }
        } catch (Exception e) {
            println("Warning: Failed to read intersection radius from config, using default value");
        }
        return 0.01f;
    }
    
    private float getEdgeStrokeWidth(JSONObject config) {
        try {
            if (config != null && config.hasKey("edges")) {
                JSONObject edges = config.getJSONObject("edges");
                if (edges.hasKey("stroke_width")) {
                    return edges.getFloat("stroke_width");
                }
            }
        } catch (Exception e) {
            println("Warning: Failed to read edge stroke_width from config, using default value");
        }
        return 2.0f;
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
}