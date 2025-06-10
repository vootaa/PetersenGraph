# Petersen Graph Specification

## Overview

The Petersen Graph is a well-known mathematical graph structure consisting of 20 vertices (nodes) and 30 edges (connections). It serves as a fundamental example in graph theory with distinctive structural properties.

## Node Structure

### Total Nodes: 20

The graph contains exactly 20 nodes distributed across three concentric layers:

### Middle Circle (Chain IDs 0-4)

- 5 nodes positioned on the middle radius circle
- Evenly distributed around the circle
- Acts as the central hub connecting to both inner and outer circles

### Inner Circle (Chain IDs 5-9)

- 5 nodes positioned on the inner radius circle
- Angular positions correspond to the middle circle nodes
- Forms a pentagonal structure with specific connection patterns

### Outer Circle (Chain IDs 10-19)

- 10 nodes positioned on the outer radius circle
- Forms the largest ring structure
- Connected in a specific sequence to maintain graph properties

## Radius Configuration

- **Inner Radius**: Smallest circle containing 5 nodes
- **Middle Radius**: Medium circle containing 5 nodes
- **Outer Radius**: Largest circle containing 10 nodes

## Connection Structure

### Total Connections: 30

The graph maintains exactly 30 bidirectional edges organized into five distinct connection types:

### Type 0: Middle to Inner (5 connections)

- Each middle circle node connects to exactly one inner circle node
- Pattern: Node i connects to Node (i+5)

### Type 1: Middle to Outer Pattern A (5 connections)

- Each middle circle node connects to one specific outer circle node
- Pattern: Node i connects to Node (i+10)

### Type 2: Middle to Outer Pattern B (5 connections)

- Each middle circle node connects to another specific outer circle node
- Pattern: Node i connects to Node (i+15)

### Type 3: Inner Circle Connections (5 connections)

- Inner circle nodes form a pentagonal connection pattern
- Creates a closed loop with specific skipping pattern

### Type 4: Outer Circle Connections (10 connections)

- Outer circle nodes form a decagonal (10-sided) connection pattern
- Creates a single closed loop connecting all outer nodes sequentially

## Graph Properties

### Regularity

- Each node has exactly 3 connections (3-regular graph)
- Total degree sum: 60 (20 nodes × 3 connections each)

### Symmetry

- Maintains rotational symmetry
- Three-layer concentric structure
- Balanced connection distribution across layers

### Connectivity

- The graph is connected (all nodes reachable from any starting node)
- Non-planar graph (cannot be drawn on a plane without edge crossings)

## Visual Characteristics

- Typically rendered with three distinct concentric circles
- Each layer may use different colors for visual distinction
- Connection types often color-coded for clarity
- Commonly displayed with rotational symmetry around the center point

This specification ensures that any implementation of the Petersen Graph across different programming languages maintains the mathematical integrity and structural properties of this classic graph theory example.
