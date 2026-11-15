/*
 * examples/smallc/small_c_assembly_compiler_4.cw — Out-of-line methods for
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
 * Perform declaration text for SmallCAssemblyCompiler.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.declarationText() {
    String result = ""
    int64 i = 0
    while (i < currentFunction.declarations.length) {
        result.append(currentFunction.declarations[i] as String)
        i += 1
    }
    return(result)
}

/*
 * Perform compile user function for SmallCAssemblyCompiler.
 *
 * function: function (SmallCAsmFunction).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.compileUserFunction(SmallCAsmFunction function) {
    currentFunction = function
    function.localCount = 0
    function.declarations = []
    function.parameterSymbols = []
    code = SmallCAsmCode()
    scope = SmallCAsmScope(null)
    loop = null

    String header = format("\n.func {}(", function.asmName)
    int64 parameterIndex = 0
    if (function.parameters != null) {

        int64 i = 0
        while (i < function.parameters.children.length) {

            AstNode parameter = child(function.parameters, i)
            if (parameter.name.equals("parameter")) {
                String valueType = function.parameterTypes[
                        parameterIndex] as String
                String symbol = format("p{}_{}", parameterIndex,
                        child(parameter, 1).text)
                function.parameterSymbols.append(symbol)
                scope.variables.append(SmallCAsmVariable(
                        child(
                        parameter,
                        1).text,
                        
                    valueType,
                        false,
                        false,
                        0,
                        symbol))
                if (parameterIndex > 0) {
                    header.append(", ")
                }
                header.append(format("{}:{}", symbol, asmType(valueType)))
                parameterIndex += 1
            }

            i += 1
        }

    }

    header.append(format(") -> {}\n", asmType(function.returnType)))
    emitCompound(function.body, false)
    if (!problem.equals("")) {
        return
    }
    if (!guaranteesReturn(function.body) && !function.name.equals("main")) {
        fail(function.declaration,
            format(
                
                "function '{}' may reach its end without returning",
                
                function.name))
        return
    }
    if (function.returnType.equals("char")) {
        code.op1("const.u8", "0")
        code.op("ret.u8")
    }
    else {
        code.op1("const.i32", "0")
        code.op("ret.i32")
    }
    functionText.append(header)
    functionText.append(declarationText())
    functionText.append(code.text)
    functionText.append(".end\n")
}

/*
 * Return true when every path through the statement reaches a return.
 *
 * node: node (AstNode).
 *
 * Returns true when the condition holds and false otherwise.
 */
bool SmallCAssemblyCompiler.guaranteesReturn(AstNode node) {
    if (node == null) {
        return(false)
    }

    if (node.name.equals("simpleStatement")) {
        if (node.children.length > 0 && child(node, 0).text.equals("return")) {
            return(true)
        }
        int64 i = 0
        while (i < node.children.length) {
            if (child(node, i).name.equals("compoundStatement")) {
                return(guaranteesReturn(child(node, i)))
            }
            i += 1
        }
        return(false)
    }

    if (node.name.equals("statement")) {
        int64 i = 0
        while (i < node.children.length) {
            if (guaranteesReturn(child(node, i))) {
                return(true)
            }
            i += 1
        }
        return(false)
    }

    if (node.name.equals("compoundStatement")) {

        int64 i = 0
        while (i < node.children.length) {

            AstNode item = child(node, i)
            if (item.name.equals("blockItem")) {
                int64 j = 0
                while (j < item.children.length) {
                    AstNode part = child(item, j)
                    if (part.name.equals("statement") && guaranteesReturn(
                            
                            part)) {
                        return(true)
                    }
                    j += 1
                }
            }

            i += 1
        }

        return(false)
    }

    if (node.name.equals("matchedStatement")) {
        if (node.children.length > 0 && child(node, 0).text.equals("if")) {
            list statements = statementChildren(node)
            return((statements.length == 2
                && guaranteesReturn(statements[
                    
                    0] as AstNode)
                && guaranteesReturn(statements[
                    
                    1] as AstNode)))
        }
        if (node.children.length > 0
                && child(node, 0).name.equals(
                
                "simpleStatement")) {
            return(guaranteesReturn(child(node, 0)))
        }
    }

    if (node.name.equals("openStatement")) {
        if (node.children.length > 0 && child(node, 0).text.equals("if")) {
            list statements = statementChildren(node)
            return((statements.length == 2
                && guaranteesReturn(statements[
                    
                    0] as AstNode)
                && guaranteesReturn(statements[
                    
                    1] as AstNode)))
        }
        if (node.children.length > 0
                && child(node, 0).name.equals(
                
                "simpleStatement")) {
            return(guaranteesReturn(child(node, 0)))
        }
    }

    return(false)
}

/*
 * Return true when is statement node holds for the argument, and false
 * otherwise.
 *
 * node: node (AstNode).
 *
 * Returns true when the condition holds and false otherwise.
 */
bool SmallCAssemblyCompiler.isStatementNode(AstNode node) {
    return((node.name.equals("statement")
        || node.name.equals(
            
            "matchedStatement")
        || node.name.equals(
            
            "openStatement")
        || node.name.equals(
            
            "simpleStatement")
        || node.name.equals(
            
            "compoundStatement")
        || node.name.equals(
            
            "switchStatement")))
}

/*
 * Perform statement children for SmallCAssemblyCompiler.
 *
 * node: node (AstNode).
 *
 * Returns the list built by this method. The list is empty when nothing
 * matched.
 */
list SmallCAssemblyCompiler.statementChildren(AstNode node) {
    list result = []
    int64 i = 0
    while (i < node.children.length) {
        AstNode part = child(node, i)
        if (isStatementNode(part)) {
            result.append(part)
        }
        i += 1
    }
    return(result)
}

/*
 * Write the emit int form into the output being generated.
 *
 * value: value (int64).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitInt(int64 value) {
    code.op1("const.i32", format("{}", value))
}

/*
 * Write the emit byte form into the output being generated.
 *
 * value: value (int64).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitByte(int64 value) {
    code.op1("const.u8", format("{}", value))
}

/*
 * Perform promote to int for SmallCAssemblyCompiler.
 *
 * valueType: value type (String).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.promoteToInt(String valueType) {
    if (valueType.equals("char")) {
        code.op("to.i32")
    }
}

/*
 * Discards an expression statement's value; void intrinsics push none.
 *
 * valueType: value type (String).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.discard(String valueType) {
    if (!valueType.equals("void")) {
        code.op("pop")
    }
}

/*
 * Write the emit load form into the output being generated.
 *
 * variable: variable (SmallCAsmVariable).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitLoad(SmallCAsmVariable variable) {
    if (variable == null) {
        return
    }
    if (variable.array) {
        fail(errorNode, "internal attempt to load an array as a scalar")
        return
    }
    if (variable.global) {
        code.op1("ldglobal", variable.asmName)
    }
    else {
        code.op1("ldloc", variable.asmName)
    }
}

/*
 * Write the emit store form into the output being generated.
 *
 * variable: variable (SmallCAsmVariable).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitStore(SmallCAsmVariable variable) {
    if (variable == null) {
        return
    }
    if (variable.global) {
        code.op1("stglobal", variable.asmName)
    }
    else {
        code.op1("stloc", variable.asmName)
    }
}
