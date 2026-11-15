/*
 * src/grammar_scanner_2.cw — Out-of-line methods for GrammarScanner.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarScanner methods out of src/grammar.cw while
 *              applying the coding standard.
 */

/*
 * Read one @insert body, respecting strings, comments, and nested braces.
 *
 * startLine: start line (int64).
 *
 * Returns the GrammarToken result, or null when the operation fails and this
 * method uses null for that.
 */
GrammarToken GrammarScanner.insertion(int64 startLine) {
    int64 startOffset = offset - 1
    int64 startSourceLine = sourceLine
    int64 startColumn = column - 1
    int64 startLogicalLine = startLine
    GrammarToken token(260, "", "insert", startLine)
    token.target = insertionWord()
    token.targetSpan = lastWordSpan
    token.boundary = insertionWord()
    token.boundarySpan = lastWordSpan
    while (current() == 32 || current() == 9 || current() == 10 ||
            current() == 13) {
        advance()
    }
    if (token.target.equals("") || token.boundary.equals("") ||
            current() != 123) {
        problem = format(
                "line {}: @insert requires TARGET BOUNDARY {{ code }};",
                        startLine)
        return(token)
    }
    advance()
    int64 startIndex = offset
    int64 depth = 1
    // State: code, quote byte, line comment ('/'), or block comment ('*').

    int64 state = 0
    int64 stateLine = line
    int64 stateSourceLine = sourceLine
    int64 stateColumn = column
    int64 stateOffset = offset
    bool escaped = false
    while (current() >= 0) {
        int64 value = current()
        int64 size = offset - startIndex
        if (size > 1048576 || (size == 1048576 && !(
                
                value == 125 && state == 0 && depth == 1))) {
            problem = format("line {}: @insert block exceeds 1048576 bytes",
                    startLine)
            problemSpan = byteSpan(offset, sourceLine, column)
            return(token)
        }
        // C translation-phase rewriting would change delimiter recognition.
        if (value == 0 || (value == 92 && (following() == 10 ||
                following() == 13)) ||
            (value == 63 && following() == 63)) {
            problem = format(
                    "line {}: @insert forbids NUL, backslash-newline and trigraph prefixes", line)
            problemSpan = byteSpan(offset, sourceLine, column)
            return(token)
        }

        if (state == 34 || state == 39) {
            if (value == 10 || value == 13) {
                problem = format("line {}: unterminated @insert quoted literal",
                        stateLine)
                problemSpan = byteSpan(stateOffset, stateSourceLine,
                        stateColumn)
                return(token)
            }

            if (escaped) {
                escaped = false
            }
            else {
                if (value == state) {
                    state = 0
                }
                else {
                    if (value == 92) {
                        escaped = true
                    }
                }
            }

        }
        else {

            if (state == 47) {
                if (value == 10 || value == 13) {
                    state = 0
                }
            }
            else {

                if (state == 42) {
                    if (value == 42 && following() == 47) {
                        advance()
                        state = 0
                    }
                }
                else {

                    if (value == 34 || value == 39) {
                        state = value
                        stateLine = line
                        stateSourceLine = sourceLine
                        stateColumn = column
                        stateOffset = offset
                    }
                    else {

                        if (value == 47 && (
                                following() == 47 || following() == 42)) {
                            state = following()
                            stateLine = line
                            stateSourceLine = sourceLine
                            stateColumn = column
                            stateOffset = offset
                            advance()
                        }
                        else {
                            if (value == 123) {
                                depth += 1
                                if (depth > 256) {
                                    problem = format(
                                            "line {}: @insert brace nesting exceeds 256", line)
                                    problemSpan = byteSpan(offset, sourceLine,
                                            column)
                                    return(token)
                                }
                            }
                            if (value == 125) {
                                depth -= 1
                                if (depth == 0) {
                                    break
                                }
                            }
                        }

                    }

                }

            }

        }

        advance()
    }

    if (current() < 0) {

        if (state == 34 || state == 39) {
            problem = format("line {}: unterminated @insert quoted literal",
                    stateLine)
            problemSpan = byteSpan(stateOffset, stateSourceLine, stateColumn)
        }
        else {
            if (state == 42) {
                problem = format("line {}: unterminated @insert block comment",
                        stateLine)
                problemSpan = byteSpan(stateOffset, stateSourceLine,
                        stateColumn)
            }
            else {
                problem = format("line {}: unterminated @insert block",
                        startLine)
                problemSpan = byteSpan(startOffset, startSourceLine,
                        startColumn)
            }
        }

        return(token)
    }

    token.text = byteSpan(source, startIndex, offset)
    advance()
    skipTrivia()
    if (problem.equals("") && current() != 59) {
        problem = format("line {}: @insert block must end with ';'", startLine)
        problemSpan = byteSpan(offset, sourceLine, column)
    }
    if (problem.equals("")) {
        advance()
    }
    token.span = byteSpan(startOffset, startSourceLine, startColumn)
    if (!problem.equals("") && problemSpan == null) {
        problemSpan = token.span
    }
    return(token)
}
