/**
 * Polar Coordinate Converter for Petersen Graph
 * Converts Cartesian coordinates to polar coordinates and provides utility functions
 */
class PolarCoordinateConverter {
  
  /**
   * Convert Cartesian coordinates to polar coordinates
   * @param x X coordinate
   * @param y Y coordinate
   * @return PolarCoordinate object containing radius and angle
   */
  PolarCoordinate cartesianToPolar(float x, float y) {
    float radius = sqrt(x * x + y * y);
    float angle = atan2(y, x);
    
    // Normalize angle to [0, 2π) range
    if (angle < 0) {
      angle += TWO_PI;
    }
    
    return new PolarCoordinate(radius, angle);
  }
  
  /**
   * Convert polar coordinates to Cartesian coordinates
   * @param radius Distance from origin
   * @param angle Angle in radians
   * @return PVector containing x and y coordinates
   */
  PVector polarToCartesian(float radius, float angle) {
    float x = radius * cos(angle);
    float y = radius * sin(angle);
    return new PVector(x, y);
  }
  
  /**
   * Convert angle from radians to degrees
   * @param radians Angle in radians
   * @return Angle in degrees
   */
  float radiansToDegrees(float radians) {
    return radians * 180.0 / PI;
  }
  
  /**
   * Convert angle from degrees to radians
   * @param degrees Angle in degrees
   * @return Angle in radians
   */
  float degreesToRadians(float degrees) {
    return degrees * PI / 180.0;
  }
  
  /**
   * Format polar coordinates as a readable string
   * @param polar PolarCoordinate object
   * @param includeRadians Whether to include angle in radians
   * @param includeDegrees Whether to include angle in degrees
   * @return Formatted string
   */
  String formatPolarCoordinate(PolarCoordinate polar, boolean includeRadians, boolean includeDegrees) {
    StringBuilder sb = new StringBuilder();
    sb.append("r=").append(String.format("%.4f", polar.radius));
    
    if (includeRadians) {
      sb.append(", θ=").append(String.format("%.4f", polar.angle)).append("rad");
    }
    
    if (includeDegrees) {
      if (includeRadians) sb.append(", ");
      else sb.append(", ");
      sb.append("θ=").append(String.format("%.2f", radiansToDegrees(polar.angle))).append("°");
    }
    
    return sb.toString();
  }
  
  /**
   * Get the theoretical radius for a given layer in Petersen Graph
   * @param layerType "inner", "middle", or "outer"
   * @param config JSON configuration object
   * @return Expected radius for that layer
   */
  float getTheoreticalRadius(String layerType, JSONObject config) {
    JSONObject radiusConfig = config.getJSONObject("nodes").getJSONObject("radius");
    
    switch (layerType.toLowerCase()) {
      case "inner":
        return radiusConfig.getFloat("inner");
      case "middle":
        return radiusConfig.getFloat("middle");
      case "outer":
        return radiusConfig.getFloat("outer");
      default:
        return 0.0;
    }
  }
  
  /**
   * Calculate the angular difference between two angles (in radians)
   * Returns the smallest angle between them
   * @param angle1 First angle in radians
   * @param angle2 Second angle in radians
   * @return Angular difference in radians (0 to π)
   */
  float angularDifference(float angle1, float angle2) {
    float diff = abs(angle1 - angle2);
    if (diff > PI) {
      diff = TWO_PI - diff;
    }
    return diff;
  }
  
  /**
   * Check if a point is approximately on a given radius
   * @param point Cartesian coordinates
   * @param expectedRadius Expected radius
   * @param tolerance Tolerance for comparison
   * @return True if point is within tolerance of expected radius
   */
  boolean isOnRadius(PVector point, float expectedRadius, float tolerance) {
    PolarCoordinate polar = cartesianToPolar(point.x, point.y);
    return abs(polar.radius - expectedRadius) <= tolerance;
  }
  
  /**
   * Get the layer name for a given chain ID
   * @param chainId Chain ID of the node
   * @return Layer name ("Middle", "Inner", "Outer", or "Unknown")
   */
  String getLayerFromChainId(int chainId) {
    if (chainId >= 0 && chainId <= 4) return "Middle";
    else if (chainId >= 5 && chainId <= 9) return "Inner";
    else if (chainId >= 10 && chainId <= 19) return "Outer";
    return "Unknown";
  }
}

/**
 * Data class to hold polar coordinate information
 */
class PolarCoordinate {
  float radius;
  float angle; // in radians
  
  PolarCoordinate(float radius, float angle) {
    this.radius = radius;
    this.angle = angle;
  }
  
  /**
   * Get angle in degrees
   * @return Angle in degrees
   */
  float getAngleDegrees() {
    return radiansToDegrees(angle);
  }
  
  /**
   * Convert angle from radians to degrees (helper method)
   */
  private float radiansToDegrees(float radians) {
    return radians * 180.0 / PI;
  }
  
  /**
   * Get formatted string representation
   * @return String representation of polar coordinates
   */
  String toString() {
    return String.format("r=%.4f, θ=%.4frad, θ=%.2f°", radius, angle, getAngleDegrees());
  }
  
  /**
   * Get compact string representation (radius and degrees only)
   * @return Compact string representation
   */
  String toCompactString() {
    return String.format("r=%.3f, θ=%.1f°", radius, getAngleDegrees());
  }
}