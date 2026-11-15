/*
 * examples/smallc/small_c_assembly_compiler_3.cw — Out-of-line methods for
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
 * Record global declaration on the compiler or checker.
 *
 * declaration: declaration (AstNode).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.collectGlobalDeclaration(AstNode declaration) {

    String baseType = child(child(declaration, 0), 0).text
    int64 i = 1
    while (i < declaration.children.length && problem.equals("")) {

        AstNode declarator = child(declaration, i)
        if (declarator.name.equals("declarator")) {

            AstNode nameNode = child(declarator, 0)
            bool isArray = declarator.children.length > 1 && child(declarator,
                    1).text.equals("[")
            AstNode initializer = declarationInitializer(declarator)
            bool needsCode = initializer != null
            if (isArray) {

                int64 length = declaredArrayLength(declarator, initializer)
                if (length <= 0) {
                    fail(nameNode, format(
                            
                            "array '{}' requires a positive fixed size or inferable initializer",
                            
                            nameNode.text))
                }
                else {
                    String arrayElementType = "int"
                    String arrayType = "int[]"
                    if (baseType.equals("char")) {
                        arrayElementType = "char"
                        arrayType = "char[]"
                    }
                    SmallCAsmArray array = SmallCAsmArray(
                        format("a{}_{}", arrays.length, nameNode.text),
                        arrayElementType, length)
                    array.staticInitializer = staticArrayInitializer(
                        arrayElementType, length, initializer, nameNode.text)
                    if (!array.staticInitializer.equals("")) {
                        needsCode = false
                    }
                    array.isGlobal = true
                    arrays.append(array)
                    globals.append(SmallCAsmVariable(
                            
                            
                        nameNode.text,
                            
                            arrayType,
                            
                            true,
                            
                            true,
                            
                            arrays.length - 1,
                            
                            
                        array.asmName))
                }

            }
            else {
                SmallCAsmVariable variable = SmallCAsmVariable(
                    nameNode.text, baseType, true, false, scalarGlobalCount,
                    format("g_{}", nameNode.text))
                globals.append(variable)
                scalarGlobalCount += 1
            }

            if (needsCode && problem.equals("")) {
                globalInitializers.append([declarator, initializer])
            }
        }

        i += 1
    }

}

/*
 * Record function on the compiler or checker.
 *
 * external: external (AstNode).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.collectFunction(AstNode external) {
    String resultType = child(child(external, 0), 0).text
    AstNode nameNode = child(external, 1)
    SmallCAsmFunction function = findFunction(nameNode.text)
    if (function == null) {
        function = SmallCAsmFunction(nameNode.text, resultType)
        functions.append(function)
    }
    function.parameterTypes = []
    function.parameters = null
    function.declaration = nameNode

    int64 i = 0
    while (i < external.children.length) {

        AstNode part = child(external, i)
        if (part.name.equals("parameters")) {
            function.parameters = part

            int64 p = 0
            while (p < part.children.length) {
                AstNode parameter = child(part, p)
                if (parameter.name.equals("parameter")) {
                    function.parameterTypes.append(
                        child(child(
                            
                            parameter,
                            
                            0), 0).text)
                }
                p += 1
            }

        }

        if (part.name.equals("compoundStatement")) {
            function.body = part
        }
        i += 1
    }

}

/*
 * Record program on the compiler or checker.
 *
 * root: root (AstNode).
 *
 * Returns true on success and false when the operation does not apply or has
 * failed.
 */
bool SmallCAssemblyCompiler.collectProgram(AstNode root) {

    int64 i = 0
    while (i < root.children.length && problem.equals("")) {
        AstNode external = child(root, i)
        if (external.children.length > 0) {
            AstNode declaration = child(external, 0)
            if (declaration.name.equals("declaration")) {
                collectGlobalDeclaration(declaration)
            }
            else {
                collectFunction(external)
            }
        }
        i += 1
    }

    if (!problem.equals("")) {
        return(false)
    }
    entryFunction = findFunction("main")
    if (entryFunction == null || entryFunction.body == null) {
        fail(root, "SmallC program requires a definition of main()")
        return(false)
    }
    if (!entryFunction.returnType.equals("int")
            || entryFunction.parameterTypes.length != 0) {
        fail(
                
                entryFunction.declaration,
                
                "CVM entry point main must have type int main()")
        return(false)
    }
    int64 f = 0
    while (f < functions.length) {
        SmallCAsmFunction function = functions[f] as SmallCAsmFunction
        if (function.body != null) {
            function.defined = true
        }
        f += 1
    }
    return(true)
}

/*
 * Returns the complete assembly source, or null with `problem` set.
 *
 * root: root (AstNode). frontendModel: frontend model (SmallCFrontend).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.compile(
        AstNode root,
        SmallCFrontend frontendModel) {
    frontend = frontendModel
    problem = ""
    errorNode = root
    functionText = ""
    if (!collectProgram(root)) {
        return(null)
    }
    String initText = compileGlobalInitializers()
    if (!problem.equals("")) {
        return(null)
    }
    int64 i = 0
    while (i < functions.length && problem.equals("")) {
        SmallCAsmFunction function = functions[i] as SmallCAsmFunction
        if (function.defined) {
            compileUserFunction(function)
        }
        i += 1
    }
    if (!problem.equals("")) {
        return(null)
    }
    return(assemble(initText))
}

/*
 * Wrap the lowered instructions in the CVM assembly prologue and epilogue.
 *
 * initText: init text (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.assemble(String initText) {
    String result = "; SmallC compiler output: CVM v1 assembly.\n"
    result.append("; Assemble with: cvm-as INPUT.asm -o OUTPUT.cvm\n")
    result.append(".version 1.0\n.entry main\n")

    bool hasData = false
    int64 i = 0
    while (i < globals.length) {
        SmallCAsmVariable variable = globals[i] as SmallCAsmVariable
        if (!variable.array) {
            if (!hasData) {
                result.append("\n")
            }
            hasData = true
            result.append(format(".global {}: {} = 0\n", variable.asmName,
                asmType(
                    
                    variable.valueType)))
        }
        i += 1
    }

    i = 0

    while (i < arrays.length) {
        SmallCAsmArray array = arrays[i] as SmallCAsmArray
        if (!array.isGlobal) {
            i += 1
            continue
        }
        if (!hasData) {
            result.append("\n")
        }
        hasData = true
        result.append(format(".array {}: {}[{}]", array.asmName,
            asmType(
                
                array.elementType), array.length))
        if (!array.staticInitializer.equals("")) {
            result.append(format(" = {}", array.staticInitializer))
        }
        result.append("\n")
        i += 1
    }

    result.append("\n.func main() -> i32\n")
    if (!initText.equals("")) {
        result.append("    call smallc_init_globals\n")
    }
    result.append(format(
            
            "    call {}\n    ret.i32\n.end\n",
            
            entryFunction.asmName))
    if (!initText.equals("")) {
        result.append(initText)
    }
    result.append(functionText)
    return(result)
}

/*
 * Perform compile global initializers for SmallCAssemblyCompiler.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.compileGlobalInitializers() {
    if (globalInitializers.length == 0) {
        return("")
    }
    currentFunction = SmallCAsmFunction("smallc_init_globals", "void")
    code = SmallCAsmCode()
    scope = null
    loop = null

    int64 i = 0
    while (i < globalInitializers.length && problem.equals("")) {
        list pair = globalInitializers[i] as list
        AstNode declarator = pair[0] as AstNode
        AstNode initializer = pair[1] as AstNode
        SmallCAsmVariable variable = findGlobal(child(declarator, 0).text)
        if (variable != null && variable.array) {
            emitArrayInitializer(variable, initializer)
        }
        else {
            emitExpression(child(initializer, 0))
            emitStore(variable)
            code.op("pop")
        }
        i += 1
    }

    if (!problem.equals("")) {
        return("")
    }
    code.op("ret")
    String result = "\n.func smallc_init_globals() -> void\n"
    result.append(declarationText())
    result.append(code.text)
    result.append(".end\n")
    return(result)
}
