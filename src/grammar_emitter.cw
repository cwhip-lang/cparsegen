/*
 * src/grammar_emitter.cw — Writes the Cwhip scanner, parser, AST, visitor,
 * and optional DOT graph from the shared analysis.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarEmitter out of src/emitter.cw.
 */

/*
 * Writes the Cwhip scanner, parser, AST, visitor, and optional DOT graph
 * from the shared analysis.
 */
class GrammarEmitter {
    public:
    GrammarModel grammar
    Analysis analysis
    list literals
    list expressions
    list visitorNames
    list visitorSuffixes
    GrammarEmitter(GrammarModel model)

    String quoted(String value)

    String literalKind(int64 index)

    void emitInsertions(String output, String target, String boundary)

    void emitScanner(String output)

    void emitParser(String output)

    String emitProgram(bool library)

    void dotExpression(String output, String owner, int64 index, String order)

    String emitDot()

    int64 byteSpanBound(int64 value, int64 length)
    String byteSpan(String text, int64 first, int64 last)

}

include "grammar_emitter_1.cw"
include "grammar_emitter_2.cw"
