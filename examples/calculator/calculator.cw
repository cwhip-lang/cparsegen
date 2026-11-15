/*
 * examples/calculator/calculator.cw — Holds Variable, Calculator.
 *
 * Created: 2026-10-19
 * Author: chuck
 *
 * Changelog:
 *   2026-10-19  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "parser.cw"
/*
 * One named numeric binding in the calculator session.
 */
class Variable {
    public:
    String name
    fp64 value
    Variable(String variableName, fp64 number)

}

/*
 * Create a Variable and store the values passed to the constructor.
 *
 * variableName: variable name (String). number: number (fp64).
 *
 * Returns the new object.
 */
Variable Variable.Variable(String variableName, fp64 number) {
    name = variableName
    value = number
}

/*
 * Evaluates calculator statements and owns the session variables and the
 * console.
 */
class Calculator {
    public:
    list variables
    String problem
    Sys.StandardIO io
    bool endOfInput
    Calculator()

    AstNode child(AstNode node, int64 index)

    Variable findVariable(String name)

    fp64 evaluate(AstNode node)

    bool execute(String text)

    void listVariables()

    String readInputLine()

    int64 run()

}

/*
 * Create a Calculator and store the values passed to the constructor.
 *
 * Returns the new object.
 */
Calculator Calculator.Calculator() {
    variables = []
    problem = ""
    io = Sys.StandardIO()
    endOfInput = false
}

/*
 * Return the child at index as an AstNode.
 *
 * node: node (AstNode). index: index (int64).
 *
 * Returns the AstNode result, or null when the operation fails and this
 * method uses null for that.
 */
AstNode Calculator.child(AstNode node, int64 index) {
    return(node.children[index] as AstNode)
}

/*
 * Return the session variable with this name, or null when it has not been
 * assigned.
 *
 * name: name (String).
 *
 * Returns the Variable result.
 */
Variable Calculator.findVariable(String name) {
    int64 i = 0
    while (i < variables.length) {
        Variable variable = variables[i] as Variable
        if (variable.name.equals(name)) {
            return(variable)
        }
        i += 1
    }
    return(null)
}

/*
 * Evaluate one expression node, using the session variables and writing any
 * failure into problem.
 *
 * node: node (AstNode).
 *
 * Returns the fp64 result.
 */
fp64 Calculator.evaluate(AstNode node) {
    if (!problem.equals("")) {
        return(0.0)
    }
    if (node.name.equals("number")) {
        String spelling = ""
        int64 i = 0
        while (i < node.children.length) {
            spelling.append(child(node, i).text)
            i += 1
        }
        return(spelling.toFp64())
    }
    if (node.name.equals("IDENT")) {
        Variable variable = findVariable(node.text)
        if (variable == null) {
            problem = format("undefined variable '{}'", node.text)
            return(0.0)
        }
        return(variable.value)
    }
    if (node.name.equals("primary")) {
        if (node.children.length == 3) {
            return(evaluate(child(node, 1)))
        }
        return(evaluate(child(node, 0)))
    }
    if (node.name.equals("unary")) {
        if (node.children.length == 1) {
            return(evaluate(child(node, 0)))
        }
        fp64 value = evaluate(child(node, 1))
        if (child(node, 0).text.equals("-")) {
            return(-value)
        }
        return(value)
    }

    if (node.name.equals("expression") || node.name.equals("product")) {

        fp64 result = evaluate(child(node, 0))
        int64 i = 1
        while (i < node.children.length && problem.equals("")) {
            String operation = child(node, i).text
            fp64 value = evaluate(child(node, i + 1))
            if (!problem.equals("")) {
                return(0.0)
            }

            if (operation.equals("+")) {
                result += value
            }
            else {

                if (operation.equals("-")) {
                    result -= value
                }
                else {
                    if (operation.equals("*")) {
                        result *= value
                    }
                    else {
                        if (value == 0.0) {
                            problem = "division by zero"
                            return(0.0)
                        }
                        result /= value
                    }
                }

            }

            i += 2
        }

        return(result)
    }

    problem = format("unexpected AST node '{}'", node.name)
    return(0.0)
}

/*
 * Parse and evaluate one input line. Returns false when the line is a quit
 * command.
 *
 * text: text (String).
 *
 * Returns true on success and false when the operation does not apply or has
 * failed.
 */
bool Calculator.execute(String text) {
    problem = ""
    InputScanner scanner(text)
    if (!scanner.scan()) {
        problem = scanner.problem
        return(false)
    }
    GeneratedParser parser(scanner.tokens)
    AstNode statement = parser.parseAll()
    if (statement == null) {
        problem = parser.problem
        return(false)
    }
    bool assignment = statement.children.length == 3
    int64 expressionIndex = 0
    if (assignment) {
        expressionIndex = 2
    }
    fp64 value = evaluate(child(statement, expressionIndex))
    if (!problem.equals("")) {
        return(false)
    }

    if (assignment) {
        String name = child(statement, 0).text
        Variable variable = findVariable(name)
        if (variable == null) {
            variables.append(Variable(name, value))
        }
        else {
            variable.value = value
        }
        io.writeLine(format("{} = {}", name, value))
    }
    else {
        io.writeLine(format("{}", value))
    }

    return(true)
}

/*
 * Print every variable currently stored in the session.
 *
 * Does not return a value.
 */
void Calculator.listVariables() {
    int64 i = 0
    while (i < variables.length) {
        Variable variable = variables[i] as Variable
        io.writeLine(format("{} = {}", variable.name, variable.value))
        i += 1
    }
}

/*
 * Read one console line. A blank read is end of input because the runtime
 * cannot report EOF separately.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String Calculator.readInputLine() {
    // StandardIO.readLine() cannot distinguish a blank line from EOF.

    String line = ""
    while (!endOfInput) {
        String byte = io.read(1)
        if (byte == null || byte.length == 0) {
            endOfInput = true
            break
        }
        if (byte.equals("\n")) {
            break
        }
        line.append(byte)
    }

    return(line)
}

/*
 * Run the calculator CLI: batch, one file, or an interactive session.
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 Calculator.run() {
    Sys.Process process()
    if (process.argc() == 3 && process.arg(1).equals("-e")) {
        if (execute(process.arg(2))) {
            return(0)
        }
        io.writeErrorLine(format("error: {}", problem))
        return(1)
    }
    bool batch = process.argc() == 2 && process.arg(1).equals("--batch")
    if (process.argc() == 2 && process.arg(1).equals("--help")) {
        io.writeLine("usage: calculator [-e EXPRESSION | --batch | --help]")
        io.writeLine(
                
                "Without arguments: interactive CLI. Commands: :help, :vars, :quit")
        return(0)
    }
    if (process.argc() != 1 && !batch) {
        io.writeErrorLine(
                
                "usage: calculator [-e EXPRESSION | --batch | --help]")
        return(2)
    }
    if (!batch) {
        io.writeLine("Calculator: :help for help, :quit to exit.")
    }

    int64 status = 0
    while (true) {
        if (!batch) {
            io.write("calc> ")
        }
        String input = readInputLine()
        if (endOfInput && input.length == 0) {
            break
        }
        String line = input.trim()
        if (line.equals(":quit")) {
            break
        }

        if (line.equals(":help")) {
            io.writeLine(
                    
                    "Numbers, variables, =, +, -, *, /, parentheses. One statement per line.")
            io.writeLine(
                    
                    ":vars lists variables; :quit exits. Example: x = 2 + 3 * 4")
        }
        else {
            if (line.equals(":vars")) {
                listVariables()
            }
            else {
                if (line.length > 0 && !execute(line)) {
                    io.writeErrorLine(format("error: {}", problem))
                    status = 1
                }
            }
        }

    }

    return(status)
}

start {
    Calculator calculator()
    Sys.Process().exit(calculator.run())
}
