/*
 * src/grammar_token.cw — One token from the grammar scanner, including
 * insertion targets and spans.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarToken out of src/grammar.cw.
 */

/*
 * One token from the grammar scanner, including insertion targets and spans.
 */
class GrammarToken {
    public:
    int64 kind
    String text
    String name
    int64 line
    String target
    String boundary
    SourceSpan span
    SourceSpan targetSpan
    SourceSpan boundarySpan
    GrammarToken(
            
            int64 tokenKind,
            
            String tokenText,
            
            String tokenName,
            
            int64 tokenLine)

}

/*
 * Create a GrammarToken and store the values passed to the constructor.
 *
 * tokenKind: token kind (int64). tokenText: token text (String). tokenName:
 * token name (String). tokenLine: token line (int64).
 *
 * Returns the new object.
 */
GrammarToken GrammarToken.GrammarToken(
        
        int64 tokenKind,
        
        String tokenText,
        
        String tokenName,
        
        int64 tokenLine) {
    kind = tokenKind
    text = tokenText
    name = tokenName
    line = tokenLine
    target = ""
    boundary = ""
    span = null
    targetSpan = null
    boundarySpan = null
}
