/*
 * src/grammar_reader_2.cw — Out-of-line methods for GrammarReader.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarReader methods out of src/grammar.cw.
 */

/*
 * Perform lexer sequence for GrammarReader.
 *
 * line: line (int64). depth: depth (int64).
 *
 * Returns the LexerExpr result.
 */
LexerExpr GrammarReader.lexerSequence(int64 line, int64 depth) {
    LexerExpr expression = LexerExpr(2, line)
    while (peek().line == line && peek().kind != 0 && peek().kind != 124 &&
           peek().kind != 41 && peek().kind != 59 && problem.equals(
            
            "")) {

        GrammarToken token = take()
        LexerExpr atom = null
        if (token.kind == 258) {
            atom = LexerExpr(0, token.line)
            atom.ranges = classRanges(token)
            atom.span = token.span
        }
        else {

            if (token.kind == 256) {
                atom = LexerExpr(1, token.line)
                atom.value = token.text
                atom.span = token.span
            }
            else {

                if (token.kind == 257) {
                    atom = LexerExpr(2, token.line)
                    atom.span = token.span
                    if (token.text.length == 0) {
                        fail(format(
                                
                                "line {}: empty lexer literal is not supported",
                                
                                token.line), token.span)
                    }

                    int64 b = 0
                    while (b < token.text.length) {
                        int64 byte = int64(token.text[b])
                        if (byte == 0 || byte > 127) {
                            fail(format(
                                    
                                    "line {}: lexer literals must contain non-NUL ASCII bytes",
                                    
                                    token.line), token.span)
                        }
                        LexerExpr character = LexerExpr(0, token.line)
                        character.ranges.append(ByteRange(byte, byte))
                        character.span = token.span
                        atom.children.append(character)
                        b += 1
                    }

                }
                else {

                    if (token.kind == 40) {
                        atom = lexerChoice(line, depth + 1)
                        if (atom.span != null) {
                            atom.span = SourceSpan(token.span.first,
                                    atom.span.last)
                        }
                        if (problem.equals("") && (
                                peek().line != line || peek().kind != 41)) {
                            fail(format(
                                    "line {}: expected ')' after lexer group",
                                            token.line), peek().span)
                        }
                        if (peek().line == line && peek().kind == 41) {
                            GrammarToken closing = take()
                            atom.span = SourceSpan(token.span.first,
                                    closing.span.last)
                        }
                    }
                    else {
                        fail(format(
                                
                                "line {}: unsupported lexer expression syntax (expected class, literal, reference, or group)",
                                
                                
                            token.line), token.span)
                        return(expression)
                    }

                }

            }

        }

        if (peek().line == line && (peek().kind == 42 || peek().kind == 43 ||
                peek().kind == 63)) {
            GrammarToken quantifier = take()
            LexerExpr repeated = LexerExpr(4, quantifier.line)
            repeated.children.append(atom)
            if (atom.span == null) {
                repeated.span = quantifier.span
            }
            else {
                repeated.span = SourceSpan(atom.span.first,
                        quantifier.span.last)
            }
            if (quantifier.kind != 43) {
                repeated.minimum = 0
            }
            if (quantifier.kind != 63) {
                repeated.maximum = -1
            }
            atom = repeated
        }

        expression.children.append(atom)
    }
    if (expression.children.length == 0 && problem.equals("")) {
        fail(
                format("line {}: expected nonempty lexer expression", line),
                peek().span)
    }
    if (expression.children.length > 0 &&
        (expression.children[
            
            0] as LexerExpr).span != null &&
        (expression.children[
            
            expression.children.length - 1] as LexerExpr).span != null) {
        expression.span = SourceSpan(
            (expression.children[0] as LexerExpr).span.first,
            (expression.children[
                    expression.children.length - 1] as LexerExpr).span.last)
    }
    return(expression)
}

/*
 * Perform choice for GrammarReader.
 *
 * Returns the RuleExpr result.
 */
RuleExpr GrammarReader.choice() {
    RuleExpr expression = RuleExpr(3, "", peek().line)
    expression.children.append(sequence())
    while (peek().kind == 124 && problem.equals("")) {
        take()
        expression.children.append(sequence())
    }
    if (expression.children.length > 0 &&
        (expression.children[
            
            0] as RuleExpr).span != null &&
        (expression.children[
            
            expression.children.length - 1] as RuleExpr).span != null) {
        expression.span = SourceSpan(
            (expression.children[0] as RuleExpr).span.first,
            (expression.children[
                    expression.children.length - 1] as RuleExpr).span.last)
    }
    return(expression)
}

/*
 * Perform sequence for GrammarReader.
 *
 * Returns the RuleExpr result.
 */
RuleExpr GrammarReader.sequence() {
    RuleExpr expression = RuleExpr(2, "", peek().line)
    while (peek().kind != 0 && peek().kind != 124 && peek().kind != 41 &&
           peek().kind != 59 && problem.equals(
            
            "")) {

        GrammarToken token = take()
        RuleExpr atom = null
        if (token.kind == 256) {
            atom = RuleExpr(0, token.text, token.line)
            atom.span = token.span
        }
        else {

            if (token.kind == 257) {
                atom = RuleExpr(1, token.text, token.line)
                atom.span = token.span
            }
            else {

                if (token.kind == 40) {
                    atom = choice()
                    GrammarToken closing = take()
                    if (closing.kind != 41) {
                        fail(format(
                                
                                "line {}: expected ')' after parser group",
                                
                                
                            closing.line), closing.span)
                    }
                    atom.span = SourceSpan(token.span.first, closing.span.last)
                }
                else {
                    fail(format(
                            
                            "line {}: unsupported parser-expression syntax",
                            
                            token.line), token.span)
                    return(expression)
                }

            }

        }

        if (peek().kind == 42 || peek().kind == 43 || peek().kind == 63) {
            GrammarToken quantifier = take()
            RuleExpr repeated = RuleExpr(4, "", quantifier.line)
            repeated.children.append(atom)
            if (atom.span == null) {
                repeated.span = quantifier.span
            }
            else {
                repeated.span = SourceSpan(atom.span.first,
                        quantifier.span.last)
            }
            if (quantifier.kind != 43) {
                repeated.minimum = 0
            }
            if (quantifier.kind != 63) {
                repeated.maximum = -1
            }
            atom = repeated
        }

        expression.children.append(atom)
    }
    if (expression.children.length > 0) {
        expression.span = SourceSpan(
            (expression.children[0] as RuleExpr).span.first,
            (expression.children[
                    expression.children.length - 1] as RuleExpr).span.last)
    }
    return(expression)
}

/*
 * Parse tokens into grammar until the end of this file.
 *
 * grammar: grammar (GrammarModel).
 *
 * Does not return a value.
 */
void GrammarReader.readInto(GrammarModel grammar) {
    inclusion = null
    if (!problem.equals("")) {
        return
    }

    while (peek().kind != 0 && problem.equals("")) {
        GrammarToken first = take()
        if (first.kind == 260) {
            grammar.insertions.append(CodeInsertion(
                    
                    first,
                    
                    sourcePath,
                    
                    sourceFirstLine))
            continue
        }

        if (first.kind == 259) {

            if (first.name.equals("include")) {
                inclusion = first
                return
            }
            else {
                GrammarDirective directive(
                        
                        first.name,
                        
                        first.text,
                        
                        first.line)
                directive.span = first.span
                grammar.directives.append(directive)
            }

        }
        else {

            if (first.kind == 256) {

                GrammarToken separator = take()
                if (separator.kind == 61) {
                    LexerRule rule = LexerRule(first.text, first.line)
                    rule.expression = lexerChoice(first.line, 0)
                    rule.span = first.span
                    if (peek().line == first.line && peek().kind == 59) {
                        take()
                    }
                    if (peek().kind != 0 && peek().line == first.line &&
                            problem.equals(
                            
                            "")) {
                        fail(format(
                                "line {}: unexpected token after lexer expression",
                            first.line), peek().span)
                    }
                    grammar.lexerRules.append(rule)
                }
                else {

                    if (separator.kind == 58) {
                        ParserRule rule(first.text, first.line)
                        rule.span = first.span
                        rule.expression = choice()
                        if (problem.equals("") && peek().kind != 59) {
                            fail(format(
                                    "line {}: parser rule must end with ';'",
                                first.line), peek().span)
                        }
                        if (problem.equals("")) {
                            take()
                        }
                        grammar.parserRules.append(rule)
                    }
                    else {
                        fail(format(
                                
                                "line {}: expected '=' or ':' after declaration name",
                                
                                
                            first.line), separator.span)
                    }

                }

            }
            else {
                fail(format(
                        
                        "line {}: expected lexer rule, parser rule, or @directive",
                        
                        
                    first.line), first.span)
            }

        }

    }

}
