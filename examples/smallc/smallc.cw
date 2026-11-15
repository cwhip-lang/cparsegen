/*
 * examples/smallc/smallc.cw — Holds SmallCASTApplication.
 *
 * Created: 2026-10-19
 * Author: chuck
 *
 * Changelog:
 *   2026-10-19  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "smallc_frontend.cw"
/*
 * Command-line driver that prints a SmallC syntax tree, optionally after
 * semantic checks.
 */
class SmallCASTApplication {
    public:
    Sys.StandardIO io
    SmallCASTApplication()

    int64 run()

}

/*
 * Create a SmallCASTApplication and store the values passed to the
 * constructor.
 *
 * Returns the new object.
 */
SmallCASTApplication SmallCASTApplication.SmallCASTApplication() {
    io = Sys.StandardIO()
}

/*
 * Parse argv, check or print one SmallC file, and return the process status.
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 SmallCASTApplication.run() {
    Sys.Process process()
    if (process.argc() == 2 && process.arg(1).equals("--help")) {
        io.writeLine("usage: smallc-ast [--check] INPUT.c")
        io.writeLine(
                
                "Parse SmallC to a JSON syntax AST; --check also validates the supported semantics.")
        return(0)
    }
    bool checking = process.argc() == 3 && process.arg(1).equals("--check")
    if (process.argc() != 2 && !checking) {
        io.writeErrorLine("usage: smallc-ast [--check] INPUT.c")
        return(2)
    }
    String path = process.arg(1)
    if (checking) {
        path = process.arg(2)
    }
    if (!Sys.FileSystem().isFile(path)) {
        io.writeErrorLine(
                format(
                "{}: input must be an existing file",
                path))
        return(1)
    }
    String input = Sys.File(path, "r").readAll()
    SmallCFrontend frontend()
    AstNode root = frontend.parseInput(input)
    if (root == null) {
        frontend.report(path, input, frontend.errorOffset, frontend.problem)
        return(1)
    }
    if (checking && !frontend.check(root)) {
        frontend.report(path, input, frontend.errorOffset, frontend.problem)
        return(1)
    }
    io.writeLine(frontend.jsonAst(root))
    return(0)
}

start {
    SmallCASTApplication application()
    Sys.Process().exit(application.run())
}
