/*
 * src/source_span.cw — A half-open range of grammar source, from the first
 * byte through the last.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SourceSpan out of src/grammar.cw.
 */

/*
 * A half-open range of grammar source, from the first byte through the last.
 */
class SourceSpan {
    public:
    SourceLocation first
    SourceLocation last
    SourceSpan(SourceLocation startPoint, SourceLocation endPoint)

}

/*
 * Create a SourceSpan and store the values passed to the constructor.
 *
 * startPoint: start point (SourceLocation). endPoint: end point
 * (SourceLocation).
 *
 * Returns the new object.
 */
SourceSpan SourceSpan.SourceSpan(
        SourceLocation startPoint,
        SourceLocation endPoint) {
    first = startPoint
    last = endPoint
}
