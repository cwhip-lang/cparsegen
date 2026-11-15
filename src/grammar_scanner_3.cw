/*
 * src/grammar_scanner_3.cw — Out-of-line methods for GrammarScanner.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarScanner methods out of src/grammar.cw while
 *              applying the coding standard.
 */

/*
 * Return the next grammar token, or a token whose kind reports end of file
 * or a scan error.
 *
 * Returns the GrammarToken result, or null when the operation fails and this
 * method uses null for that.
 */
GrammarToken GrammarScanner.next() {
    skipTrivia()
    if (!problem.equals("")) {
        GrammarToken failed(0, "", "", line)
        failed.span = problemSpan
        return(failed)
    }

    int64 startLine = line
    int64 startSourceLine = sourceLine
    int64 startColumn = column
    int64 startOffset = offset
    int64 value = current()
    if (value < 0) {
        return(makeToken(
                
                0,
                
                "",
                
                "",
                
                startOffset,
                
                startSourceLine,
                
                startColumn,
                
                startLine))
    }

    if (letter(value)) {
        int64 startIndex = offset
        while (letter(current()) || digit(current())) {
            advance()
        }
        return(makeToken(
                256,
                byteSpan(
                source,
                startIndex,
                offset),
                "",
                startOffset,
                
                         startSourceLine,
                startColumn,
                startLine))
    }

    if (value == 34 || value == 39) {
        int64 quote = value
        advance()

        String literal = ""
        int64 literalStart = offset
        while (current() >= 0 && current() != quote && current() != 10) {

            if (current() == 92) {
                int64 escapeOffset = offset
                int64 escapeSourceLine = sourceLine
                int64 escapeColumn = column
                literal.append(byteSpan(source, literalStart, offset))
                advance()

                int64 escaped = current()
                if (escaped == 110) {
                    literal.append("\n")
                }
                else {

                    if (escaped == 114) {
                        literal.append("\r")
                    }
                    else {

                        if (escaped == 116) {
                            literal.append("\t")
                        }
                        else {

                            if (escaped != 92 && escaped != 34 &&
                                    escaped != 39) {
                                problem = format(
                                        "line {}: unsupported quoted escape",
                                                startLine)
                                if (current() >= 0) {
                                    advance()
                                }
                                GrammarToken failed = makeToken(0, "", "",
                                        startOffset,
                                    startSourceLine, startColumn, startLine)
                                problemSpan = byteSpan(escapeOffset,
                                        escapeSourceLine,
                                                   escapeColumn)
                                failed.span = problemSpan
                                return(failed)
                            }

                            literal.append(byteSpan(
                                    
                                    source,
                                    
                                    offset,
                                    
                                    offset + 1))
                        }

                    }

                }

                literalStart = offset + 1
            }

            advance()
        }

        if (current() != quote) {
            problem = format("line {}: unterminated quoted literal", startLine)
            GrammarToken failed = makeToken(0, "", "", startOffset,
                startSourceLine, startColumn, startLine)
            problemSpan = failed.span
            return(failed)
        }
        literal.append(byteSpan(source, literalStart, offset))
        advance()
        return(makeToken(
                
                257,
                
                literal,
                
                "",
                
                startOffset,
                
                startSourceLine,
                
                
                         startColumn,
                
                startLine))
    }

    if (value == 91) {
        int64 startIndex = offset
        advance()
        while (current() >= 0 && current() != 93 && current() != 10) {
            if (current() == 92) {
                advance()
                if (current() < 0 || current() == 10) {
                    break
                }
            }
            advance()
        }
        if (current() != 93) {
            problem = format("line {}: unterminated character class", startLine)
            GrammarToken failed = makeToken(0, "", "", startOffset,
                startSourceLine, startColumn, startLine)
            problemSpan = failed.span
            return(failed)
        }
        advance()
        return(makeToken(
                258,
                byteSpan(
                source,
                startIndex,
                offset),
                "",
                startOffset,
                
                         startSourceLine,
                startColumn,
                startLine))
    }

    if (value == 64) {
        advance()
        if (!letter(current())) {
            problem = format("line {}: expected directive name after @",
                    startLine)
            GrammarToken failed = makeToken(0, "", "", startOffset,
                startSourceLine, startColumn, startLine)
            problemSpan = failed.span
            return(failed)
        }
        int64 nameStart = offset
        while (letter(current()) || digit(current())) {
            advance()
        }
        String directiveName = byteSpan(source, nameStart, offset)
        if (directiveName.equals("insert")) {
            GrammarToken token = insertion(startLine)
            if (token.span == null) {
                token.span = byteSpan(startOffset, startSourceLine, startColumn)
            }
            if (!problem.equals("") && problemSpan == null) {
                problemSpan = token.span
            }
            return(token)
        }
        while (current() == 32 || current() == 9) {
            advance()
        }
        int64 contentStart = offset
        // Only @include interprets quotes; other directive payloads stay
        // opaque.

        int64 includeQuote = 0
        while (current() >= 0 && (current() != 59 || includeQuote != 0)) {

            if (directiveName.equals("include")) {
                if ((current() == 10 || current() == 13) && includeQuote != 0) {
                    break
                }
                if (current() == includeQuote) {
                    includeQuote = 0
                }
                else {
                    if (includeQuote == 0 && (
                            current() == 34 || current() == 39)) {
                        includeQuote = current()
                    }
                }
            }

            advance()
        }

        if (current() != 59) {
            problem = format("line {}: directive @{} must end with ';'",
                    startLine, directiveName)
            GrammarToken failed = makeToken(0, "", "", startOffset,
                startSourceLine, startColumn, startLine)
            problemSpan = failed.span
            return(failed)
        }
        String content = byteSpan(source, contentStart, offset).trim()
        advance()
        return(makeToken(
                
                259,
                
                content,
                
                directiveName,
                
                startOffset,
                
                
                         startSourceLine,
                
                startColumn,
                
                startLine))
    }

    if (value > 127) {
        problem = format("line {}: unsupported non-ASCII grammar syntax",
                startLine)
        GrammarToken failed = makeToken(0, "", "", startOffset,
            startSourceLine, startColumn, startLine)
        problemSpan = failed.span
        return(failed)
    }
    advance()
    return(makeToken(
            value,
            byteSpan(
            source,
            offset - 1,
            offset),
            "",
            startOffset,
            
                     startSourceLine,
            startColumn,
            startLine))
}

/*
 * Clamp a byte index into the half-open range from 0 through length. A
 * negative index counts back from length.
 *
 * value: value (int64). length: length (int64).
 *
 * Returns the clamped index, from 0 through length.
 */
int64 GrammarScanner.byteSpanBound(int64 value, int64 length) {
    int64 index = value
    if (index < 0) {
        index = index + length
    }
    if (index < 0) {
        return(0)
    }
    if (index > length) {
        return(length)
    }
    return(index)
}

/*
 * Copy the half-open byte range from first up to but not including last. An
 * empty or reversed range copies nothing.
 *
 * text: text (String). first: first (int64). last: last (int64).
 *
 * Returns the copied bytes, or an empty string when the range is empty.
 */
String GrammarScanner.byteSpan(String text, int64 first, int64 last) {
    int64 lower = byteSpanBound(first, text.length)
    int64 end = byteSpanBound(last, text.length)
    if (end <= lower) {
        return("")
    }
    return(text[lower..(end - 1)])
}
