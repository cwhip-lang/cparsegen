/*
 * src/lexer_expr.cw — One lexer-expression node: literal, class, sequence,
 * choice, or repetition.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split LexerExpr out of src/grammar.cw.
 */

/*
 * One lexer-expression node. Kinds: character class, reference,
 * sequence, choice, repetition.
 */
class LexerExpr {
    public:
    int64 kind
    String value
    list children
    list ranges
    int64 minimum
    int64 maximum
    int64 line
    SourceSpan span
    LexerExpr(int64 expressionKind, int64 sourceLine)

}

/*
 * Create a LexerExpr and store the values passed to the constructor.
 *
 * expressionKind: expression kind (int64). sourceLine: source line (int64).
 *
 * Returns the new object.
 */
LexerExpr LexerExpr.LexerExpr(int64 expressionKind, int64 sourceLine) {
    kind = expressionKind
    value = ""
    children = []
    ranges = []
    minimum = 1
    maximum = 1
    line = sourceLine
    span = null
}
