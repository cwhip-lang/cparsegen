/*
 * src/grammar_analyzer.cw — Builds one Analysis from an include-expanded
 * grammar and attaches it to the model.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarAnalyzer out of src/analysis.cw.
 */

/*
 * Builds one Analysis from an include-expanded grammar and attaches it to
 * the model.
 */
class GrammarAnalyzer {
    public:
    GrammarModel grammar
    Analysis analysis
    String lexerProblem
    SourceSpan lexerProblemSpan
    bool lastNullable
    GrammarAnalyzer(GrammarModel model)

    String run()

    String fail(String phase, String error, SourceSpan span, SourceSpan related)

    String failPlain(String phase, String error)

    bool identifier(String name)

    list directiveWords(String content)

    String analyze()

    void addLexer(LexerRule rule)

    String validateInsertions()

    String lexicalDirectives()

    String checkLexerNames()

    String resolveLexer(LexerPlan owner, LexerExpr expression, int64 depth)

    int64 lexerState(
            
            int64 kind,
            
            list ranges,
            
            int64 next,
            
            int64 alternate,
            
            int64 line,
            
            SourceSpan span)

    int64 compileLexer(LexerExpr expression, int64 next, int64 depth)

    String compileLexers()

    String applySkips()

    String checkParserNames()

    int64 record(RuleExpr expression)

    ParserExprRecord expressionAt(int64 index)

    ParserRuleFacts ruleAt(int64 index)

    void buildParserTable()

    void computeNullability()

    void collectCorners(ParserRuleFacts owner, int64 index, bool zero)

    void buildLeftCorners()

    String validateExpression(int64 index)

    String zeroCycle(int64 rule, list onPath, list done)

    String validateParser()

    void finishLeftRecursion()

}

include "grammar_analyzer_1.cw"
include "grammar_analyzer_2.cw"
include "grammar_analyzer_3.cw"
include "grammar_analyzer_4.cw"
include "grammar_analyzer_5.cw"
