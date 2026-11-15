/*
 * src/code_insertion.cw — One @insert block: target language, seam name, and
 * the opaque body.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split CodeInsertion out of src/grammar.cw.
 */

/*
 * One @insert block: target language, seam name, and the opaque body.
 */
class CodeInsertion {
    public:
    String target
    String boundary
    String content
    String source
    int64 line
    int64 location
    SourceSpan span
    SourceSpan targetSpan
    SourceSpan boundarySpan
    CodeInsertion(GrammarToken token, String path, int64 firstLine)

}

/*
 * Create a CodeInsertion and store the values passed to the constructor.
 *
 * token: token (GrammarToken). path: path (String). firstLine: first line
 * (int64).
 *
 * Returns the new object.
 */
CodeInsertion CodeInsertion.CodeInsertion(
        GrammarToken token,
        String path,
        int64 firstLine) {
    target = token.target
    boundary = token.boundary
    content = token.text
    source = path
    line = token.line - firstLine + 1
    location = token.line
    span = token.span
    targetSpan = token.targetSpan
    boundarySpan = token.boundarySpan
}
