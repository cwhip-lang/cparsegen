/*
 * examples/smallc/small_c_assembly_compiler_6.cw — Out-of-line methods for
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
 * Write the emit atomic statement form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitAtomicStatement(AstNode node) {
    if (node.children.length == 0) {
        return
    }
    AstNode first = child(node, 0)
    if (first.text.equals("switch")) {
        fail(first, "CVM backend does not support switch statements")
        return
    }
    if (first.text.equals("goto")) {
        fail(first, "CVM backend does not support labels or goto")
        return
    }
    if (first.text.equals("break")) {
        if (loop == null) {
            fail(first, "CVM backend does not support break outside a loop")
            return
        }
        code.op1("jmp", loop.breakLabel)
        return
    }

    if (first.text.equals("continue")) {
        if (loop == null) {
            fail(
                    
                    first,
                    
                    "CVM backend does not support continue outside a loop")
            return
        }
        code.op1("jmp", loop.continueLabel)
        return
    }

    if (first.text.equals("return")) {
        AstNode expression = null
        int64 i = 1
        while (i < node.children.length) {
            if (child(node, i).name.equals("expression")) {
                expression = child(node, i)
            }
            i += 1
        }
        if (expression == null) {
            fail(first, "CVM backend requires a return value")
            return
        }
        String actual = emitExpression(expression)
        if (actual.equals("char")) {
            code.op("ret.u8")
        }
        else {
            code.op("ret.i32")
        }
        return
    }

    int64 i = 0
    while (i < node.children.length && problem.equals("")) {
        AstNode part = child(node, i)
        if (part.name.equals("expression")) {
            discard(emitExpression(part))
        }
        if (part.name.equals("compoundStatement")) {
            emitCompound(part, true)
        }
        if (part.name.equals("switchStatement")) {
            fail(
                    
                    child(part, 0),
                    
                    "CVM backend does not support switch statements")
        }
        i += 1
    }

}

/*
 * Write the emit if form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitIf(AstNode node) {
    AstNode condition = null
    list statements = statementChildren(node)
    int64 i = 0
    while (i < node.children.length) {
        if (child(node, i).name.equals("expression")) {
            condition = child(node, i)
        }
        i += 1
    }
    if (condition == null || statements.length == 0) {
        fail(node, "invalid if statement AST")
        return
    }
    String otherwise = code.newLabel()
    String end = code.newLabel()
    String conditionType = emitExpression(condition)
    promoteToInt(conditionType)
    code.op1("jz", otherwise)
    emitStatement(statements[0] as AstNode)
    if (statements.length > 1) {
        code.op1("jmp", end)
        code.mark(otherwise)
        emitStatement(statements[1] as AstNode)
        code.mark(end)
    }
    else {
        code.mark(otherwise)
    }
}

/*
 * Write the emit while form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitWhile(AstNode node) {
    AstNode condition = null
    list statements = statementChildren(node)
    int64 i = 0
    while (i < node.children.length) {
        if (child(node, i).name.equals("expression")) {
            condition = child(node, i)
        }
        i += 1
    }
    if (condition == null || statements.length == 0) {
        fail(node, "invalid while statement AST")
        return
    }
    String loopStart = code.newLabel()
    String end = code.newLabel()
    code.mark(loopStart)
    String conditionType = emitExpression(condition)
    promoteToInt(conditionType)
    code.op1("jz", end)
    loop = SmallCAsmLoop(end, loopStart, loop)
    emitStatement(statements[0] as AstNode)
    loop = loop.parent
    code.op1("jmp", loopStart)
    code.mark(end)
}

/*
 * Write the emit for form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitFor(AstNode node) {

    AstNode initializer = null
    AstNode condition = null
    AstNode update = null
    list statements = statementChildren(node)
    bool afterInitializer = false
    bool afterCondition = false
    int64 i = 0
    while (i < node.children.length) {

        AstNode part = child(node, i)
        if (part.name.equals("forInitializer")) {
            initializer = part
            afterInitializer = true
        }
        else {

            if (afterInitializer && part.text.equals(";")) {
                afterCondition = true
            }
            else {
                if (afterInitializer && part.name.equals("expression")) {
                    if (afterCondition) {
                        update = part
                    }
                    else {
                        condition = part
                    }
                }
            }

        }

        i += 1
    }

    if (initializer == null || statements.length == 0) {
        fail(node, "invalid for statement AST")
        return
    }
    pushScope()
    emitForInitializer(initializer)
    String loopStart = code.newLabel()
    String updateLabel = code.newLabel()
    String end = code.newLabel()
    code.mark(loopStart)
    if (condition != null) {
        String conditionType = emitExpression(condition)
        promoteToInt(conditionType)
        code.op1("jz", end)
    }
    loop = SmallCAsmLoop(end, updateLabel, loop)
    emitStatement(statements[0] as AstNode)
    loop = loop.parent
    code.mark(updateLabel)
    if (update != null) {
        discard(emitExpression(update))
    }
    code.op1("jmp", loopStart)
    code.mark(end)
    popScope()
}

/*
 * Write the emit for initializer form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitForInitializer(AstNode node) {

    int64 i = 0
    while (i < node.children.length && problem.equals("")) {
        AstNode part = child(node, i)
        if (part.name.equals("declaration")) {
            emitDeclaration(part)
        }
        else {
            if (part.name.equals("expression")) {
                discard(emitExpression(part))
            }
        }
        i += 1
    }

}

/*
 * Write the emit expression form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.emitExpression(AstNode node) {
    if (problem.length > 0 || node == null) {
        return("")
    }
    if (node.name.equals("expression")) {
        return(emitExpression(child(node, 0)))
    }
    if (node.name.equals("assignment")) {
        if (node.children.length == 3) {
            return(emitAssignment(node))
        }
        return(emitExpression(child(node, 0)))
    }
    if (node.name.equals("logicalOr")) {
        return(emitLogical(node, false))
    }
    if (node.name.equals("logicalAnd")) {
        return(emitLogical(node, true))
    }
    if (node.name.equals("equality") || node.name.equals("relational")
            || node.name.equals(
            
            "additive") || node.name.equals(
            
            "multiplicative")) {
        return(emitBinaryChain(node))
    }
    if (node.name.equals("unary")) {
        return(emitUnary(node))
    }
    if (node.name.equals("primary")) {
        return(emitPrimary(node))
    }
    if (node.name.equals("lvalue")) {
        return(emitLvalue(node))
    }
    if (node.name.equals("INTEGER")) {
        emitInt(integerValue(node.text, 2147483647, node))
        return("int")
    }
    if (node.name.equals("CHAR")) {
        emitByte(characterValue(node.text))
        return("char")
    }
    fail(node, format(
            
            "CVM backend does not support expression node '{}'",
            
            node.name))
    return("")
}
