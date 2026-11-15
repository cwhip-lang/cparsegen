/*
 * examples/visitor/words.cw — Holds Names.
 *
 * Created: 2026-10-20
 * Author: chuck
 *
 * Changelog:
 *   2026-10-20  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "parser.cw"
/*
 * Counts identifiers in a generated word tree and can stop after the first
 * one.
 */
class Names : GeneratedVisitor {
    public:
    int64 count
    bool first
    String problem
    Names(bool stopAfterFirst)

    int64 on_token_IDENT(AstNode node)

    int64 enter_token_IDENT(AstNode node)

    int64 on_rule_words(AstNode node)

}

/*
 * Create a Names and store the values passed to the constructor.
 *
 * stopAfterFirst: stop after first (bool).
 *
 * Returns the new object.
 */
Names Names.Names(bool stopAfterFirst) {
    super GeneratedVisitor()
    count = 0
    first = stopAfterFirst
    problem = ""
}

/*
 * Count an identifier. The spelling forbidden is a visitor error, and the
 * first-only mode stops the walk.
 *
 * node: node (AstNode).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 Names.on_token_IDENT(AstNode node) {
    if (node.lexeme().equals("forbidden")) {
        problem = "identifier 'forbidden' is not allowed"
        return(VISIT_ERROR)
    }
    count += 1
    if (first) {
        return(VISIT_STOP)
    }
    return(VISIT_CONTINUE)
}

/*
 * Forward the token hook to the same identifier check.
 *
 * node: node (AstNode).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 Names.enter_token_IDENT(AstNode node) {
    return(on_token_IDENT(node))
}

/*
 * Visit each child of a words node and stop when a child asks to stop or
 * fail.
 *
 * node: node (AstNode).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 Names.on_rule_words(AstNode node) {
    int64 i = 0
    while (i < node.childCount()) {
        int64 result = dispatch(node.childAt(i))
        if (result != VISIT_CONTINUE) {
            return(result)
        }
        i += 1
    }
    return(VISIT_CONTINUE)
}

start {
    Sys.Process process()
    Sys.StandardIO io()
    bool first = process.argc() == 3 && process.arg(1).equals("--first")
    bool manual = process.argc() == 3 && process.arg(1).equals("--dispatch")
    if (process.argc() != 2 && !first && !manual) {
        io.writeErrorLine("usage: words-visitor [--first | --dispatch] TEXT")
        process.exit(2)
    }
    int64 argument = 1
    if (first || manual) {
        argument = 2
    }
    InputScanner scanner(process.arg(argument))
    if (!scanner.scan()) {
        io.writeErrorLine(scanner.problem)
        process.exit(1)
    }
    GeneratedParser parser(scanner.tokens)
    AstNode root = parser.parseAll()
    if (root == null) {
        io.writeErrorLine(parser.problem)
        process.exit(1)
    }
    Names names(first)
    int64 result = names.VISIT_CONTINUE
    if (manual) {
        result = names.dispatch(root)
    }
    else {
        result = names.walk(root)
    }

    if (result == names.VISIT_CONTINUE || (first &&
            result == names.VISIT_STOP)) {
        String suffix = ""
        if (result == names.VISIT_STOP) {
            suffix = " (stopped)"
        }
        io.writeLine(format("names={}{}", names.count, suffix))
    }
    else {
        if (names.problem.equals("")) {
            names.problem = "visitor failed"
        }
        io.writeErrorLine(names.problem)
        process.exit(1)
    }

}
