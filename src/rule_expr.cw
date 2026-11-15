/*
 * src/rule_expr.cw — One parser-expression node before it is numbered into
 * the shared table.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split RuleExpr out of src/grammar.cw.
 */

/*
 * One parser-expression node before it is numbered into the shared
 * table. Kinds: reference, literal, sequence, choice, repetition.
 */
class RuleExpr {
    public:
    int64 kind
    String value
    list children
    int64 minimum
    int64 maximum
    int64 line
    SourceSpan span
    RuleExpr(int64 expressionKind, String text, int64 sourceLine)

}

/*
 * Create a RuleExpr and store the values passed to the constructor.
 *
 * expressionKind: expression kind (int64). text: text (String). sourceLine:
 * source line (int64).
 *
 * Returns the new object.
 */
RuleExpr RuleExpr.RuleExpr(int64 expressionKind, String text,
        int64 sourceLine) {
    kind = expressionKind
    value = text
    children = []
    minimum = 1
    maximum = 1
    line = sourceLine
    span = null
}
