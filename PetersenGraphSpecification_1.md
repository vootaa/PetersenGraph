# Petersen Graph Specification

## Overview

The Petersen Graph is a well-known mathematical graph structure consisting of 20 vertices (nodes) and 30 edges (connections). It serves as a fundamental example in graph theory with distinctive structural properties and is commonly used for mathematical visualization and educational purposes.

## Node Structure

### Total Nodes: 20

The graph contains exactly 20 nodes distributed across three concentric layers with specific positioning:

#### Middle Circle (Chain IDs 0-4)

- 5 nodes positioned on the middle radius circle
- Radius: 0.3 units from center
- Angular positions (in radians): 5.0265, 0.0, 1.2566, 2.5133, 3.7699
- Evenly distributed around the circle at 72-degree intervals
- Acts as the central hub connecting to both inner and outer circles

#### Inner Circle (Chain IDs 5-9)

- 5 nodes positioned on the inner radius circle
- Radius: 0.15 units from center
- Angular positions identical to middle circle: 5.0265, 0.0, 1.2566, 2.5133, 3.7699
- Forms a pentagonal structure with specific connection patterns
- Aligned radially with corresponding middle circle nodes

#### Outer Circle (Chain IDs 10-19)

- 10 nodes positioned on the outer radius circle
- Radius: 0.48 units from center
- Angular positions (in radians): 4.8521, 0.1745, 1.0821, 2.6878, 3.5954, 5.2009, 6.1087, 1.4312, 2.3387, 3.9444
- Forms the largest ring structure with irregular angular distribution
- Connected in a specific sequence to maintain graph properties

## Radius Configuration

- **Inner Radius**: 0.15 units (smallest circle containing 5 nodes)
- **Middle Radius**: 0.3 units (medium circle containing 5 nodes)
- **Outer Radius**: 0.48 units (largest circle containing 10 nodes)

## Connection Structure

### Total Connections: 30

The graph maintains exactly 30 bidirectional edges organized into five distinct connection types:

#### Type 0: Middle to Inner (5 connections)

- Each middle circle node connects to exactly one inner circle node
- Pattern: Node i connects to Node (i+5)
- Connections: (0→5), (1→6), (2→7), (3→8), (4→9)

#### Type 1: Middle to Outer Pattern A (5 connections)

- Each middle circle node connects to one specific outer circle node
- Pattern: Node i connects to Node (i+10)
- Connections: (0→10), (1→11), (2→12), (3→13), (4→14)

#### Type 2: Middle to Outer Pattern B (5 connections)

- Each middle circle node connects to another specific outer circle node
- Pattern: Node i connects to Node (i+15)
- Connections: (0→15), (1→16), (2→17), (3→18), (4→19)

#### Type 3: Inner Circle Connections (5 connections)

- Inner circle nodes form a pentagonal connection pattern with skip-2 pattern
- Creates a pentagram (5-pointed star) within the inner circle
- Connections: (5→7), (6→8), (7→9), (8→5), (9→6)

#### Type 4: Outer Circle Connections (10 connections)

- Outer circle nodes form a decagonal (10-sided) connection pattern
- Creates a single closed loop connecting all outer nodes sequentially
- Connections: (10→11), (11→12), (12→13), (13→14), (14→15), (15→16), (16→17), (17→18), (18→19), (19→10)

## Graph Properties

### Regularity

- Each node has exactly 3 connections (3-regular graph)
- Total degree sum: 60 (20 nodes × 3 connections each)
- Vertex connectivity: 3
- Edge connectivity: 3

### Symmetry

- Maintains 5-fold rotational symmetry
- Three-layer concentric structure
- Balanced connection distribution across layers
- Dihedral symmetry group D₅

### Connectivity

- The graph is connected (all nodes reachable from any starting node)
- Non-planar graph (cannot be drawn on a plane without edge crossings)
- Diameter: 2 (maximum shortest path between any two nodes)
- Girth: 5 (shortest cycle length)

## Visual Characteristics

### Node Representation

- **Middle Circle Nodes**: Red color (RGB: 1.0, 0.2, 0.2)
- **Inner Circle Nodes**: Blue color (RGB: 0.2, 0.4, 1.0)
- **Outer Circle Nodes**: Yellow color (RGB: 1.0, 0.8, 0.2)
- Node size: 0.02 units radius with smooth circular shape

### Connection Representation

- **Type 0 (Middle to Inner)**: Bright Red lines (RGB: 0.9, 0.2, 0.2)
- **Type 1 (Middle to Outer +10)**: Bright Green lines (RGB: 0.2, 0.8, 0.2)
- **Type 2 (Middle to Outer +15)**: Bright Blue lines (RGB: 0.2, 0.4, 1.0)
- **Type 3 (Inner Circle)**: Yellow lines (RGB: 1.0, 0.8, 0.0)
- **Type 4 (Outer Circle)**: Magenta lines (RGB: 0.9, 0.4, 0.9)
- Line width: 0.002 units with smooth anti-aliased edges

### Rendering Properties

- Three distinct concentric circles with specific radius ratios
- Color-coded connection types for visual distinction
- Rotational symmetry around the center point
- Optional slow rotation for dynamic visualization
- Dark background (RGB: 0.05, 0.05, 0.08) for contrast
- Subtle vignette effect for visual enhancement

## Mathematical Significance

The Petersen Graph is notable for being:

- The smallest bridgeless cubic graph with no Hamiltonian path
- A counterexample to several graph theory conjectures
- The complete graph K₆ with edges of a perfect matching removed
- A fundamental example in algebraic graph theory

This specification ensures that any implementation of the Petersen Graph across different programming languages maintains the mathematical integrity, visual consistency, and structural properties of this classic graph theory example.
