/*
 * src/grammar_model.cw — Every declaration collected from a grammar, plus
 * the analysis attached later.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarModel out of src/grammar.cw.
 */

/*
 * Every declaration collected from a grammar, plus the analysis attached
 * later.
 */
class GrammarModel {
    public:
    list lexerRules
    list parserRules
    list directives
    list insertions
    SourceSpan diagnosticSpan
    SourceSpan relatedSpan
    GrammarDiagnostic diagnosticInfo
    Analysis analysis
    GrammarModel()

}

/*
 * Declarations only; GrammarAnalyzer attaches the shared analysis once.
 *
 * Returns the new object.
 */
GrammarModel GrammarModel.GrammarModel() {
    lexerRules = []
    parserRules = []
    directives = []
    insertions = []
    diagnosticSpan = null
    relatedSpan = null
    diagnosticInfo = null
    analysis = null
}
