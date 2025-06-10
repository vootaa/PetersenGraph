/**
 * Helper class for sorting points by polar coordinates
 */
class PolarPoint {
    String type; // "Node" or "Int."
    int id;
    PolarCoordinate polar;
    String info;
    
    PolarPoint(String type, int id, PolarCoordinate polar, String info) {
        this.type = type;
        this.id = id;
        this.polar = polar;
        this.info = info;
    }
}