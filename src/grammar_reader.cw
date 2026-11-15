/*
 * src/grammar_reader.cw — Parses the token stream of one grammar file into
 * the model.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarReader out of src/grammar.cw.
 */

/*
 * Parses the token stream of one grammar file into the model.
 */
class GrammarReader {
    public:
    list tokens
    int64 position
    int64 classPosition
    String problem
    GrammarToken inclusion
    String sourcePath
    int64 sourceFirstLine
    SourceSpan problemSpan
    GrammarDiagnostic diagnosticInfo
    GrammarReader(
            
            String source,
            
            int64 firstLine,
            
            String path,
            
            String shownPath,
            

                  SourceLocation parent)

    GrammarToken peek()

    GrammarToken take()

    void fail(String message, SourceSpan span)

    int64 classByte(GrammarToken token)

    list classRanges(GrammarToken token)

    LexerExpr lexerChoice(int64 line, int64 depth)

    LexerExpr lexerSequence(int64 line, int64 depth)

    RuleExpr choice()

    RuleExpr sequence()

    void readInto(GrammarModel grammar)

}

include "grammar_reader_1.cw"
include "grammar_reader_2.cw"
