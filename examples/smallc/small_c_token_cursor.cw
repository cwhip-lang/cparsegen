/*
 * examples/smallc/small_c_token_cursor.cw — Walks lexer tokens while
 * attaching source offsets to AST nodes.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCTokenCursor out of
 *              examples/smallc/smallc_frontend.cw.
 */

/*
 * Walks lexer tokens while attaching source offsets to AST nodes.
 */
class SmallCTokenCursor {
    public:
    int64 index
    SmallCTokenCursor()

}

/*
 * Create a SmallCTokenCursor and store the values passed to the constructor.
 *
 * Returns the new object.
 */
SmallCTokenCursor SmallCTokenCursor.SmallCTokenCursor() {
    index = 0
}
