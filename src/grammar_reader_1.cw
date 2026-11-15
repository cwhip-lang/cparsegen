/*
 * src/grammar_reader_1.cw — Out-of-line methods for GrammarReader.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarReader methods out of src/grammar.cw.
 */

/*
 * Create a GrammarReader and store the values passed to the constructor.
 *
 * source: source (String). firstLine: first line (int64). path: path
 * (String). shownPath: shown path (String). parent: parent (SourceLocation).
 *
 * Returns the new object.
 */
GrammarReader GrammarReader.GrammarReader(
        
        String source,
        
        int64 firstLine,
        
        String path,
        
        String shownPath,
        

              SourceLocation parent) {
    tokens = []
    position = 0
    classPosition = 0
    problem = ""
    inclusion = null
    sourcePath = path
    sourceFirstLine = firstLine
    problemSpan = null
    diagnosticInfo = null

    GrammarScanner scanner(source, path, shownPath, firstLine, parent)
    while (true) {
        GrammarToken token = scanner.next()
        if (!scanner.problem.equals("")) {
            problem = scanner.problem
            problemSpan = scanner.problemSpan
            diagnosticInfo = GrammarDiagnostic(problem, problemSpan, null)
            return
        }
        tokens.append(token)
        if (token.kind == 0) {
            return
        }
    }

}

/*
 * Return the peek input unit without consuming a later one.
 *
 * Returns the GrammarToken result, or null when the operation fails and this
 * method uses null for that.
 */
GrammarToken GrammarReader.peek() {
    return(tokens[position] as GrammarToken)
}

/*
 * Move past the current input unit and return what take describes.
 *
 * Returns the GrammarToken result, or null when the operation fails and this
 * method uses null for that.
 */
GrammarToken GrammarReader.take() {
    GrammarToken token = peek()
    if (position < tokens.length - 1) {
        position += 1
    }
    return(token)
}

/*
 * Perform fail for GrammarReader.
 *
 * message: message (String). span: span (SourceSpan).
 *
 * Does not return a value.
 */
void GrammarReader.fail(String message, SourceSpan span) {
    problem = message
    problemSpan = span
    diagnosticInfo = GrammarDiagnostic(message, span, null)
}

/*
 * Perform class byte for GrammarReader.
 *
 * token: token (GrammarToken).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 GrammarReader.classByte(GrammarToken token) {
    int64 byte = int64(token.text[classPosition])
    classPosition += 1

    if (byte == 92) {
        byte = int64(token.text[classPosition])
        classPosition += 1
        if (byte == 110) {
            return(10)
        }
        if (byte == 114) {
            return(13)
        }
        if (byte == 116) {
            return(9)
        }
        if (byte != 92 && byte != 93 && byte != 91 && byte != 45 &&
                byte != 94) {
            fail(format(
                    
                    "line {}: unsupported character-class escape",
                    
                    token.line), token.span)
        }
    }

    return(byte)
}

/*
 * Parse a character class into inclusive byte ranges.
 *
 * token: token (GrammarToken).
 *
 * Returns the list built by this method. The list is empty when nothing
 * matched.
 */
list GrammarReader.classRanges(GrammarToken token) {
    String pattern = token.text
    list ranges = []
    classPosition = 1
    bool negated = int64(pattern[1]) == 94
    if (negated) {
        classPosition += 1
    }

    while (classPosition < pattern.length - 1 && problem.equals("")) {

        int64 first = classByte(token)
        int64 last = first
        if (classPosition + 1 < pattern.length - 1 && int64(pattern[
                
                classPosition]) == 45) {
            classPosition += 1
            last = classByte(token)
            if (last < first) {
                fail(format(
                        
                        "line {}: descending character-class range",
                        
                        token.line), token.span)
                return(ranges)
            }
        }

        if (first == 0 || last > 127) {
            fail(format(
                    
                    "line {}: character classes must contain non-NUL ASCII bytes",
                    
                    token.line), token.span)
            return(ranges)
        }
        ranges.append(ByteRange(first, last))
    }

    if (ranges.length == 0) {
        fail(
                format(
                "line {}: empty character class",
                token.line),
                token.span)
    }

    if (negated && problem.equals("")) {

        list complement = []
        int64 byte = 1
        int64 lower = -1
        while (byte <= 127) {
            bool included = false
            int64 r = 0
            while (r < ranges.length) {
                ByteRange interval = ranges[r] as ByteRange
                if (byte >= interval.first && byte <= interval.last) {
                    included = true
                }
                r += 1
            }
            if (!included && lower < 0) {
                lower = byte
            }
            if (included && lower >= 0) {
                complement.append(ByteRange(lower, byte - 1))
                lower = -1
            }
            byte += 1
        }

        if (lower >= 0) {
            complement.append(ByteRange(lower, 127))
        }
        if (complement.length == 0) {
            fail(format(
                    
                    "line {}: character class matches no ASCII bytes",
                    
                    token.line), token.span)
        }
        return(complement)
    }

    return(ranges)
}

/*
 * Perform lexer choice for GrammarReader.
 *
 * line: line (int64). depth: depth (int64).
 *
 * Returns the LexerExpr result.
 */
LexerExpr GrammarReader.lexerChoice(int64 line, int64 depth) {
    LexerExpr expression = LexerExpr(3, line)
    if (depth > 128) {
        fail(format("line {}: lexer group nesting limit exceeded (128)", line),
                peek().span)
        return(expression)
    }
    expression.children.append(lexerSequence(line, depth))
    while (peek().line == line && peek().kind == 124 && problem.equals("")) {
        take()
        expression.children.append(lexerSequence(line, depth))
    }
    if (expression.children.length > 0 &&
        (expression.children[
            
            0] as LexerExpr).span != null) {
        expression.span = (expression.children[0] as LexerExpr).span
        int64 child = expression.children.length - 1
        if (child >= 0 &&
                (expression.children[child] as LexerExpr).span != null) {
            expression.span = SourceSpan(expression.span.first,
                (expression.children[child] as LexerExpr).span.last)
        }
    }
    return(expression)
}
