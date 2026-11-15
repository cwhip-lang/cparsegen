/*
 * src/grammar_source.cw — One file that contributed lines to the logical
 * grammar, with its include parent.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarSource out of src/grammar.cw.
 */

/*
 * One file that contributed lines to the logical grammar, with its include
 * parent.
 */
class GrammarSource {
    public:
    String path
    String displayPath
    int64 firstLine
    int64 lineCount
    int64 includedAt
    bool active
    SourceLocation includedFrom
    GrammarSource(
            
            String filename,
            
            int64 first,
            
            int64 count,
            
            SourceLocation parent)

}

/*
 * Create a GrammarSource and store the values passed to the constructor.
 *
 * filename: filename (String). first: first (int64). count: count (int64).
 * parent: parent (SourceLocation).
 *
 * Returns the new object.
 */
GrammarSource GrammarSource.GrammarSource(
        
        String filename,
        
        int64 first,
        
        int64 count,
        
        SourceLocation parent) {
    path = filename
    displayPath = filename
    firstLine = first
    lineCount = count
    includedAt = 0
    if (parent != null) {
        includedAt = parent.logicalLine
    }
    includedFrom = parent
    active = true
}
