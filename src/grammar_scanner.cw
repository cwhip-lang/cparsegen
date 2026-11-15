/*
 * src/grammar_scanner.cw — Scans one grammar file into tokens, directives,
 * and insertion blocks.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarScanner out of src/grammar.cw.
 */

/*
 * Scans one grammar file into tokens, directives, and insertion blocks.
 */
class GrammarScanner {
    public:
    String source
    String sourcePath
    String displayPath
    int64 offset
    int64 line
    int64 sourceLine
    int64 column
    bool previousCR
    SourceLocation includedFrom
    SourceSpan lastWordSpan
    String problem
    SourceSpan problemSpan
    GrammarScanner(
            
            String text,
            
            String path,
            
            String shownPath,
            
            int64 firstLine,
            

                   SourceLocation parent)

    int64 current()

    int64 following()

    void advance()

    SourceLocation location()

    SourceSpan byteSpan(int64 startOffset, int64 startLine, int64 startColumn)

    GrammarToken makeToken(
            
            int64 kind,
            
            String text,
            
            String name,
            
            int64 startOffset,
            

                           int64 startSourceLine,
            
            int64 startColumn,
            
            int64 startLogicalLine)

    bool letter(int64 value)

    bool digit(int64 value)

    void skipTrivia()

    String insertionWord()

    GrammarToken insertion(int64 startLine)

    GrammarToken next()

    int64 byteSpanBound(int64 value, int64 length)
    String byteSpan(String text, int64 first, int64 last)

}

include "grammar_scanner_1.cw"
include "grammar_scanner_2.cw"
include "grammar_scanner_3.cw"
