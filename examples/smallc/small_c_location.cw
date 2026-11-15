/*
 * examples/smallc/small_c_location.cw — Byte offset of one AST node in the
 * original SmallC source.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCLocation out of examples/smallc/smallc_frontend.cw.
 */

/*
 * Byte offset of one AST node in the original SmallC source.
 */
class SmallCLocation {
    public:
    AstNode node
    int64 offset
    SmallCLocation(AstNode value, int64 at)

}

/*
 * Create a SmallCLocation and store the values passed to the constructor.
 *
 * value: value (AstNode). at: at (int64).
 *
 * Returns the new object.
 */
SmallCLocation SmallCLocation.SmallCLocation(AstNode value, int64 at) {
    node = value
    offset = at
}
