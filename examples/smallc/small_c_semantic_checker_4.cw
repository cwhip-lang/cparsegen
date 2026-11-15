/*
 * examples/smallc/small_c_semantic_checker_4.cw — Out-of-line methods for
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
 * Perform enter rule parameter for SmallCSemanticChecker.
 *
 * node: node (AstNode).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 SmallCSemanticChecker.enter_rule_parameter(AstNode node) {
    String valueType = node.childAt(0).childAt(0).lexeme()
    AstNode nameNode = node.childAt(1)
    int64 i = 0
    while (i < parameterNames.length) {
        if ((parameterNames[i] as String).equals(nameNode.lexeme())) {
            fail(
                    nameNode,
                    format("duplicate parameter '{}'", nameNode.lexeme()))
            return(VISIT_ERROR)
        }
        i += 1
    }
    parameterNames.append(nameNode.lexeme())
    checkedParameterTypes.append(valueType)
    return(VISIT_SKIP)
}

/*
 * Return true when is label holds for the argument, and false otherwise.
 *
 * node: node (AstNode).
 *
 * Returns true when the condition holds and false otherwise.
 */
bool SmallCSemanticChecker.isLabel(AstNode node) {
    return(((node.name.equals("matchedStatement") || node.name.equals(
            
            "openStatement"))
        && node.children.length == 3 && child(
            
            node,
            
            0).name.equals(
            
            "IDENT")
        && child(
            
            node,
            
            1).text.equals(
            
            ":")))
}

/*
 * Record labels on the compiler or checker.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.collectLabels(AstNode node) {
    if (isLabel(node)) {
        labels.append(child(node, 0))
    }
    int64 i = 0
    while (i < node.children.length) {
        collectLabels(child(node, i))
        i += 1
    }
}

/*
 * Return the matching label, or null when nothing matches.
 *
 * name: name (String).
 *
 * Returns the AstNode result, or null when the operation fails and this
 * method uses null for that.
 */
AstNode SmallCSemanticChecker.findLabel(String name) {
    int64 i = 0
    while (i < labels.length) {
        AstNode label = labels[i] as AstNode
        if (label.text.equals(name)) {
            return(label)
        }
        i += 1
    }
    return(null)
}

/*
 * Perform case key for SmallCSemanticChecker.
 *
 * node: node (AstNode).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCSemanticChecker.caseKey(AstNode node) {

    AstNode literal = child(node, node.children.length - 1)
    String text = literal.text
    if (literal.name.equals("CHAR")) {

        int64 value = int64(text[1])
        if (value == 92) {
            value = int64(text[2])

            if (value == 110) {
                value = 10
            }
            else {

                if (value == 114) {
                    value = 13
                }
                else {
                    if (value == 116) {
                        value = 9
                    }
                    else {
                        if (value == 48) {
                            value = 0
                        }
                    }
                }

            }

        }

        return(format("{}", value))
    }

    // Compare decimal spellings without imposing a host integer width.
    int64 first = 0
    while (first + 1 < text.length && int64(text[first]) == 48) {
        first += 1
    }
    String result = byteSpan(text, first, text.length)
    if (child(node, 0).text.equals("-") && !result.equals("0")) {
        return(format("-{}", result))
    }
    return(result)
}

/*
 * Validate function and record a problem when it is illegal or unsupported.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.checkFunction(AstNode node) {
    String valueType = child(child(node, 0), 0).text
    AstNode nameNode = child(node, 1)
    AstNode parameters = null
    AstNode body = null
    bool definition = false
    int64 i = 0
    while (i < node.children.length) {
        AstNode part = child(node, i)
        if (part.name.equals("parameters")) {
            parameters = part
        }
        if (part.name.equals("compoundStatement")) {
            body = part
            definition = true }
        i += 1
    }
    if (intrinsics.find(nameNode.text) != null) {
        fail(nameNode, format(
                
                "'{}' is a reserved compiler intrinsic name",
                
                nameNode.text))
        return
    }
    list types = []
    if (parameters != null) {
        types = parameterTypes(parameters)
    }
    if (!problem.equals("")) {
        return
    }
    SmallCSymbol function = findGlobal(nameNode.text)
    if (function != null && !function.kind.equals("function")) {
        fail(nameNode, format(
                
                "function '{}' conflicts with a global variable",
                
                nameNode.text))
        return
    }

    if (function == null) {
        function = SmallCSymbol(nameNode.text, "function", valueType)
        function.parameterTypes = types
        globals.append(function)
    }
    else {
        if (!function.valueType.equals(valueType) ||
                function.parameterTypes.length != types.length) {
            fail(nameNode, format(
                    
                    "incompatible function signature for '{}'",
                    
                    nameNode.text))
            return
        }

        int64 p = 0
        while (p < types.length && problem.equals("")) {
            if (!(function.parameterTypes[p] as String).equals(
                    types[
                    p] as String)) {
                fail(nameNode, format(
                        
                        "incompatible function signature for '{}'",
                        
                        nameNode.text))
            }
            p += 1
        }

    }

    if (!problem.equals("")) {
        return
    }
    if (definition && function.hasDefinition) {
        fail(nameNode, format(
                
                "duplicate definition of function '{}'",
                
                nameNode.text))
        return
    }
    if (!definition && function.hasPrototype) {
        fail(nameNode, format(
                
                "duplicate declaration of function '{}'",
                
                nameNode.text))
        return
    }
    if (definition) {
        function.hasDefinition = true
    }
    else {
        function.hasPrototype = true
    }

    if (definition) {
        returnType = valueType
        labels = []
        loopDepth = 0
        switchDepth = 0
        collectLabels(body)
        pushScope()

        if (parameters != null) {

            int64 p = 0
            int64 parameterIndex = 0
            while (p < parameters.children.length && problem.equals("")) {
                AstNode parameter = child(parameters, p)
                if (parameter.name.equals("parameter")) {
                    addVariable(
                            child(parameter, 1),
                            types[
                            parameterIndex] as String,
                            false)
                    parameterIndex += 1
                }
                p += 1
            }

        }

        if (problem.equals("")) {
            checkCompound(body, false)
        }
        popScope()
        returnType = ""
        labels = []
    }

}

/*
 * Validate for initializer and record a problem when it is illegal or
 * unsupported.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.checkForInitializer(AstNode node) {

    int64 i = 0
    while (i < node.children.length && problem.equals("")) {
        AstNode part = child(node, i)
        if (part.name.equals("declaration")) {
            checkDeclaration(part, false)
        }
        else {
            if (part.name.equals("expression")) {
                expressionType(part)
            }
        }
        i += 1
    }

}

/*
 * Validate compound and record a problem when it is illegal or unsupported.
 *
 * node: node (AstNode). nested: nested (bool).
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.checkCompound(AstNode node, bool nested) {
    if (nested) {
        pushScope()
    }
    int64 i = 0
    while (i < node.children.length && problem.equals("")) {
        AstNode part = child(node, i)
        if (part.name.equals("blockItem")) {
            checkBlockItem(part)
        }
        i += 1
    }
    if (nested) {
        popScope()
    }
}
