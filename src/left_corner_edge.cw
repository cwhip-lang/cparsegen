/*
 * src/left_corner_edge.cw — One left-corner edge from a parser rule to a
 * token or rule it can start with.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split LeftCornerEdge out of src/analysis.cw.
 */

/*
 * An edge A -> B means B can start a match of A once only nullable
 * material precedes it. zeroContext is true when nothing non-nullable
 * can follow it inside A, so a cycle of such edges consumes nothing
 * and nothing follows it.
 */
class LeftCornerEdge {
    public:
    int64 origin
    int64 destination
    bool zeroContext
    int64 line
    SourceSpan span
    LeftCornerEdge(
            
            int64 source,
            
            int64 target,
            
            bool zero,
            
            int64 sourceLine,
            
            SourceSpan location)

}

/*
 * Create a LeftCornerEdge and store the values passed to the constructor.
 *
 * source: source (int64). target: target (int64). zero: zero (bool).
 * sourceLine: source line (int64). location: location (SourceSpan).
 *
 * Returns the new object.
 */
LeftCornerEdge LeftCornerEdge.LeftCornerEdge(
        
        int64 source,
        
        int64 target,
        
        bool zero,
        
        int64 sourceLine,
        
        SourceSpan location) {
    origin = source
    destination = target
    zeroContext = zero
    line = sourceLine
    span = location
}
