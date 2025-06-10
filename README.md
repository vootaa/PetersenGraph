# PetersenGraph

Processing software implementation for visualizing and analyzing the Petersen Graph structure. This project provides accurate mathematical representation of the classic graph theory example with interactive debugging capabilities and data export functionality.

## Features

- Mathematically accurate Petersen Graph visualization with 20 nodes and 30 edges
- Three-layer concentric structure (inner, middle, outer circles)
- Color-coded connection types for visual analysis
- Interactive debug mode with node and edge labeling
- Data export capabilities (JSON and CSV formats)
- Real-time structure validation and statistics

## Documentation

- [Petersen Graph Specification v1.0](PetersenGraphSpecification_1.md) - Complete technical specification with precise coordinates and connection patterns
- [Petersen Graph Specification v0.0](PetersenGraphSpecification_0.md) - Initial specification (deprecated)

## Quick Start

1. Open the project in Processing IDE
2. Run `petersen_graph_processing.pde`
3. Press 'D' to toggle debug information
4. Press 'P' to print detailed graph data
5. Press 'E' to export data files

## Graph Structure

- **20 Nodes**: 5 middle (red), 5 inner (blue), 10 outer (yellow)
- **30 Edges**: 5 connection types with distinct colors
- **3-Regular Graph**: Each node has exactly 3 connections
- **Non-Planar**: Requires edge crossings in 2D representation

## Controls

- `D` - Toggle debug display (shows node/edge IDs)
- `P` - Print complete graph data to console
- `E` - Export data to JSON and CSV files
- `O` - Toggle export directory (data/ or exports/)
