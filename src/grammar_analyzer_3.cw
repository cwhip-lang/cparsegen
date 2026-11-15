/*
 * src/grammar_analyzer_3.cw — Out-of-line methods for GrammarAnalyzer.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarAnalyzer methods out of src/analysis.cw while
 *              applying the coding standard.
 */

/*
 * Perform compile lexer for GrammarAnalyzer.
 *
 * expression: expression (LexerExpr). next: next (int64). depth: depth
 * (int64).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 GrammarAnalyzer.compileLexer(
        LexerExpr expression,
        int64 next,
        int64 depth) {
    if (!lexerProblem.equals("")) {
        return(-1)
    }
    if (depth > 128) {
        lexerProblem = format(
                "line {}: expanded lexer nesting/reference limit exceeded (128)", expression.line)
        lexerProblemSpan = expression.span
        return(-1)
    }

    if (expression.kind == 0) {
        return(lexerState(
                
                0,
                
                expression.ranges,
                
                next,
                
                -1,
                
                expression.line,
                
                expression.span))
    }

    if (expression.kind == 1) {
        LexerPlan target = analysis.lexers[analysis.lexerIndex(
                expression.value)] as LexerPlan
        return(compileLexer(target.rule.expression, next, depth + 1))
    }
    if (expression.kind == 2) {
        int64 c = expression.children.length - 1
        while (c >= 0 && lexerProblem.equals("")) {
            next = compileLexer(expression.children[c] as LexerExpr, next,
                    depth + 1)
            c -= 1
        }
        return(next)
    }
    if (expression.kind == 3) {
        int64 result = compileLexer(expression.children[0] as LexerExpr, next,
                depth + 1)
        int64 c = 1
        while (c < expression.children.length && lexerProblem.equals("")) {
            int64 branch = compileLexer(expression.children[c] as LexerExpr,
                    next, depth + 1)
            result = lexerState(1, [], result, branch, expression.line,
                    expression.span)
            c += 1
        }
        return(result)
    }
    int64 split = lexerState(1, [], -1, next, expression.line, expression.span)
    if (split < 0) {
        return(-1)
    }
    int64 continuation = next
    if (expression.maximum < 0) {
        continuation = split
    }
    int64 child = compileLexer(expression.children[0] as LexerExpr,
            continuation, depth + 1)
    (analysis.lexerStates[split] as LexerState).next = child
    if (expression.minimum == 0) {
        return(split)
    }
    return(child)
}

/*
 * Perform compile lexers for GrammarAnalyzer.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.compileLexers() {

    int64 i = 0
    while (i < analysis.lexers.length) {

        LexerPlan plan = analysis.lexers[i] as LexerPlan
        if (plan.quote == 0) {
            if (plan.color == 0) {
                plan.color = 1
                String error = resolveLexer(plan, plan.rule.expression, 0)
                if (!error.equals("")) {
                    return(error)
                }
                plan.nullable = lastNullable
                plan.color = 2
            }
            if (plan.nullable) {
                return(fail("lexer", format(
                        
                        "line {}: lexer rule {} can match empty input",
                        
                        
                    plan.line,
                        
                        plan.name), plan.span, null))
            }
            plan.firstState = analysis.lexerStates.length
            plan.accept = lexerState(2, [], -1, -1, plan.line, plan.span)
            plan.entry = compileLexer(plan.rule.expression, plan.accept, 0)
            if (!lexerProblem.equals("")) {
                return(fail("lexer", lexerProblem, lexerProblemSpan, null))
            }
            plan.stateCount = analysis.lexerStates.length - plan.firstState
        }

        i += 1
    }

    i = 0
    while (i < analysis.lexers.length) {
        list references = (analysis.lexers[i] as LexerPlan).references
        int64 r = 0
        while (r < references.length) {
            analysis.lexerReferences.append(references[r])
            r += 1
        }
        i += 1
    }
    return("")
}

/*
 * Perform apply skips for GrammarAnalyzer.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.applySkips() {

    int64 i = 0
    while (i < grammar.directives.length) {

        GrammarDirective directive = grammar.directives[i] as GrammarDirective
        if (directive.name.equals("skip")) {
            int64 token = analysis.lexerIndex(directive.content)
            if (token < 0) {
                return(fail("directives", format(
                        
                        "line {}: @skip requires a declared lexer token name",
                        
                        
                    directive.line), directive.span, null))
            }
            (analysis.lexers[token] as LexerPlan).skip = true
        }

        i += 1
    }

    String keyword = analysis.lexical.keywordToken
    if (!keyword.equals("")) {

        LexerPlan token = analysis.lexers[analysis.lexerIndex(
                keyword)] as LexerPlan
        if (token.skip) {
            return(fail(
                    
                    "directives",
                    
                    "@keywords cannot use a skipped lexer token",
                    
                    
                        analysis.lexical.keywordSpan,
                    
                    token.span))
        }

    }

    return("")
}

/*
 * Validate parser names and record a problem when it is illegal or
 * unsupported.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.checkParserNames() {
    list names = []
    int64 i = 0
    while (i < grammar.parserRules.length) {
        names.append((grammar.parserRules[i] as ParserRule).name)
        i += 1
    }
    i = 0

    while (i < grammar.parserRules.length) {
        ParserRule rule = grammar.parserRules[i] as ParserRule
        int64 first = int64(rule.name[0])
        if (first < 97 || first > 122) {
            return(fail("parser", format(
                    
                    "line {}: parser-rule names must begin with a lowercase letter",
                    
                    
                rule.line), rule.span, null))
        }

        if (analysis.nameCount(names, rule.name) > 1) {
            SourceSpan previous = null
            int64 p = 0
            while (p < i && previous == null) {
                ParserRule candidate = grammar.parserRules[p] as ParserRule
                if (candidate.name.equals(rule.name)) {
                    previous = candidate.span
                }
                p += 1
            }
            if (previous != null) {
                return(fail("parser", format(
                        
                        "line {}: duplicate parser rule {}",
                        
                        rule.line,
                        
                        
                    rule.name), rule.span, previous))
            }
        }

        i += 1
    }

    return("")
}

/*
 * Numbers expressions children-first, resolves references, and interns
 * literals.
 *
 * expression: expression (RuleExpr).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 GrammarAnalyzer.record(RuleExpr expression) {
    ParserExprRecord entry = ParserExprRecord(expression, 0)
    int64 c = 0
    while (c < expression.children.length) {
        entry.children.append(record(expression.children[c] as RuleExpr))
        c += 1
    }
    if (expression.kind == 0) {
        entry.token = analysis.lexerIndex(expression.value)
        if (entry.token < 0) {
            entry.target = analysis.parserIndex(expression.value)
        }
    }
    if (expression.kind == 1) {
        entry.literal = analysis.literalIndex(expression.value)
        if (entry.literal < 0) {
            entry.literal = analysis.literals.length
            analysis.literals.append(expression.value)
        }
    }
    entry.index = analysis.expressions.length
    analysis.expressions.append(entry)
    return(entry.index)
}

/*
 * Perform expression at for GrammarAnalyzer.
 *
 * index: index (int64).
 *
 * Returns the ParserExprRecord result.
 */
ParserExprRecord GrammarAnalyzer.expressionAt(int64 index) {
    return(analysis.expressions[index] as ParserExprRecord)
}

/*
 * Perform rule at for GrammarAnalyzer.
 *
 * index: index (int64).
 *
 * Returns the ParserRuleFacts result.
 */
ParserRuleFacts GrammarAnalyzer.ruleAt(int64 index) {
    return(analysis.parserRules[index] as ParserRuleFacts)
}

/*
 * Number expressions children-first, resolve references, and intern
 * literals.
 *
 * Does not return a value.
 */
void GrammarAnalyzer.buildParserTable() {
    int64 i = 0
    while (i < grammar.parserRules.length) {
        analysis.parserRules.append(ParserRuleFacts(i, grammar.parserRules[
                
                i] as ParserRule))
        i += 1
    }
    i = 0
    while (i < analysis.parserRules.length) {
        ParserRuleFacts facts = ruleAt(i)
        facts.root = record(facts.rule.expression)
        i += 1
    }
}
