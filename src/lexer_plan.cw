/*
 * src/lexer_plan.cw — A lexer rule after analysis: its NFA entry, skip flag,
 * and quote byte.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split LexerPlan out of src/analysis.cw.
 */

/*
 * One lexer token, including synthetic @quoted tokens, with its compiled
 * Thompson NFA entry and its resolved dependencies.
 */
class LexerPlan {
    public:
    int64 index
    String name
    LexerRule rule
    int64 quote
    bool skip
    bool nullable
    int64 entry
    int64 accept
    int64 firstState
    int64 stateCount
    int64 color
    list references
    int64 line
    SourceSpan span
    LexerPlan(int64 position, LexerRule declaration)

}

/*
 * Create a LexerPlan and store the values passed to the constructor.
 *
 * position: position (int64). declaration: declaration (LexerRule).
 *
 * Returns the new object.
 */
LexerPlan LexerPlan.LexerPlan(int64 position, LexerRule declaration) {
    index = position
    name = declaration.name
    rule = declaration
    quote = declaration.quote
    skip = false
    nullable = false
    entry = -1
    accept = -1
    firstState = 0
    stateCount = 0
    color = 0
    references = []
    line = declaration.line
    span = declaration.span
}
