/*
 * src/grammar_directive.cw — An @-directive and its raw payload.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarDirective out of src/grammar.cw.
 */

/*
 * An @-directive and its raw payload.
 */
class GrammarDirective {
    public:
    String name
    String content
    int64 line
    SourceSpan span
    GrammarDirective(String directiveName, String payload, int64 sourceLine)

}

/*
 * Create a GrammarDirective and store the values passed to the constructor.
 *
 * directiveName: directive name (String). payload: payload (String).
 * sourceLine: source line (int64).
 *
 * Returns the new object.
 */
GrammarDirective GrammarDirective.GrammarDirective(
        String directiveName,
        String payload,
        int64 sourceLine) {
    name = directiveName
    content = payload
    line = sourceLine
    span = null
}
