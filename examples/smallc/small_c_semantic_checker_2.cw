/*
 * examples/smallc/small_c_semantic_checker_2.cw — Out-of-line methods for
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
 * Perform lvalue type for SmallCSemanticChecker.
 *
 * node: node (AstNode). writing: writing (bool).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCSemanticChecker.lvalueType(AstNode node, bool writing) {
    AstNode nameNode = child(node, 0)
    SmallCSymbol symbol = findVariable(nameNode.text)
    if (symbol == null) {
        fail(nameNode, format("undeclared variable '{}'", nameNode.text))
        return("")
    }
    if (!symbol.kind.equals("variable")) {
        fail(nameNode, format(
                
                "function '{}' is not a variable",
                
                nameNode.text))
        return("")
    }

    if (node.children.length == 1) {
        if (writing && isArray(symbol.valueType)) {
            fail(nameNode, format(
                    
                    "array '{}' is not a modifiable scalar",
                    
                    nameNode.text))
            return("")
        }
        return(symbol.valueType)
    }

    if (!isArray(symbol.valueType)) {
        fail(nameNode, format(
                
                "variable '{}' is not an array",
                
                nameNode.text))
        return("")
    }
    String indexType = expressionType(child(node, 2))
    if (!isScalar(indexType)) {
        fail(child(node, 2), "array index must have integral scalar type")
        return("")
    }
    return(elementType(symbol.valueType))
}

/*
 * Returns the lvalue naming a whole array when an argument is exactly that
 * bare identifier, otherwise null.
 *
 * argument: argument (AstNode).
 *
 * Returns the AstNode result, or null when the operation fails and this
 * method uses null for that.
 */
AstNode SmallCSemanticChecker.arrayArgument(AstNode argument) {
    AstNode current = argument
    while (!current.name.equals("lvalue") && current.children.length == 1) {
        current = child(current, 0)
    }
    if (current.name.equals("lvalue") && current.children.length == 1) {
        return(current)
    }
    return(null)
}

/*
 * Perform intrinsic call type for SmallCSemanticChecker.
 *
 * node: node (AstNode). intrinsic: intrinsic (SmallCIntrinsic).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCSemanticChecker.intrinsicCallType(
        AstNode node,
        SmallCIntrinsic intrinsic) {
    AstNode nameNode = child(node, 0)
    int64 argumentCount = 0
    int64 i = 0
    while (i < node.children.length && !child(node, i).name.equals(
            
            "arguments")) {
        i += 1
    }

    if (i < node.children.length) {

        AstNode arguments = child(node, i)
        int64 a = 0
        while (a < arguments.children.length && problem.equals("")) {

            AstNode argument = child(arguments, a)
            if (argument.name.equals("STRING")) {
                String stringExpected = ""
                if (argumentCount < intrinsic.parameterTypes.length) {
                    stringExpected = intrinsic.parameterTypes[
                            argumentCount] as String
                }
                if (!stringExpected.equals("char[]")) {
                    fail(argument, format(
                            
                            "argument {} to '{}' cannot be a string literal",
                            
                            argumentCount + 1,
                            
                            intrinsic.name))
                }
                argumentCount += 1
            }

            if (argument.name.equals("assignment")) {

                if (argumentCount >= intrinsic.parameterTypes.length) {
                    fail(argument, format(
                            
                            "intrinsic '{}' called with too many arguments",
                            
                            intrinsic.name))
                }
                else {

                    String expected = intrinsic.parameterTypes[
                            argumentCount] as String
                    String context = format("argument {} to '{}'",
                            argumentCount + 1, intrinsic.name)
                    if (expected.equals("char[]")) {
                        AstNode target = arrayArgument(argument)
                        SmallCSymbol symbol = null
                        if (target != null) {
                            symbol = findVariable(child(target, 0).text)
                        }

                        if (symbol == null || !symbol.kind.equals(
                                
                                "variable")
                                || !symbol.valueType.equals(
                                
                                "char[]")) {
                            fail(argument, format(
                                    
                                    "{} requires the name of a char array",
                                    
                                    context))
                        }

                    }
                    else {

                        String actual = expressionType(argument)
                        if (problem.equals("")) {

                            if (expected.equals("byte") || expected.equals(
                                    
                                    "int")) {

                                if (actual.equals("void")) {
                                    fail(argument, format(
                                            
                                            "{} cannot use the result of a void intrinsic",
                                            
                                            context))
                                }
                                else {
                                    if (!isScalar(actual)) {
                                        fail(argument, format(
                                                
                                                "{} requires an integral scalar value",
                                                
                                                context))
                                    }
                                }

                            }
                            else {
                                exactType(
                                        
                                        actual,
                                        
                                        expected,
                                        
                                        argument,
                                        
                                        context)
                            }

                        }

                    }

                }

                argumentCount += 1
            }

            a += 1
        }

    }

    if (problem.equals("") &&
            argumentCount != intrinsic.parameterTypes.length) {
        fail(nameNode, format(
                
                "intrinsic '{}' expects {} arguments, got {}",
                
                intrinsic.name,
                
                intrinsic.parameterTypes.length,
                
                argumentCount))
    }

    return(intrinsic.resultType)
}

/*
 * Perform call type for SmallCSemanticChecker.
 *
 * node: node (AstNode).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCSemanticChecker.callType(AstNode node) {
    AstNode nameNode = child(node, 0)
    SmallCIntrinsic intrinsic = intrinsics.find(nameNode.text)
    if (intrinsic != null) {
        return(intrinsicCallType(node, intrinsic))
    }
    SmallCSymbol local = findScoped(nameNode.text)
    if (local != null) {
        fail(nameNode, format(
                
                "'{}' names a variable, not a function",
                
                nameNode.text))
        return("")
    }
    SmallCSymbol function = findGlobal(nameNode.text)
    if (function == null) {
        fail(nameNode, format(
                
                "call to undeclared function '{}'",
                
                nameNode.text))
        return("")
    }
    if (!function.kind.equals("function")) {
        fail(nameNode, format(
                
                "'{}' names a variable, not a function",
                
                nameNode.text))
        return("")
    }
    int64 argumentCount = 0
    int64 i = 0
    while (i < node.children.length && !child(node, i).name.equals(
            
            "arguments")) {
        i += 1
    }

    if (i < node.children.length) {

        AstNode arguments = child(node, i)
        int64 a = 0
        while (a < arguments.children.length && problem.equals("")) {
            AstNode argument = child(arguments, a)
            if (argument.name.equals("STRING")) {
                fail(argument, format(
                        
                        "string literals may only be passed to compiler built-ins, not '{}'",
                        
                        function.name))
            }

            if (argument.name.equals("assignment")) {

                String actual = expressionType(argument)
                if (argumentCount >= function.parameterTypes.length) {
                    fail(argument, format(
                            
                            "function '{}' called with too many arguments",
                            
                            function.name))
                }
                else {
                    String expected = function.parameterTypes[
                            argumentCount] as String
                    exactType(actual, expected, argument, format(
                            
                            "argument {} to '{}'",
                            
                            argumentCount + 1,
                            
                            function.name))
                }

                argumentCount += 1
            }

            a += 1
        }

    }

    if (problem.equals("") && argumentCount != function.parameterTypes.length) {
        fail(nameNode, format(
                
                "function '{}' expects {} arguments, got {}",
                
                function.name,
                
                function.parameterTypes.length,
                
                argumentCount))
    }

    return(function.valueType)
}
