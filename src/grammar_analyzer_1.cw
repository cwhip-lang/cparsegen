/*
 * src/grammar_analyzer_1.cw — Out-of-line methods for GrammarAnalyzer.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarAnalyzer methods out of src/analysis.cw while
 *              applying the coding standard.
 */

/*
 * Create a GrammarAnalyzer and store the values passed to the constructor.
 *
 * model: model (GrammarModel).
 *
 * Returns the new object.
 */
GrammarAnalyzer GrammarAnalyzer.GrammarAnalyzer(GrammarModel model) {
    grammar = model
    analysis = Analysis()
    lexerProblem = ""
    lexerProblemSpan = null
    lastNullable = false
}

/*
 * Runs every shared check in the established order and attaches the result.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.run() {
    grammar.diagnosticSpan = null
    grammar.relatedSpan = null
    grammar.diagnosticInfo = null
    String problem = analyze()
    analysis.complete = problem.equals("")
    grammar.analysis = analysis
    if (analysis.diagnostics.length > 0) {
        AnalysisDiagnostic last = analysis.diagnostics[
                analysis.diagnostics.length - 1] as AnalysisDiagnostic
        if (last.located) {
            grammar.diagnosticInfo = last.info
            grammar.diagnosticSpan = last.info.span
            grammar.relatedSpan = last.info.related
        }
    }
    return(problem)
}

/*
 * Record a located diagnostic and return the error text so the caller can
 * stop.
 *
 * phase: phase (String). error: error (String). span: span (SourceSpan).
 * related: related (SourceSpan).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.fail(
        String phase,
        String error,
        SourceSpan span,
        SourceSpan related) {
    analysis.diagnostics.append(AnalysisDiagnostic(phase, GrammarDiagnostic(
            
            error,
            
            span,
            
            related), true))
    return(error)
}

/*
 * Record a diagnostic that has no source span and return the error text.
 *
 * phase: phase (String). error: error (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.failPlain(String phase, String error) {
    analysis.diagnostics.append(AnalysisDiagnostic(phase, GrammarDiagnostic(
            
            error,
            
            null,
            
            null), false))
    return(error)
}

/*
 * Return true when identifier holds for the argument, and false otherwise.
 *
 * name: name (String).
 *
 * Returns true when the condition holds and false otherwise.
 */
bool GrammarAnalyzer.identifier(String name) {
    int64 i = 0
    while (i < name.length) {
        int64 byte = int64(name[i])
        bool letter = (byte >= 65 && byte <= 90) || (byte >= 97 &&
                byte <= 122) || byte == 95
        if (!letter && (i == 0 || byte < 48 || byte > 57)) {
            return(false)
        }
        i += 1
    }
    return(name.length > 0)
}

/*
 * Perform directive words for GrammarAnalyzer.
 *
 * content: content (String).
 *
 * Returns the list built by this method. The list is empty when nothing
 * matched.
 */
list GrammarAnalyzer.directiveWords(String content) {
    list pieces = content.replace("\t", " ").replace("\n", " ").replace("\r",
            " ").split(" ")
    list words = []
    int64 i = 0
    while (i < pieces.length) {
        String word = pieces[i] as String
        if (word.length > 0) {
            words.append(word)
        }
        i += 1
    }
    return(words)
}

/*
 * Resolve, validate, and compile the grammar. Returns an empty string on
 * success.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.analyze() {
    String error = validateInsertions()
    if (!error.equals("")) {
        return(error)
    }
    int64 d = 0
    while (d < grammar.lexerRules.length) {
        addLexer(grammar.lexerRules[d] as LexerRule)
        d += 1
    }
    error = lexicalDirectives()
    if (!error.equals("")) {
        return(error)
    }
    if (analysis.lexers.length == 0) {
        return(failPlain(
                
                "declarations",
                
                "grammar must declare a lexer rule"))
    }
    if (grammar.parserRules.length == 0) {
        return(failPlain(
                
                "declarations",
                
                "grammar must declare a parser rule"))
    }
    error = checkLexerNames()
    if (!error.equals("")) {
        return(error)
    }
    error = compileLexers()
    if (!error.equals("")) {
        return(error)
    }
    error = applySkips()
    if (!error.equals("")) {
        return(error)
    }
    error = checkParserNames()
    if (!error.equals("")) {
        return(error)
    }
    buildParserTable()
    computeNullability()
    buildLeftCorners()
    error = validateParser()
    if (!error.equals("")) {
        return(error)
    }
    finishLeftRecursion()
    return("")
}

/*
 * Perform add lexer for GrammarAnalyzer.
 *
 * rule: rule (LexerRule).
 *
 * Does not return a value.
 */
void GrammarAnalyzer.addLexer(LexerRule rule) {
    analysis.lexers.append(LexerPlan(analysis.lexers.length, rule))
}

/*
 * Perform validate insertions for GrammarAnalyzer.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.validateInsertions() {

    int64 i = 0
    while (i < grammar.insertions.length) {
        CodeInsertion block = grammar.insertions[i] as CodeInsertion
        if (!block.target.equals("c") && !block.target.equals("cwhip")) {
            return(fail("insertions", format(
                    
                    "line {}: unknown @insert target {}",
                    
                    block.location,
                    
                    
                block.target), block.targetSpan, null))
        }

        if (!block.boundary.equals("file_pre") && !block.boundary.equals(
                
                "file_post") &&
            !block.boundary.equals(
                
                "imports") && !block.boundary.equals(
                
                "declarations") &&
            !block.boundary.equals(
                
                "ast_pre") && !block.boundary.equals(
                
                "ast_post") &&
            !block.boundary.equals(
                
                "scanner_pre") && !block.boundary.equals(
                
                "scanner_post") &&
            !block.boundary.equals(
                
                "parser_pre") && !block.boundary.equals(
                
                "parser_post") &&
            !block.boundary.equals(
                
                "visitor_pre") && !block.boundary.equals(
                
                "visitor_post")) {
            return(fail("insertions", format(
                    
                    "line {}: unknown @insert boundary {}",
                    
                    
                block.location,
                    
                    block.boundary), block.boundarySpan, null))
        }

        i += 1
    }

    return("")
}
