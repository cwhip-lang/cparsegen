/*
 * src/grammar_analyzer_2.cw — Out-of-line methods for GrammarAnalyzer.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarAnalyzer methods out of src/analysis.cw while
 *              applying the coding standard.
 */

/*
 * Perform lexical directives for GrammarAnalyzer.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.lexicalDirectives() {

    LexicalConfig lexical = analysis.lexical
    int64 i = 0
    while (i < grammar.directives.length) {

        GrammarDirective directive = grammar.directives[i] as GrammarDirective
        list words = directiveWords(directive.content)
        if (directive.name.equals("quoted")) {
            if (words.length != 2) {
                return(fail("directives", format(
                        
                        "line {}: @quoted requires TOKEN single|double",
                        
                        
                    directive.line), directive.span, null))
            }
            String style = words[1] as String
            if (!style.equals("single") && !style.equals("double")) {
                return(fail("directives", format(
                        
                        "line {}: @quoted requires single or double",
                        
                        
                    directive.line), directive.span, null))
            }
            LexerRule rule = LexerRule(words[0] as String, directive.line)
            rule.quote = 34
            if (style.equals("single")) {
                rule.quote = 39
            }
            rule.span = directive.span
            addLexer(rule)
        }

        if (directive.name.equals("keywords")) {
            if (words.length != 1 || !lexical.keywordToken.equals("")) {
                return(fail("directives", format(
                        
                        "line {}: @keywords requires one identifier token and may occur only once",
                        
                        
                    directive.line), directive.span, null))
            }
            lexical.keywordToken = words[0] as String
            lexical.keywordSpan = directive.span
        }

        if (directive.name.equals("reserved")) {
            lexical.reservedSpan = directive.span
            if (words.length == 0) {
                return(fail("directives", format(
                        
                        "line {}: @reserved requires word names",
                        
                        
                    directive.line), directive.span, null))
            }

            int64 w = 0
            while (w < words.length) {
                if (!identifier(words[w] as String)) {
                    return(fail("directives", format(
                            
                            "line {}: @reserved requires identifier spellings",
                            
                            
                        directive.line), directive.span, null))
                }
                lexical.reserved.append(words[w])
                w += 1
            }

        }

        if (directive.name.equals("line_comment")) {
            if (words.length != 1 || (words[0] as String).length == 0) {
                return(fail("directives", format(
                        
                        "line {}: @line_comment requires one nonempty marker",
                        
                        
                    directive.line), directive.span, null))
            }
            lexical.lineComments.append(words[0])
        }

        if (directive.name.equals("block_comment")) {
            if (words.length != 2) {
                return(fail("directives", format(
                        
                        "line {}: @block_comment requires opening and closing markers",
                        
                        
                    directive.line), directive.span, null))
            }
            lexical.blockComments.append(words)
        }

        i += 1
    }

    if (!lexical.keywordToken.equals("")) {

        int64 token = analysis.lexerIndex(lexical.keywordToken)
        if (token < 0 || (analysis.lexers[token] as LexerPlan).quote != 0) {
            return(fail(
                    
                    "directives",
                    
                    "@keywords must name a declared expression lexer token",
                    
                    
                        lexical.keywordSpan,
                    
                    null))
        }

    }

    if (lexical.reserved.length > 0 && lexical.keywordToken.equals("")) {
        return(fail(
                
                "directives",
                
                "@reserved requires @keywords to identify the identifier token",
                
                
                    lexical.reservedSpan,
                
                null))
    }

    return("")
}

/*
 * Validate lexer names and record a problem when it is illegal or
 * unsupported.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.checkLexerNames() {
    list names = []
    int64 i = 0
    while (i < analysis.lexers.length) {
        names.append((analysis.lexers[i] as LexerPlan).name)
        i += 1
    }
    i = 0

    while (i < analysis.lexers.length) {
        LexerPlan plan = analysis.lexers[i] as LexerPlan
        int64 first = int64(plan.name[0])
        if (first < 65 || first > 90 || !identifier(plan.name)) {
            return(fail("lexer", format(
                    
                    "line {}: lexer names must begin with an uppercase letter",
                    
                    
                plan.line), plan.span, null))
        }

        if (analysis.nameCount(names, plan.name) > 1) {
            SourceSpan previous = null
            int64 p = 0
            while (p < i && previous == null) {
                LexerPlan candidate = analysis.lexers[p] as LexerPlan
                if (candidate.name.equals(plan.name)) {
                    previous = candidate.span
                }
                p += 1
            }
            if (previous != null) {
                return(fail("lexer", format(
                        
                        "line {}: duplicate lexer rule {}",
                        
                        plan.line,
                        
                        
                    plan.name), plan.span, previous))
            }
        }

        i += 1
    }

    return("")
}

/*
 * Perform resolve lexer for GrammarAnalyzer.
 *
 * owner: owner (LexerPlan). expression: expression (LexerExpr). depth: depth
 * (int64).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.resolveLexer(
        LexerPlan owner,
        LexerExpr expression,
        int64 depth) {
    if (depth > 128) {
        return(fail("lexer", format(
                
                "line {}: lexer expression nesting/reference limit exceeded (128)",
                
                
            expression.line), expression.span, null))
    }

    if (expression.kind == 1) {
        int64 index = analysis.lexerIndex(expression.value)
        if (index < 0) {
            return(fail("lexer", format(
                    
                    "line {}: unknown lexer reference {}",
                    
                    expression.line,
                    
                    
                expression.value), expression.span, null))
        }
        LexerPlan target = analysis.lexers[index] as LexerPlan
        if (target.quote != 0) {
            return(fail("lexer", format(
                    
                    "line {}: cannot compose @quoted token {}",
                    
                    
                expression.line,
                    
                    target.name), expression.span, target.span))
        }
        if (target.color == 1) {
            return(fail("lexer", format(
                    
                    "line {}: cyclic lexer reference {}",
                    
                    
                expression.line,
                    
                    target.name), expression.span, target.span))
        }
        if (target.color == 0) {
            target.color = 1
            String error = resolveLexer(target, target.rule.expression,
                    depth + 1)
            if (!error.equals("")) {
                return(error)
            }
            target.nullable = lastNullable
            target.color = 2
        }
        owner.references.append(ResolvedReference(
                
                0,
                
                target.name,
                
                owner.index,
                
                index,
                
                
            expression.line,
                
                expression.span,
                
                target.span))
        lastNullable = target.nullable
        return("")
    }

    bool nullable = expression.kind == 2 || (expression.kind == 4 &&
            expression.minimum == 0)
    int64 c = 0
    while (c < expression.children.length) {
        LexerExpr child = expression.children[c] as LexerExpr
        String error = resolveLexer(owner, child, depth + 1)
        if (!error.equals("")) {
            return(error)
        }
        bool childNullable = lastNullable
        if (expression.kind == 2 && !childNullable) {
            nullable = false
        }
        if (expression.kind == 3 && childNullable) {
            nullable = true
        }
        if (expression.kind == 4 && childNullable) {
            return(fail("lexer", format(
                    
                    "line {}: nullable lexer repetition is not supported",
                    
                    
                expression.line), expression.span, null))
        }
        c += 1
    }

    lastNullable = nullable
    return("")
}

/*
 * Perform lexer state for GrammarAnalyzer.
 *
 * kind: kind (int64). ranges: ranges (list). next: next (int64). alternate:
 * alternate (int64). line: line (int64). span: span (SourceSpan).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 GrammarAnalyzer.lexerState(
        
        int64 kind,
        
        list ranges,
        
        int64 next,
        
        int64 alternate,
        
        int64 line,
        
        SourceSpan span) {
    if (analysis.lexerStates.length >= 4096) {
        lexerProblem = format(
                "line {}: expanded lexer state limit exceeded (4096)", line)
        lexerProblemSpan = span
        return(-1)
    }
    int64 index = analysis.lexerStates.length
    analysis.lexerStates.append(LexerState(kind, ranges, next, alternate))
    return(index)
}
