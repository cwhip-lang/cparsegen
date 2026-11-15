/*
 * src/parser_rule.cw — A named parser rule and the expression it expands to.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split ParserRule out of src/grammar.cw.
 */

/*
 * A named parser rule and the expression it expands to.
 */
class ParserRule {
    public:
    String name
    RuleExpr expression
    int64 line
    SourceSpan span
    ParserRule(String ruleName, int64 sourceLine)

}

/*
 * Create a ParserRule and store the values passed to the constructor.
 *
 * ruleName: rule name (String). sourceLine: source line (int64).
 *
 * Returns the new object.
 */
ParserRule ParserRule.ParserRule(String ruleName, int64 sourceLine) {
    name = ruleName
    line = sourceLine
    expression = null
    span = null
}
