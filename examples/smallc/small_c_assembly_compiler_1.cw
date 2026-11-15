/*
 * examples/smallc/small_c_assembly_compiler_1.cw — Out-of-line methods for
 * SmallCAssemblyCompiler.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCAssemblyCompiler methods out of
 *              examples/smallc/smallc_backend.cw.
 */

/*
 * Create a SmallCAssemblyCompiler and store the values passed to the
 * constructor.
 *
 * Returns the new object.
 */
SmallCAssemblyCompiler SmallCAssemblyCompiler.SmallCAssemblyCompiler() {
    functions = []
    globals = []
    arrays = []
    globalInitializers = []
    entryFunction = null
    currentFunction = null
    code = null
    scope = null
    loop = null
    frontend = null
    intrinsics = SmallCIntrinsics()
    problem = ""
    errorNode = null
    scalarGlobalCount = 0
    functionText = ""
}

/*
 * Return the child at index as an AstNode.
 *
 * node: node (AstNode). index: index (int64).
 *
 * Returns the AstNode result, or null when the operation fails and this
 * method uses null for that.
 */
AstNode SmallCAssemblyCompiler.child(AstNode node, int64 index) {
    return(node.children[index] as AstNode)
}

/*
 * Perform fail for SmallCAssemblyCompiler.
 *
 * node: node (AstNode). message: message (String).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.fail(AstNode node, String message) {
    if (problem.equals("")) {
        problem = message
        errorNode = node
    }
}

/*
 * Perform element type for SmallCAssemblyCompiler.
 *
 * valueType: value type (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.elementType(String valueType) {
    if (valueType.equals("int[]")) {
        return("int")
    }
    if (valueType.equals("char[]")) {
        return("char")
    }
    return(valueType)
}

/*
 * Perform asm type for SmallCAssemblyCompiler.
 *
 * valueType: value type (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.asmType(String valueType) {
    if (valueType.equals("int") || valueType.equals("int[]")) {
        return("i32")
    }
    if (valueType.equals("char") || valueType.equals("char[]")) {
        return("u8")
    }
    return("void")
}

/*
 * Return the matching function, or null when nothing matches.
 *
 * name: name (String).
 *
 * Returns the SmallCAsmFunction result, or null when the operation fails and
 * this method uses null for that.
 */
SmallCAsmFunction SmallCAssemblyCompiler.findFunction(String name) {
    int64 i = 0
    while (i < functions.length) {
        SmallCAsmFunction function = functions[i] as SmallCAsmFunction
        if (function.name.equals(name)) {
            return(function)
        }
        i += 1
    }
    return(null)
}

/*
 * Return the matching global, or null when nothing matches.
 *
 * name: name (String).
 *
 * Returns the SmallCAsmVariable result, or null when the operation fails and
 * this method uses null for that.
 */
SmallCAsmVariable SmallCAssemblyCompiler.findGlobal(String name) {
    int64 i = 0
    while (i < globals.length) {
        SmallCAsmVariable variable = globals[i] as SmallCAsmVariable
        if (variable.name.equals(name)) {
            return(variable)
        }
        i += 1
    }
    return(null)
}

/*
 * Return the matching variable, or null when nothing matches.
 *
 * name: name (String).
 *
 * Returns the SmallCAsmVariable result, or null when the operation fails and
 * this method uses null for that.
 */
SmallCAsmVariable SmallCAssemblyCompiler.findVariable(String name) {

    SmallCAsmScope current = scope
    while (current != null) {
        int64 i = current.variables.length - 1
        while (i >= 0) {
            SmallCAsmVariable variable = current.variables[
                    i] as SmallCAsmVariable
            if (variable.name.equals(name)) {
                return(variable)
            }
            i -= 1
        }
        current = current.parent
    }

    return(findGlobal(name))
}

/*
 * Open a nested scope for the block about to be compiled or checked.
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.pushScope() {
    scope = SmallCAsmScope(scope)
}

/*
 * Close the current scope and restore the one that enclosed it.
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.popScope() {
    if (scope != null) {
        scope = scope.parent
    }
}

/*
 * Perform slot count for SmallCAssemblyCompiler.
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 SmallCAssemblyCompiler.slotCount() {
    return(
            
            currentFunction.parameterTypes.length + currentFunction.localCount)
}

/*
 * Declares a scalar local in the current function and returns its symbol.
 *
 * name: name (String). valueType: value type (String). prefix: prefix
 * (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.declareLocal(
        String name,
        String valueType,
        String prefix) {
    int64 slot = slotCount()
    String symbol = format("{}{}", prefix, slot)
    if (!name.equals("")) {
        symbol = format("{}{}_{}", prefix, slot, name)
    }
    currentFunction.localCount += 1
    currentFunction.declarations.append(
        format("    .local {}: {}\n", symbol, asmType(
            
            valueType)))
    return(symbol)
}

/*
 * Perform add local for SmallCAssemblyCompiler.
 *
 * name: name (String). valueType: value type (String).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.addLocal(String name, String valueType) {
    String symbol = declareLocal(name, valueType, "v")
    scope.variables.append(SmallCAsmVariable(
            
            name,
            
            valueType,
            
            false,
            
            false,
            
            0,
            
            symbol))
}

/*
 * Perform add temporary for SmallCAssemblyCompiler.
 *
 * valueType: value type (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.addTemporary(String valueType) {
    return(declareLocal("", valueType, "t"))
}

/*
 * Perform integer value for SmallCAssemblyCompiler.
 *
 * spelling: spelling (String). limit: limit (int64). node: node (AstNode).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 SmallCAssemblyCompiler.integerValue(
        String spelling,
        int64 limit,
        AstNode node) {

    int64 value = 0
    int64 i = 0
    while (i < spelling.length && problem.equals("")) {
        int64 digit = int64(spelling[i]) - 48
        if (digit < 0 || digit > 9 || value > (limit - digit) / 10) {
            fail(node, format(
                    
                    "integer literal '{}' is outside the CVM i32 range",
                    
                    spelling))
            return(0)
        }
        value = value * 10 + digit
        i += 1
    }

    return(value)
}

/*
 * Return true when is minimum integer literal holds for the argument, and
 * false otherwise.
 *
 * spelling: spelling (String).
 *
 * Returns true when the condition holds and false otherwise.
 */
bool SmallCAssemblyCompiler.isMinimumIntegerLiteral(String spelling) {
    int64 first = 0
    while (first + 1 < spelling.length
            && int64(spelling[
            
            first]) == 48) {
        first += 1
    }
    return(byteSpan(spelling, first, spelling.length).equals("2147483648"))
}

/*
 * Perform decode escape for SmallCAssemblyCompiler.
 *
 * value: value (int64).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 SmallCAssemblyCompiler.decodeEscape(int64 value) {
    if (value == 110) {
        return(10)
    }
    if (value == 114) {
        return(13)
    }
    if (value == 116) {
        return(9)
    }
    if (value == 48) {
        return(0)
    }
    return(value)
}

/*
 * Perform character value for SmallCAssemblyCompiler.
 *
 * spelling: spelling (String).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 SmallCAssemblyCompiler.characterValue(String spelling) {
    int64 value = int64(spelling[1])
    if (value == 92) {
        value = decodeEscape(int64(spelling[2]))
    }
    return(value)
}
