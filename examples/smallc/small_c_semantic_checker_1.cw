/*
 * examples/smallc/small_c_semantic_checker_1.cw — Out-of-line methods for
 * SmallCSemanticChecker.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCSemanticChecker methods out of
 *              examples/smallc/smallc_frontend.cw.
 */

/*
 * Create a SmallCSemanticChecker and store the values passed to the
 * constructor.
 *
 * Returns the new object.
 */
SmallCSemanticChecker SmallCSemanticChecker.SmallCSemanticChecker() {
    super GeneratedVisitor()
    intrinsics = SmallCIntrinsics()
    locations = []
    globals = []
    currentScope = null
    problem = ""
    errorOffset = 0
    returnType = ""
    labels = []
    loopDepth = 0
    switchDepth = 0
    parameterNames = []
    checkedParameterTypes = []
}

/*
 * Return the child at index as an AstNode.
 *
 * node: node (AstNode). index: index (int64).
 *
 * Returns the AstNode result, or null when the operation fails and this
 * method uses null for that.
 */
AstNode SmallCSemanticChecker.child(AstNode node, int64 index) {
    return(node.children[index] as AstNode)
}

/*
 * Perform index locations for SmallCSemanticChecker.
 *
 * node: node (AstNode). tokens: tokens (list). cursor: cursor
 * (SmallCTokenCursor).
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.indexLocations(
        AstNode node,
        list tokens,
        SmallCTokenCursor cursor) {
    if (node.children.length == 0) {
        int64 offset = 0
        if (cursor.index < tokens.length) {
            offset = (tokens[cursor.index] as LexToken).offset
            cursor.index += 1
        }
        locations.append(SmallCLocation(node, offset))
        return
    }
    int64 i = 0
    while (i < node.children.length) {
        indexLocations(child(node, i), tokens, cursor)
        i += 1
    }
    locations.append(SmallCLocation(node, offsetOf(child(node, 0))))
}

/*
 * Perform offset of for SmallCSemanticChecker.
 *
 * node: node (AstNode).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 SmallCSemanticChecker.offsetOf(AstNode node) {
    int64 i = 0
    while (i < locations.length) {
        SmallCLocation location = locations[i] as SmallCLocation
        if (location.node == node) {
            return(location.offset)
        }
        i += 1
    }
    return(0)
}

/*
 * Perform fail for SmallCSemanticChecker.
 *
 * node: node (AstNode). message: message (String).
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.fail(AstNode node, String message) {
    if (problem.equals("")) {
        problem = message
        errorOffset = offsetOf(node)
    }
}

/*
 * Return true when is array holds for the argument, and false otherwise.
 *
 * valueType: value type (String).
 *
 * Returns true when the condition holds and false otherwise.
 */
bool SmallCSemanticChecker.isArray(String valueType) {
    return(valueType.equals("int[]") || valueType.equals("char[]"))
}

/*
 * Perform element type for SmallCSemanticChecker.
 *
 * valueType: value type (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCSemanticChecker.elementType(String valueType) {
    if (valueType.equals("int[]")) {
        return("int")
    }
    if (valueType.equals("char[]")) {
        return("char")
    }
    return(valueType)
}

/*
 * Return true when is scalar holds for the argument, and false otherwise.
 *
 * valueType: value type (String).
 *
 * Returns true when the condition holds and false otherwise.
 */
bool SmallCSemanticChecker.isScalar(String valueType) {
    return(valueType.equals("int") || valueType.equals("char"))
}

/*
 * Return true when is value holds for the argument, and false otherwise.
 *
 * valueType: value type (String).
 *
 * Returns true when the condition holds and false otherwise.
 */
bool SmallCSemanticChecker.isValue(String valueType) {
    return(isScalar(valueType))
}

/*
 * Return the matching global, or null when nothing matches.
 *
 * name: name (String).
 *
 * Returns the SmallCSymbol result, or null when the operation fails and this
 * method uses null for that.
 */
SmallCSymbol SmallCSemanticChecker.findGlobal(String name) {
    int64 i = 0
    while (i < globals.length) {
        SmallCSymbol symbol = globals[i] as SmallCSymbol
        if (symbol.name.equals(name)) {
            return(symbol)
        }
        i += 1
    }
    return(null)
}

/*
 * Return the matching scoped, or null when nothing matches.
 *
 * name: name (String).
 *
 * Returns the SmallCSymbol result, or null when the operation fails and this
 * method uses null for that.
 */
SmallCSymbol SmallCSemanticChecker.findScoped(String name) {

    SmallCScope scope = currentScope
    while (scope != null) {
        int64 i = 0
        while (i < scope.symbols.length) {
            SmallCSymbol symbol = scope.symbols[i] as SmallCSymbol
            if (symbol.name.equals(name)) {
                return(symbol)
            }
            i += 1
        }
        scope = scope.parent
    }

    return(null)
}

/*
 * Return the matching variable, or null when nothing matches.
 *
 * name: name (String).
 *
 * Returns the SmallCSymbol result, or null when the operation fails and this
 * method uses null for that.
 */
SmallCSymbol SmallCSemanticChecker.findVariable(String name) {
    SmallCSymbol symbol = findScoped(name)
    if (symbol != null) {
        return(symbol)
    }
    return(findGlobal(name))
}

/*
 * Perform current scope has for SmallCSemanticChecker.
 *
 * name: name (String).
 *
 * Returns true on success and false when the operation does not apply or has
 * failed.
 */
bool SmallCSemanticChecker.currentScopeHas(String name) {
    if (currentScope == null) {
        return(false)
    }
    int64 i = 0
    while (i < currentScope.symbols.length) {
        if ((currentScope.symbols[i] as SmallCSymbol).name.equals(name)) {
            return(true)
        }
        i += 1
    }
    return(false)
}

/*
 * Open a nested scope for the block about to be compiled or checked.
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.pushScope() {
    currentScope = SmallCScope(currentScope)
}

/*
 * Close the current scope and restore the one that enclosed it.
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.popScope() {
    if (currentScope != null) {
        currentScope = currentScope.parent
    }
}

/*
 * Perform add variable for SmallCSemanticChecker.
 *
 * nameNode: name node (AstNode). valueType: value type (String). global:
 * global (bool).
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.addVariable(
        AstNode nameNode,
        String valueType,
        bool global) {
    String name = nameNode.text
    if (intrinsics.find(name) != null) {
        fail(nameNode, format(
                
                "'{}' is a reserved compiler intrinsic name",
                
                name))
        return
    }

    if (global) {
        if (findGlobal(name) != null) {
            fail(
                    nameNode,
                    format(
                    "duplicate global declaration '{}'",
                    name))
            return
        }
        globals.append(SmallCSymbol(name, "variable", valueType))
        return
    }

    if (currentScopeHas(name)) {
        fail(nameNode, format("duplicate variable declaration '{}'", name))
        return
    }
    currentScope.symbols.append(SmallCSymbol(name, "variable", valueType))
}

/*
 * Perform exact type for SmallCSemanticChecker.
 *
 * actual: actual (String). expected: expected (String). node: node
 * (AstNode). context: context (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCSemanticChecker.exactType(
        
        String actual,
        
        String expected,
        
        AstNode node,
        
        String context) {
    if (actual.equals("void")) {
        fail(node, format(
                
                "{} cannot use the result of a void intrinsic",
                
                context))
        return("")
    }
    if (!isValue(actual)) {
        fail(node, format("{} requires a scalar value", context))
        return("")
    }

    if (!actual.equals(expected)) {
        fail(node, format(
                
                "{} requires {}, got {}",
                
                context,
                
                expected,
                
                actual))
        return("")
    }

    return(actual)
}
