/*
 * examples/smallc/small_c_semantic_checker_3.cw — Out-of-line methods for
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
 * Perform expression type for SmallCSemanticChecker.
 *
 * node: node (AstNode).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCSemanticChecker.expressionType(AstNode node) {
    if (!problem.equals("")) {
        return("")
    }
    if (node.name.equals("INTEGER")) {
        return("int")
    }
    if (node.name.equals("CHAR")) {
        return("char")
    }

    if (node.name.equals("lvalue")) {
        String valueType = lvalueType(node, false)
        if (isArray(valueType)) {
            fail(child(node, 0),
                    format("array '{}' cannot be used as a scalar value", child(
                    
                    node,
                    
                    0).text))
            return("")
        }
        return(valueType)
    }

    if (node.name.equals("assignment") && node.children.length == 3) {

        String left = lvalueType(child(node, 0), true)
        String operation = child(node, 1).text
        String right = expressionType(child(node, 2))
        if (problem.equals("")) {

            if (operation.equals("=")) {

                if (right.equals("void")) {
                    fail(
                            
                            child(node, 2),
                            
                            "assignment cannot use the result of a void intrinsic")
                }
                else {

                    if (!isValue(right)) {
                        fail(
                                
                                child(node, 2),
                                
                                "assignment requires a scalar value")
                    }
                    else {
                        if (!left.equals(right)) {
                            fail(child(node, 0), format(
                                    
                                    "assignment requires {}, got {}",
                                    
                                    left,
                                    
                                    right))
                        }
                    }

                }

            }
            else {

                if (!isScalar(left) || !isScalar(right)) {
                    fail(
                            
                            node,
                            
                            "compound assignment requires integral scalar operands")
                }
                else {
                    if (!left.equals("int")) {
                        fail(child(node, 0), format(
                                
                                "compound assignment produces int, not {}",
                                
                                left))
                    }
                }

            }

        }

        return(left)
    }

    if (node.name.equals("primary")) {
        if (node.children.length >= 3 && child(node, 0).name.equals("IDENT") &&
                child(
                
                node,
                
                1).text.equals(
                
                "(")) {
            return(callType(node))
        }
        if (node.children.length == 3 && child(node, 0).text.equals("(")) {
            return(expressionType(child(node, 1)))
        }

        if (child(node, 0).name.equals("lvalue")) {
            String valueType = lvalueType(child(node, 0),
                    node.children.length > 1)
            if (node.children.length > 1 && !isScalar(valueType)) {
                fail(
                        
                        child(node, 0),
                        
                        "increment/decrement requires a scalar variable")
                return("")
            }
            if (isArray(valueType)) {
                fail(child(child(node, 0), 0),
                        format("array '{}' cannot be used as a scalar value",
                        child(child(
                        
                        node,
                        
                        0), 0).text))
                return("")
            }
            return(valueType)
        }

        return(expressionType(child(node, 0)))
    }

    if (node.name.equals("unary")) {
        if (node.children.length == 1) {
            return(expressionType(child(node, 0)))
        }

        if (node.children.length == 2 && (child(node, 0).text.equals("++") ||
                child(
                
                node,
                
                0).text.equals(
                
                "--"))) {
            String target = lvalueType(child(node, 1), true)
            if (!isScalar(target)) {
                fail(
                        
                        child(node, 1),
                        
                        "increment/decrement requires a scalar variable")
                return("")
            }
            return(target)
        }

        String operand = expressionType(child(node, 1))
        if (!isScalar(operand)) {
            fail(
                    
                    child(node, 1),
                    
                    "unary operator requires an integral scalar operand")
            return("")
        }
        return("int")
    }

    if (node.children.length > 1) {

        String result = expressionType(child(node, 0))
        int64 i = 1
        while (i < node.children.length && problem.equals("")) {

            if (i + 1 < node.children.length) {
                String right = expressionType(child(node, i + 1))
                if (!isScalar(result) || !isScalar(right)) {
                    fail(
                            
                            child(node, i + 1),
                            
                            "operator requires integral scalar operands")
                    return("")
                }
                result = "int"
                i += 2
            }
            else {
                i += 1
            }

        }

        return(result)
    }

    if (node.children.length == 1) {
        return(expressionType(child(node, 0)))
    }
    fail(node, format("unsupported expression node '{}'", node.name))
    return("")
}

/*
 * Validate initializer and record a problem when it is illegal or
 * unsupported.
 *
 * initializer: initializer (AstNode). valueType: value type (String).
 * nameNode: name node (AstNode).
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.checkInitializer(
        
        AstNode initializer,
        
        String valueType,
        
        AstNode nameNode) {
    if (!problem.equals("")) {
        return
    }
    bool array = isArray(valueType)
    String target = elementType(valueType)
    if (initializer.children.length == 1 && child(initializer, 0).name.equals(
            
            "STRING")) {
        if (!array || !target.equals("char")) {
            fail(initializer, "string initializer requires a char array")
        }
        return
    }

    if (initializer.children.length > 0 && child(initializer, 0).text.equals(
            
            "{")) {
        if (!array) {
            fail(initializer, format(
                    
                    "scalar '{}' cannot use an array initializer",
                    
                    nameNode.text))
            return
        }

        int64 i = 1
        while (i < initializer.children.length && problem.equals("")) {
            AstNode value = child(initializer, i)
            if (value.name.equals("assignment")) {
                String actual = expressionType(value)
                exactType(actual, target, value, format(
                        
                        "array initializer for '{}'",
                        
                        nameNode.text))
            }
            i += 1
        }

        return
    }

    if (array) {
        fail(initializer, format(
                
                "array '{}' requires a string or brace initializer",
                
                nameNode.text))
        return
    }
    if (initializer.children.length == 1) {
        String actual = expressionType(child(initializer, 0))
        exactType(actual, target, initializer, format(
                
                "initializer for '{}'",
                
                nameNode.text))
        return
    }
    fail(initializer, format("invalid initializer for '{}'", nameNode.text))
}

/*
 * Validate declaration and record a problem when it is illegal or
 * unsupported.
 *
 * node: node (AstNode). global: global (bool).
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.checkDeclaration(AstNode node, bool global) {

    String base = child(child(node, 0), 0).text
    int64 i = 1
    while (i < node.children.length && problem.equals("")) {

        AstNode declarator = child(node, i)
        if (declarator.name.equals("declarator")) {

            AstNode nameNode = child(declarator, 0)
            bool array = declarator.children.length > 1 && child(declarator,
                    1).text.equals("[")
            String valueType = base
            int64 initializerIndex = declarator.children.length
            if (array) {
                valueType = "int[]"
                if (base.equals("char")) {
                    valueType = "char[]"
                }
                int64 d = 1
                while (d < declarator.children.length
                        && !child(
                        
                        declarator,
                        
                        d).text.equals(
                        
                        "=")) {
                    d += 1
                }
                initializerIndex = d
            }
            else {
                if (declarator.children.length > 1 && child(declarator,
                        1).text.equals(
                        
                        "=")) {
                    initializerIndex = 1
                }
            }

            if (problem.equals("")) {
                addVariable(nameNode, valueType, global)
            }
            if (problem.equals("") &&
                    initializerIndex < declarator.children.length) {
                checkInitializer(
                        child(
                        declarator,
                        initializerIndex + 1),
                        valueType,
                        nameNode)
            }
        }

        i += 1
    }

}

/*
 * Perform parameter types for SmallCSemanticChecker.
 *
 * parameters: parameters (AstNode).
 *
 * Returns the list built by this method. The list is empty when nothing
 * matched.
 */
list SmallCSemanticChecker.parameterTypes(AstNode parameters) {
    parameterNames = []
    checkedParameterTypes = []
    if (walk(parameters) != VISIT_CONTINUE && problem.equals("")) {
        fail(parameters, "parameter visitor failed")
    }
    return(checkedParameterTypes)
}
