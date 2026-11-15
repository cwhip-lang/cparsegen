/*
 * src/source_location.cw — A byte in a grammar file, plus the include site
 * that pulled that file in.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SourceLocation out of src/grammar.cw.
 */

/*
 * A byte in a grammar file, plus the include site that pulled that file in.
 */
class SourceLocation {
    public:
    String path
    String displayPath
    int64 offset
    int64 line
    int64 column
    int64 logicalLine
    SourceLocation includedFrom
    SourceLocation(
            
            String sourcePath,
            
            String shownPath,
            
            int64 byteOffset,
            
            int64 sourceLine,
            

                   int64 sourceColumn,
            
            int64 grammarLine,
            
            SourceLocation parent)

}

/*
 * Create a SourceLocation and store the values passed to the constructor.
 *
 * sourcePath: source path (String). shownPath: shown path (String).
 * byteOffset: byte offset (int64). sourceLine: source line (int64).
 * sourceColumn: source column (int64). grammarLine: grammar line (int64).
 * parent: parent (SourceLocation).
 *
 * Returns the new object.
 */
SourceLocation SourceLocation.SourceLocation(
        
        String sourcePath,
        
        String shownPath,
        
        int64 byteOffset,
        
        int64 sourceLine,
        

               int64 sourceColumn,
        
        int64 grammarLine,
        
        SourceLocation parent) {
    path = sourcePath
    displayPath = shownPath
    offset = byteOffset
    line = sourceLine
    column = sourceColumn
    logicalLine = grammarLine
    includedFrom = parent
}
