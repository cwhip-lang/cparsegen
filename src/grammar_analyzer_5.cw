/*
 * src/grammar_analyzer_5.cw — Out-of-line methods for GrammarAnalyzer.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarAnalyzer methods out of src/analysis.cw while
 *              applying the coding standard.
 */

/*
 * Consuming left recursion needs a conservative token lower bound per
 * expression.
 *
 * Does not return a value.
 */
void GrammarAnalyzer.finishLeftRecursion() {
    int64 r = 0
    while (r < analysis.parserRules.length) {
        if (ruleAt(r).leftRecursive) {
            analysis.leftRecursive = true
        }
        r += 1
    }
    if (!analysis.leftRecursive) {
        return
    }
    int64 e = 0
    while (e < analysis.expressions.length) {
        ParserExprRecord entry = expressionAt(e)
        if (!entry.nullable) {
            entry.required = 1
        }
        e += 1
    }
}
