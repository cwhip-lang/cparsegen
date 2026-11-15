/*
 * src/parser_rule_facts.cw — Per-rule analysis: nullability, the expression-
 * table root, and reachability.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split ParserRuleFacts out of src/analysis.cw.
 */

/*
 * Per-rule analysis: nullability, the expression-table root, and
 * reachability.
 */
class ParserRuleFacts {
    public:
    int64 index
    String name
    ParserRule rule
    int64 root
    bool nullable
    bool leftRecursive
    list corners
    list reachable
    int64 line
    SourceSpan span
    ParserRuleFacts(int64 position, ParserRule declaration)

}

/*
 * Create a ParserRuleFacts and store the values passed to the constructor.
 *
 * position: position (int64). declaration: declaration (ParserRule).
 *
 * Returns the new object.
 */
ParserRuleFacts ParserRuleFacts.ParserRuleFacts(
        int64 position,
        ParserRule declaration) {
    index = position
    name = declaration.name
    rule = declaration
    root = -1
    nullable = false
    leftRecursive = false
    corners = []
    reachable = []
    line = declaration.line
    span = declaration.span
}
