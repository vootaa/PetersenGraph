# Petersen Graph Static Data JSON Format Specification

## Overview

This document describes the JSON format for static Petersen graph data exported by the `StaticDataExporter` class. The format is designed to provide complete polar coordinate representation of the Petersen graph, suitable for visualization and analysis applications.

## File Structure

### Root Object

```json
{
  "version": "string",
  "created_time": "string", 
  "metadata": "object",
  "statistics": "object",
  "nodes": "object",
  "intersections": "object", 
  "original_edges": "object",
  "segments": "object",
  "layer_groups": "object"
}
```

## Field Descriptions

### Basic Information

- **`version`** (string): Format version identifier (e.g., "1.0")
- **`created_time`** (string): Timestamp when data was generated (format: "YYYY-M-D H:M:S")
- **`metadata`** (object): Configuration and styling information used during generation

### Statistics

```json
"statistics": {
  "total_nodes": "number",
  "total_intersections": "number", 
  "total_original_edges": "number",
  "total_segments": "number"
}
```

## Data Collections

All major data collections follow a dual-indexing pattern:

### Pattern Structure

```json
{
  "by_index": [...],  // Ordered by creation/ID
  "by_polar": [...]   // Sorted by polar coordinates (angle, then radius)
}
```

## Core Data Types

### Polar Coordinate

```json
{
  "radius": "string",        // Formatted to 2 decimal places
  "angle_radians": "string", // Angle in radians (2 decimal places)
  "angle_degrees": "string"  // Angle in degrees (2 decimal places)
}
```

### Node Object

```json
{
  "node_id": "number",           // Unique node identifier
  "chain_id": "number",          // Original graph chain ID
  "polar": "PolarCoordinate",    // Position in polar coordinates
  "layer": "string",             // "Middle" | "Inner" | "Outer"
  "display_radius": "string"     // Visual radius for rendering
}
```

### Intersection Object

```json
{
  "intersection_id": "number",   // Unique intersection identifier
  "polar": "PolarCoordinate",    // Position where edges intersect
  "edge1_id": "number",          // First intersecting edge ID
  "edge2_id": "number",          // Second intersecting edge ID
  "display_radius": "string"     // Visual radius for rendering
}
```

### Original Edge Object

```json
{
  "edge_id": "number",           // Unique edge identifier
  "edge_type": "number",         // 0-4: edge type classification
  "start_polar": "PolarCoordinate", // Start position
  "end_polar": "PolarCoordinate",   // End position
  "description": "string",       // Human-readable edge type
  "intersection_ids": "number[]" // IDs of intersections on this edge
}
```

#### Edge Type Classifications

- **0**: Middle to Inner
- **1**: Middle to Outer A
- **2**: Middle to Outer B  
- **3**: Inner Circle (Pentagram)
- **4**: Outer Circle (Loop)

### Segment Object

```json
{
  "segment_id": "number",              // Unique segment identifier
  "parent_edge_id": "number",          // Original edge this segment belongs to
  "start_polar": "PolarCoordinate",    // Segment start position
  "end_polar": "PolarCoordinate",      // Segment end position
  "is_intersected": "boolean",         // Whether segment has intersection endpoints
  "endpoint_intersection_ids": "number[]" // Intersection IDs at endpoints
}
```

## Layer Groups

The `layer_groups` object organizes data by geometric and topological properties:

```json
"layer_groups": {
  "middle_nodes": "Node[]",
  "inner_nodes": "Node[]", 
  "outer_nodes": "Node[]",
  "middle_to_inner_segments": "Segment[]",
  "middle_to_outer_segments": "Segment[]",
  "inner_circle_segments": "Segment[]",
  "outer_circle_segments": "Segment[]",
  "intersection_segments": "Segment[]"
}
```

### Layer Group Descriptions

- **Node Groups**: Nodes categorized by their radial layer
- **Segment Groups**: Segments categorized by their topological role
  - `middle_to_inner_segments`: Radial connections from middle to inner layer
  - `middle_to_outer_segments`: Radial connections from middle to outer layer  
  - `inner_circle_segments`: Pentagram segments in inner layer
  - `outer_circle_segments`: Loop segments in outer layer
  - `intersection_segments`: All segments that contain intersection points

## Metadata Structure

```json
"metadata": {
  "nodes": {
    "size": "number",
    "radius": {
      "middle": "number",
      "inner": "number", 
      "outer": "number"
    },
    "colors": {
      "middle": "number[]",  // RGB array
      "inner": "number[]",
      "outer": "number[]"
    }
  },
  "edges": {
    "thickness": "number",
    "colors": {
      "type0": "number[]",   // RGB for each edge type
      "type1": "number[]",
      "type2": "number[]", 
      "type3": "number[]",
      "type4": "number[]"
    }
  },
  "intersections": {
    "radius": "number",
    "color": "number[]"      // RGB array
  },
  "backgroundColor": {
    "rgb": "number[]"        // RGB array
  }
}
```

## Data Relationships

### Key Relationships

1. **Nodes** are connected by **Original Edges**
2. **Original Edges** are split into **Segments** at **Intersection** points
3. **Intersections** reference the two **Original Edges** that cross
4. **Segments** reference their parent **Original Edge** and any endpoint **Intersections**

### ID References

- All `*_id` fields are integers starting from 0
- IDs are unique within their respective collections
- Cross-references use these IDs to link related objects

## Coordinate System

- **Radius**: Distance from origin (0.0 to ~0.5)
- **Angle**: Measured from positive X-axis
  - Radians: 0 to 2π
  - Degrees: 0 to 360
- **Origin**: Center of the Petersen graph layout

## Usage Notes

### Sorting Behavior

- `by_index` arrays: Original creation order
- `by_polar` arrays: Sorted by angle (ascending), then radius (ascending)

### Precision

- All floating-point values formatted to 2 decimal places
- Stored as strings to maintain precision across platforms

### Validation

- All referenced IDs must exist in their respective collections
- Polar coordinates should have consistent radius/angle relationships
- Intersection endpoints should match segment start/end points

## Example Usage

See the accompanying code snippets for examples of:

- Loading and parsing JSON data
- Accessing nodes, edges, and intersections
- Filtering by layer groups
- Converting between coordinate systems
