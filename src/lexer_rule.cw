/*
 * src/lexer_rule.cw — A named lexer rule as it appears in the grammar,
 * before NFA compilation.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split LexerRule out of src/grammar.cw.
 */

/*
 * A named lexer rule as it appears in the grammar, before NFA compilation.
 */
class LexerRule {
    public:
    String name
    LexerExpr expression
    int64 quote
    int64 line
    SourceSpan span
    LexerRule(String tokenName, int64 sourceLine)

}

/*
 * Create a LexerRule and store the values passed to the constructor.
 *
 * tokenName: token name (String). sourceLine: source line (int64).
 *
 * Returns the new object.
 */
LexerRule LexerRule.LexerRule(String tokenName, int64 sourceLine) {
    name = tokenName
    expression = null
    quote = 0
    line = sourceLine
    span = null
}
