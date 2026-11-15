/*
 * examples/smallc/small_c_frontend.cw — Parses SmallC with the generated
 * parser and exposes checking, JSON, and diagnostics.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCFrontend out of examples/smallc/smallc_frontend.cw.
 */

/*
 * Parses SmallC with the generated parser and exposes checking, JSON, and
 * diagnostics.
 */
class SmallCFrontend {
    public:
    Sys.StandardIO io
    list tokens
    String problem
    int64 errorOffset
    SmallCSemanticChecker checker
    SmallCFrontend()

    AstNode parseInput(String input)

    bool check(AstNode root)

    int64 offsetOf(AstNode node)

    String jsonString(String value)

    String jsonAst(AstNode node)

    void report(String path, String input, int64 offset, String problem)

    int64 byteSpanBound(int64 value, int64 length)
    String byteSpan(String text, int64 first, int64 last)

}

/*
 * Create a SmallCFrontend and store the values passed to the constructor.
 *
 * Returns the new object.
 */
SmallCFrontend SmallCFrontend.SmallCFrontend() {
    io = Sys.StandardIO()
    tokens = []
    problem = ""
    errorOffset = 0
    checker = null
}

/*
 * Scan and parse one SmallC translation unit. Returns null and sets problem
 * on failure.
 *
 * input: input (String).
 *
 * Returns the AstNode result, or null when the operation fails and this
 * method uses null for that.
 */
AstNode SmallCFrontend.parseInput(String input) {
    problem = ""
    errorOffset = 0
    InputScanner scanner(input)
    if (!scanner.scan()) {
        problem = scanner.problem
        errorOffset = scanner.errorOffset
        return(null)
    }
    tokens = scanner.tokens
    GeneratedParser parser(scanner.tokens)
    AstNode root = parser.parseAll()
    if (root == null) {
        errorOffset = input.length
        if (parser.errorPosition < scanner.tokens.length) {
            errorOffset = (scanner.tokens[
                    parser.errorPosition] as LexToken).offset
        }
        problem = parser.problem
    }
    return(root)
}

/*
 * Validate the construct and record a problem when it is illegal or
 * unsupported.
 *
 * root: root (AstNode).
 *
 * Returns true on success and false when the operation does not apply or has
 * failed.
 */
bool SmallCFrontend.check(AstNode root) {
    checker = SmallCSemanticChecker()
    if (checker.check(root, tokens)) {
        return(true)
    }
    problem = checker.problem
    errorOffset = checker.errorOffset
    return(false)
}

/*
 * Perform offset of for SmallCFrontend.
 *
 * node: node (AstNode).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 SmallCFrontend.offsetOf(AstNode node) {
    if (checker == null) {
        return(0)
    }
    return(checker.offsetOf(node))
}

/*
 * Perform json string for SmallCFrontend.
 *
 * value: value (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCFrontend.jsonString(String value) {

    String result = "\""
    int64 i = 0
    while (i < value.length) {
        int64 byte = int64(value[i])
        if (byte == 34 || byte == 92) {
            result.append("\\")
        }

        if (byte == 10) {
            result.append("\\n")
        }
        else {

            if (byte == 13) {
                result.append("\\r")
            }
            else {
                if (byte == 9) {
                    result.append("\\t")
                }
                else {
                    result.append(byteSpan(value, i, i + 1))
                }
            }

        }

        i += 1
    }

    result.append("\"")
    return(result)
}

/*
 * Render the AST as one JSON object.
 *
 * node: node (AstNode).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCFrontend.jsonAst(AstNode node) {
    String result = "{\"name\":"
    result.append(jsonString(node.name))
    result.append(",\"text\":")
    result.append(jsonString(node.text))
    result.append(",\"children\":[")
    int64 i = 0
    while (i < node.children.length) {
        if (i > 0) {
            result.append(",")
        }
        result.append(jsonAst(node.children[i] as AstNode))
        i += 1
    }
    result.append("]}")
    return(result)
}

/*
 * Print a path, line, column, and problem for a byte offset in the input.
 *
 * path: path (String). input: input (String). offset: offset (int64).
 * problem: problem (String).
 *
 * Does not return a value.
 */
void SmallCFrontend.report(
        String path,
        String input,
        int64 offset,
        String problem) {
    int64 line = 1
    int64 column = 1
    int64 i = 0
    while (i < offset && i < input.length) {
        if (int64(input[i]) == 10) {
            line += 1
            column = 1
        }
        else {
            column += 1
        }
        i += 1
    }
    io.writeErrorLine(format("{}:{}:{}: {}", path, line, column, problem))
}

/*
 * Clamp a byte index into the half-open range from 0 through length. A
 * negative index counts back from length.
 *
 * value: value (int64). length: length (int64).
 *
 * Returns the clamped index, from 0 through length.
 */
int64 SmallCFrontend.byteSpanBound(int64 value, int64 length) {
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
String SmallCFrontend.byteSpan(String text, int64 first, int64 last) {
    int64 lower = byteSpanBound(first, text.length)
    int64 end = byteSpanBound(last, text.length)
    if (end <= lower) {
        return("")
    }
    return(text[lower..(end - 1)])
}
