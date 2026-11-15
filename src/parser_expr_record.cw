/*
 * src/parser_expr_record.cw — One numbered parser expression, shared by both
 * emitters.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split ParserExprRecord out of src/analysis.cw.
 */

/*
 * Numbered parser expression. Children precede parents, so the table
 * order is the emitted expression order. kind: 0 reference, 1 literal,
 * 2 sequence, 3 choice, 4 repetition. target is a parser-rule index
 * and token a lexer index for references (-1 otherwise); literal
 * indexes Analysis.literals.
 */
class ParserExprRecord {
    public:
    int64 index
    int64 kind
    String value
    list children
    int64 minimum
    int64 maximum
    int64 required
    int64 literal
    int64 target
    int64 token
    bool nullable
    int64 line
    SourceSpan span
    ParserExprRecord(RuleExpr expression, int64 position)

}

/*
 * Create a ParserExprRecord and store the values passed to the constructor.
 *
 * expression: expression (RuleExpr). position: position (int64).
 *
 * Returns the new object.
 */
ParserExprRecord ParserExprRecord.ParserExprRecord(
        RuleExpr expression,
        int64 position) {
    index = position
    kind = expression.kind
    value = expression.value
    children = []
    minimum = expression.minimum
    maximum = expression.maximum
    required = 0
    literal = -1
    target = -1
    token = -1
    nullable = false
    line = expression.line
    span = expression.span
}
