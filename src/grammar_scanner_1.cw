/*
 * src/grammar_scanner_1.cw — Out-of-line methods for GrammarScanner.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarScanner methods out of src/grammar.cw while
 *              applying the coding standard.
 */

/*
 * Create a GrammarScanner and store the values passed to the constructor.
 *
 * text: text (String). path: path (String). shownPath: shown path (String).
 * firstLine: first line (int64). parent: parent (SourceLocation).
 *
 * Returns the new object.
 */
GrammarScanner GrammarScanner.GrammarScanner(
        
        String text,
        
        String path,
        
        String shownPath,
        
        int64 firstLine,
        

               SourceLocation parent) {
    source = text
    sourcePath = path
    displayPath = shownPath
    offset = 0
    line = firstLine
    sourceLine = 1
    column = 1
    previousCR = false
    includedFrom = parent
    lastWordSpan = null
    problem = ""
    problemSpan = null
}

/*
 * Return the current input unit without consuming a later one.
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 GrammarScanner.current() {
    if (offset >= source.length) {
        return(-1)
    }
    return(int64(source[offset]))
}

/*
 * Return the following input unit without consuming a later one.
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 GrammarScanner.following() {
    if (offset + 1 >= source.length) {
        return(-1)
    }
    return(int64(source[offset + 1]))
}

/*
 * Move past the current input unit and return what advance describes.
 *
 * Does not return a value.
 */
void GrammarScanner.advance() {

    int64 value = current()
    if (value == 13) {
        line += 1
        sourceLine += 1
        column = 1
        previousCR = true
    }
    else {

        if (value == 10) {
            if (!previousCR) {
                line += 1
                sourceLine += 1
            }
            column = 1
            previousCR = false
        }
        else {
            column += 1
            previousCR = false
        }

    }

    offset += 1
}

/*
 * Perform location for GrammarScanner.
 *
 * Returns the SourceLocation result.
 */
SourceLocation GrammarScanner.location() {
    return(SourceLocation(
            
            sourcePath,
            
            displayPath,
            
            offset,
            
            sourceLine,
            
            column,
            
            
                          line,
            
            includedFrom))
}

/*
 * Copy the half-open byte range from first up to but not including last. An
 * empty or reversed range copies nothing.
 *
 * startOffset: start offset (int64). startLine: start line (int64).
 * startColumn: start column (int64).
 *
 * Returns the copied bytes, or an empty string when the range is empty.
 */
SourceSpan GrammarScanner.byteSpan(
        int64 startOffset,
        int64 startLine,
        int64 startColumn) {
    int64 startLogicalLine = line - (sourceLine - startLine)
    SourceLocation first(
            
            sourcePath,
            
            displayPath,
            
            startOffset,
            
            startLine,
            
            
                         startColumn,
            
            startLogicalLine,
            
            includedFrom)
    return(SourceSpan(first, location()))
}

/*
 * Perform make token for GrammarScanner.
 *
 * kind: kind (int64). text: text (String). name: name (String). startOffset:
 * start offset (int64). startSourceLine: start source line (int64).
 * startColumn: start column (int64). startLogicalLine: start logical line
 * (int64).
 *
 * Returns the GrammarToken result, or null when the operation fails and this
 * method uses null for that.
 */
GrammarToken GrammarScanner.makeToken(
        
        int64 kind,
        
        String text,
        
        String name,
        
        int64 startOffset,
        

                       int64 startSourceLine,
        
        int64 startColumn,
        
        int64 startLogicalLine) {
    GrammarToken token(kind, text, name, startLogicalLine)
    token.span = byteSpan(startOffset, startSourceLine, startColumn)
    return(token)
}

/*
 * Return true when letter holds for the argument, and false otherwise.
 *
 * value: value (int64).
 *
 * Returns true when the condition holds and false otherwise.
 */
bool GrammarScanner.letter(int64 value) {
    return(
            (value >= 65 && value <= 90) || (
            value >= 97 && value <= 122) || value == 95)
}

/*
 * Return true when digit holds for the argument, and false otherwise.
 *
 * value: value (int64).
 *
 * Returns true when the condition holds and false otherwise.
 */
bool GrammarScanner.digit(int64 value) {
    return(value >= 48 && value <= 57)
}

/*
 * Skip whitespace and comments. A comment that never ends sets problem.
 *
 * Does not return a value.
 */
void GrammarScanner.skipTrivia() {

    while (current() >= 0) {

        if (current() <= 32) {
            advance()
        }
        else {

            if (current() == 35 || (current() == 47 && following() == 47)) {
                while (current() >= 0 && current() != 10 && current() != 13) {
                    advance()
                }
            }
            else {

                if (current() == 47 && following() == 42) {
                    int64 startLine = line
                    int64 startSourceLine = sourceLine
                    int64 startColumn = column
                    int64 startOffset = offset
                    advance()
                    advance()
                    while (current() >= 0 && !(
                            current() == 42 && following() == 47)) {
                        advance()
                    }
                    if (current() < 0) {
                        problem = format("line {}: unterminated block comment",
                                startLine)
                        problemSpan = byteSpan(startOffset, startSourceLine,
                                startColumn)
                        return
                    }
                    advance()
                    advance()
                }
                else {
                    return
                }

            }

        }

    }

}

/*
 * Perform insertion word for GrammarScanner.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarScanner.insertionWord() {
    while (current() == 32 || current() == 9 || current() == 10 ||
            current() == 13) {
        advance()
    }
    int64 startIndex = offset
    int64 startSourceLine = sourceLine
    int64 startColumn = column
    int64 startLogicalLine = line
    if (letter(current())) {
        while (letter(current()) || digit(current())) {
            advance()
        }
    }
    lastWordSpan = byteSpan(startIndex, startSourceLine, startColumn)
    lastWordSpan.first.logicalLine = startLogicalLine
    return(byteSpan(source, startIndex, offset))
}
