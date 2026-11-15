/*
 * src/analysis_model.cw — The immutable facts backends read: references,
 * nullability, NFAs, and the expression table.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split Analysis out of src/analysis.cw.
 */

/*
 * The immutable facts backends read: references, nullability, NFAs, and the
 * expression table.
 */
class Analysis {
    public:
    bool complete
    LexicalConfig lexical
    list lexers
    list lexerStates
    list lexerReferences
    list parserRules
    list expressions
    list literals
    list parserReferences
    bool leftRecursive
    list diagnostics
    Analysis()

    int64 lexerIndex(String name)

    int64 parserIndex(String name)

    int64 literalIndex(String value)

    int64 nameCount(list names, String name)

}

/*
 * Create a Analysis and store the values passed to the constructor.
 *
 * Returns the new object.
 */
Analysis Analysis.Analysis() {
    complete = false
    lexical = LexicalConfig()
    lexers = []
    lexerStates = []
    lexerReferences = []
    parserRules = []
    expressions = []
    literals = []
    parserReferences = []
    leftRecursive = false
    diagnostics = []
}

/*
 * Perform lexer index for Analysis.
 *
 * name: name (String).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 Analysis.lexerIndex(String name) {
    int64 i = 0
    while (i < lexers.length) {
        if ((lexers[i] as LexerPlan).name.equals(name)) {
            return(i)
        }
        i += 1
    }
    return(-1)
}

/*
 * Perform parser index for Analysis.
 *
 * name: name (String).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 Analysis.parserIndex(String name) {
    int64 i = 0
    while (i < parserRules.length) {
        if ((parserRules[i] as ParserRuleFacts).name.equals(name)) {
            return(i)
        }
        i += 1
    }
    return(-1)
}

/*
 * Perform literal index for Analysis.
 *
 * value: value (String).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 Analysis.literalIndex(String value) {
    int64 i = 0
    while (i < literals.length) {
        if ((literals[i] as String).equals(value)) {
            return(i)
        }
        i += 1
    }
    return(-1)
}

/*
 * Perform name count for Analysis.
 *
 * names: names (list). name: name (String).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 Analysis.nameCount(list names, String name) {
    int64 count = 0
    int64 i = 0
    while (i < names.length) {
        if ((names[i] as String).equals(name)) {
            count += 1
        }
        i += 1
    }
    return(count)
}
