/*
 * examples/smallc/small_c_assembly_compiler_8.cw — Out-of-line methods for
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
 * print(char[]): writes the bytes before the first NUL (or the whole array
 * when none), retrying short writes.
 *
 * argument: argument (AstNode).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.emitPrint(AstNode argument) {
    bool literal = argument.name.equals("STRING")
    SmallCAsmVariable variable = null
    if (!literal) {
        variable = findVariable(arrayArgumentName(argument).text)
    }
    String length = addTemporary("int")
    String done = addTemporary("int")
    String scan = code.newLabel()
    String scanEnd = code.newLabel()
    String send = code.newLabel()
    String sendEnd = code.newLabel()
    code.op("const.i32 0")
    code.op1("stloc", length)
    code.op("pop")

    if (literal) {
        code.op1("const.i32", format(
                "{}",
                stringBytes(
                argument.text).length))
        code.op1("stloc", length)
        code.op("pop")
    }
    else {
        code.mark(scan)
        code.op1("ldloc", length)
        emitArrayReference(variable)
        code.op("alen")
        code.op("lt.i32")
        code.op1("jz", scanEnd)
        emitArrayReference(variable)
        code.op1("ldloc", length)
        code.op("aget")
        if (elementType(variable.valueType).equals("char")) {
            code.op("to.i32")
        }
        code.op1("jz", scanEnd)
        code.op1("ldloc", length)
        code.op("const.i32 1")
        code.op("add.i32")
        code.op1("stloc", length)
        code.op("pop")
        code.op1("jmp", scan)
        code.mark(scanEnd)
    }

    code.op("const.i32 0")
    code.op1("stloc", done)
    code.op("pop")
    code.mark(send)
    code.op1("ldloc", done)
    code.op1("ldloc", length)
    code.op("lt.i32")
    code.op1("jz", sendEnd)
    if (literal) {
        emitBufferArgument(argument)
    }
    else {
        emitArrayReference(variable)
    }
    code.op1("ldloc", done)
    code.op1("ldloc", length)
    code.op1("ldloc", done)
    code.op("sub.i32")
    code.op1("sys", "stdout_write")
    code.op1("ldloc", done)
    code.op("add.i32")
    code.op1("stloc", done)
    code.op("pop")
    code.op1("jmp", send)
    code.mark(sendEnd)
    return("void")
}

/*
 * Pushes a char array reference for a bare array name or a string literal.
 *
 * argument: argument (AstNode).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitBufferArgument(AstNode argument) {
    if (argument.name.equals("STRING")) {
        buffer bytes = stringBytes(argument.text)
        SmallCAsmArray array = SmallCAsmArray(
            format("s{}_literal", arrays.length), "char", bytes.length + 1)
        array.staticInitializer = assemblyString(bytes)
        array.isGlobal = true
        arrays.append(array)
        code.op1("array", array.asmName)
        return
    }
    emitArrayReference(findVariable(arrayArgumentName(argument).text))
}

/*
 * Write the emit intrinsic form into the output being generated.
 *
 * node: node (AstNode). intrinsic: intrinsic (SmallCIntrinsic).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.emitIntrinsic(
        AstNode node,
        SmallCIntrinsic intrinsic) {
    list arguments = callArguments(node)
    if (intrinsic.service.equals("stdout_write")) {
        return(emitPrint(arguments[0] as AstNode))
    }

    bool transfer = intrinsic.service.equals(
            "file_read_handle") || intrinsic.service.equals("file_write_handle")
    if (transfer) {
        // Source order is (handle, length, buffer); the service takes
        // (handle, buffer, length). Evaluate in source order via
        // temporaries.
        String handleSlot = addTemporary("int")
        String lengthSlot = addTemporary("int")
        promoteToInt(emitExpression(arguments[0] as AstNode))
        code.op1("stloc", handleSlot)
        code.op("pop")
        promoteToInt(emitExpression(arguments[1] as AstNode))
        code.op1("stloc", lengthSlot)
        code.op("pop")
        code.op1("ldloc", handleSlot)
        emitBufferArgument(arguments[2] as AstNode)
        code.op1("ldloc", lengthSlot)
    }
    else {

        int64 a = 0
        while (a < arguments.length && problem.equals("")) {
            AstNode argument = arguments[a] as AstNode
            String expected = intrinsic.parameterTypes[a] as String
            if (expected.equals("char[]")) {
                emitBufferArgument(argument)
            }
            else {
                promoteToInt(emitExpression(argument))
            }
            a += 1
        }

    }

    if (problem.equals("")) {
        code.op1("sys", intrinsic.service)
    }
    return(intrinsic.resultType)
}

/*
 * Write the emit lvalue form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.emitLvalue(AstNode node) {
    AstNode nameNode = child(node, 0)
    SmallCAsmVariable variable = findVariable(nameNode.text)
    if (variable == null) {
        fail(nameNode, format("undeclared variable '{}'", nameNode.text))
        return("")
    }

    if (node.children.length == 1) {
        if (variable.array) {
            fail(nameNode, format(
                    
                    "array '{}' cannot be used as a scalar value",
                    
                    nameNode.text))
            return("")
        }
        emitLoad(variable)
        return(variable.valueType)
    }

    if (!variable.array) {
        fail(nameNode, format(
                
                "variable '{}' is not an array",
                
                nameNode.text))
        return("")
    }
    emitArrayReference(variable)
    String indexType = emitExpression(child(node, 2))
    promoteToInt(indexType)
    code.op("aget")
    return(elementType(variable.valueType))
}

/*
 * Perform evaluate index for SmallCAssemblyCompiler.
 *
 * lvalue: lvalue (AstNode).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.evaluateIndex(AstNode lvalue) {
    String indexType = emitExpression(child(lvalue, 2))
    promoteToInt(indexType)
    String slot = addTemporary("int")
    code.op1("stloc", slot)
    code.op("pop")
    return(slot)
}

/*
 * Write the emit assignment form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.emitAssignment(AstNode node) {
    AstNode lvalue = child(node, 0)
    String operation = child(node, 1).text
    AstNode right = child(node, 2)
    AstNode nameNode = child(lvalue, 0)
    SmallCAsmVariable variable = findVariable(nameNode.text)
    if (variable == null) {
        fail(nameNode, format("undeclared variable '{}'", nameNode.text))
        return("")
    }

    if (!variable.array) {
        if (operation.equals("=")) {
            String valueType = emitExpression(right)
            emitStore(variable)
            return(valueType)
        }
        emitLoad(variable)
        String rightType = emitExpression(right)
        promoteToInt(rightType)
        emitCompoundOperation(operation, child(node, 1))
        emitStore(variable)
        return("int")
    }

    String indexSlot = evaluateIndex(lvalue)
    if (operation.equals("=")) {
        String valueType = emitExpression(right)
        String valueSlot = addTemporary(valueType)
        code.op1("stloc", valueSlot)
        code.op("pop")
        emitArrayReference(variable)
        code.op1("ldloc", indexSlot)
        code.op1("ldloc", valueSlot)
        code.op("aset")
        return(valueType)
    }

    emitArrayReference(variable)
    code.op1("ldloc", indexSlot)
    code.op("aget")
    String rightType = emitExpression(right)
    promoteToInt(rightType)
    emitCompoundOperation(operation, child(node, 1))
    String resultSlot = addTemporary("int")
    code.op1("stloc", resultSlot)
    code.op("pop")
    emitArrayReference(variable)
    code.op1("ldloc", indexSlot)
    code.op1("ldloc", resultSlot)
    code.op("aset")
    return("int")
}

/*
 * Write the emit compound operation form into the output being generated.
 *
 * operation: operation (String). operator: operator (AstNode).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitCompoundOperation(
        String operation,
        AstNode operator) {
    String mnemonic = ""
    if (operation.equals("+=")) {
        mnemonic = "add.i32"
    }
    if (operation.equals("-=")) {
        mnemonic = "sub.i32"
    }
    if (operation.equals("*=")) {
        mnemonic = "mul.i32"
    }
    if (operation.equals("/=")) {
        mnemonic = "div.i32"
    }
    if (operation.equals("%=")) {
        mnemonic = "rem.i32"
    }
    if (mnemonic.equals("")) {
        fail(operator, format(
                
                "CVM backend does not support operator '{}'",
                
                operation))
    }
    else {
        code.op(mnemonic)
    }
}
