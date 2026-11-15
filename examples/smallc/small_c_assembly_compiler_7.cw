/*
 * examples/smallc/small_c_assembly_compiler_7.cw — Out-of-line methods for
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
 * Perform binary mnemonic for SmallCAssemblyCompiler.
 *
 * operation: operation (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.binaryMnemonic(String operation) {
    if (operation.equals("+")) {
        return("add.i32")
    }
    if (operation.equals("-")) {
        return("sub.i32")
    }
    if (operation.equals("*")) {
        return("mul.i32")
    }
    if (operation.equals("/")) {
        return("div.i32")
    }
    if (operation.equals("%")) {
        return("rem.i32")
    }
    if (operation.equals("==")) {
        return("eq.i32")
    }
    if (operation.equals("!=")) {
        return("ne.i32")
    }
    if (operation.equals("<")) {
        return("lt.i32")
    }
    if (operation.equals("<=")) {
        return("le.i32")
    }
    if (operation.equals(">")) {
        return("gt.i32")
    }
    if (operation.equals(">=")) {
        return("ge.i32")
    }
    return("")
}

/*
 * Write the emit binary chain form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.emitBinaryChain(AstNode node) {

    String resultType = emitExpression(child(node, 0))
    int64 i = 1
    while (i + 1 < node.children.length && problem.equals("")) {
        String operation = child(node, i).text
        promoteToInt(resultType)
        String rightType = emitExpression(child(node, i + 1))
        promoteToInt(rightType)
        String mnemonic = binaryMnemonic(operation)
        if (mnemonic.equals("")) {
            fail(child(node, i), format(
                    
                    "CVM backend does not support operator '{}'",
                    
                    operation))
        }
        else {
            code.op(mnemonic)
        }
        resultType = "int"
        i += 2
    }

    return(resultType)
}

/*
 * Write the emit logical form into the output being generated.
 *
 * node: node (AstNode). conjunction: conjunction (bool).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.emitLogical(AstNode node, bool conjunction) {
    if (node.children.length == 1) {
        return(emitExpression(child(node, 0)))
    }

    String end = code.newLabel()
    String shortCircuit = code.newLabel()
    int64 i = 0
    while (i < node.children.length && problem.equals("")) {

        AstNode part = child(node, i)
        if (part.name.equals("logicalAnd") || part.name.equals("equality")) {
            String valueType = emitExpression(part)
            promoteToInt(valueType)
            if (conjunction) {
                code.op1("jz", shortCircuit)
            }
            else {
                String next = code.newLabel()
                code.op1("jz", next)
                emitInt(1)
                code.op1("jmp", end)
                code.mark(next)
            }
        }

        if (part.text.equals("&&") || part.text.equals("||")) {
            if (part.text.equals("&&") != conjunction) {
                fail(part, "invalid logical-expression AST")
            }
        }
        i += 1
    }

    if (conjunction) {
        emitInt(1)
        code.op1("jmp", end)
        code.mark(shortCircuit)
        emitInt(0)
    }
    else {
        emitInt(0)
    }
    code.mark(end)
    return("int")
}

/*
 * Write the emit unary form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.emitUnary(AstNode node) {
    if (node.children.length == 1) {
        return(emitExpression(child(node, 0)))
    }
    String operation = child(node, 0).text
    AstNode operand = child(node, 1)
    if (operation.equals("++") || operation.equals("--")) {
        return(emitIncrement(operand, false, operation.equals("++")))
    }
    if (operation.equals("-") && operand.name.equals("INTEGER")
            && isMinimumIntegerLiteral(
            
            operand.text)) {
        emitInt(-2147483648)
        return("int")
    }
    String valueType = emitExpression(operand)
    if (operation.equals("+")) {
        promoteToInt(valueType)
        return("int")
    }
    if (operation.equals("-")) {
        promoteToInt(valueType)
        code.op("neg.i32")
        return("int")
    }
    if (operation.equals("!")) {
        promoteToInt(valueType)
        emitInt(0)
        code.op("eq.i32")
        return("int")
    }
    fail(child(node, 0), format(
            
            "CVM backend does not support unary operator '{}'",
            
            operation))
    return("")
}

/*
 * Write the emit primary form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.emitPrimary(AstNode node) {
    if (node.children.length >= 3 && child(node, 0).name.equals("IDENT")
            && child(
            
            node,
            
            1).text.equals(
            
            "(")) {
        return(emitCall(node))
    }
    if (node.children.length == 3 && child(node, 0).text.equals("(")) {
        return(emitExpression(child(node, 1)))
    }
    if (child(node, 0).name.equals("lvalue")) {
        if (node.children.length > 1) {
            String operation = child(node, 1).text
            return(emitIncrement(child(node, 0), true, operation.equals(
                    
                    "++")))
        }
        return(emitLvalue(child(node, 0)))
    }
    return(emitExpression(child(node, 0)))
}

/*
 * Perform call arguments for SmallCAssemblyCompiler.
 *
 * node: node (AstNode).
 *
 * Returns the list built by this method. The list is empty when nothing
 * matched.
 */
list SmallCAssemblyCompiler.callArguments(AstNode node) {

    list result = []
    int64 i = 0
    while (i < node.children.length) {

        AstNode part = child(node, i)
        if (part.name.equals("arguments")) {
            int64 a = 0
            while (a < part.children.length) {
                AstNode argument = child(part, a)
                if (argument.name.equals("assignment") || argument.name.equals(
                        
                        "STRING")) {
                    result.append(argument)
                }
                a += 1
            }
        }

        i += 1
    }

    return(result)
}

/*
 * Write the emit call form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.emitCall(AstNode node) {
    AstNode nameNode = child(node, 0)
    SmallCIntrinsic intrinsic = intrinsics.find(nameNode.text)
    if (intrinsic != null) {
        return(emitIntrinsic(node, intrinsic))
    }
    SmallCAsmFunction function = findFunction(nameNode.text)
    if (function == null || !function.defined) {
        fail(nameNode, format(
                
                "CVM backend has no definition for function '{}'",
                
                nameNode.text))
        return("")
    }
    list arguments = callArguments(node)
    int64 a = 0
    while (a < arguments.length && problem.equals("")) {
        emitExpression(arguments[a] as AstNode)
        a += 1
    }
    code.op1("call", function.asmName)
    return(function.returnType)
}

/*
 * Perform array argument name for SmallCAssemblyCompiler.
 *
 * argument: argument (AstNode).
 *
 * Returns the AstNode result, or null when the operation fails and this
 * method uses null for that.
 */
AstNode SmallCAssemblyCompiler.arrayArgumentName(AstNode argument) {
    AstNode current = argument
    while (!current.name.equals("lvalue") && current.children.length == 1) {
        current = child(current, 0)
    }
    return(child(current, 0))
}
