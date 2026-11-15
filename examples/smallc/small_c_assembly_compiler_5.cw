/*
 * examples/smallc/small_c_assembly_compiler_5.cw — Out-of-line methods for
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
 * Write the emit array reference form into the output being generated.
 *
 * variable: variable (SmallCAsmVariable).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitArrayReference(SmallCAsmVariable variable) {
    if (variable == null || !variable.array) {
        fail(errorNode, "internal attempt to index a scalar")
        return
    }
    code.op1("array", variable.asmName)
}

/*
 * Write the emit array initializer form into the output being generated.
 *
 * variable: variable (SmallCAsmVariable). initializer: initializer
 * (AstNode).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitArrayInitializer(
        SmallCAsmVariable variable,
        AstNode initializer) {
    if (initializer == null || variable == null) {
        return
    }
    SmallCAsmArray array = arrays[variable.index] as SmallCAsmArray
    if (initializer.children.length == 1
            && child(
            
            initializer,
            
            0).name.equals(
            
            "STRING")) {

        buffer bytes = stringBytes(child(initializer, 0).text)
        if (bytes.length > array.length) {
            fail(initializer, format(
                    
                    "string initializer for '{}' exceeds array capacity {}",
                    
                    
                variable.name,
                    
                    array.length))
            return
        }

        int64 i = 0
        while (i < bytes.length && problem.equals("")) {
            emitArrayReference(variable)
            emitInt(i)
            emitByte(int64(bytes[i]))
            code.op("aset")
            code.op("pop")
            i += 1
        }
        if (bytes.length < array.length && problem.equals("")) {
            emitArrayReference(variable)
            emitInt(bytes.length)
            emitByte(0)
            code.op("aset")
            code.op("pop")
        }
        return
    }

    int64 element = 0
    int64 i = 0
    while (i < initializer.children.length && problem.equals("")) {

        AstNode value = child(initializer, i)
        if (value.name.equals("assignment")) {
            if (element >= array.length) {
                fail(value, format(
                        
                        "too many elements in initializer for '{}'",
                        
                        variable.name))
                return
            }
            emitArrayReference(variable)
            emitInt(element)

            String actual = emitExpression(value)
            if (!actual.equals(array.elementType)) {
                fail(value, format(
                        
                        "initializer for '{}' requires {}, got {}",
                        
                        
                    variable.name,
                        
                        array.elementType,
                        
                        actual))
                return
            }

            code.op("aset")
            code.op("pop")
            element += 1
        }

        i += 1
    }

}

/*
 * Write the emit declaration form into the output being generated.
 *
 * declaration: declaration (AstNode).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitDeclaration(AstNode declaration) {

    String baseType = child(child(declaration, 0), 0).text
    int64 i = 1
    while (i < declaration.children.length && problem.equals("")) {

        AstNode declarator = child(declaration, i)
        if (declarator.name.equals("declarator")) {

            AstNode nameNode = child(declarator, 0)
            bool isArray = declarator.children.length > 1 && child(declarator,
                    1).text.equals("[")
            AstNode initializer = declarationInitializer(declarator)
            if (isArray) {

                int64 length = declaredArrayLength(declarator, initializer)
                if (length <= 0) {
                    fail(nameNode, format(
                            
                            "array '{}' requires a positive fixed size or inferable initializer",
                            
                            nameNode.text))
                }
                else {
                    int64 index = arrays.length
                    String arrayElementType = "int"
                    String arrayType = "int[]"
                    if (baseType.equals("char")) {
                        arrayElementType = "char"
                        arrayType = "char[]"
                    }
                    SmallCAsmArray array = SmallCAsmArray(
                        format("a{}_{}", index,
                                nameNode.text), arrayElementType, length)
                    arrays.append(array)
                    currentFunction.declarations.append(
                        format("    .array {}: {}[{}]\n", array.asmName,
                            asmType(
                            
                            arrayElementType), length))
                    SmallCAsmVariable variable = SmallCAsmVariable(
                        nameNode.text, arrayType, false, true, index,
                                array.asmName)
                    scope.variables.append(variable)
                    emitArrayInitializer(variable, initializer)
                }

            }
            else {
                addLocal(nameNode.text, baseType)

                SmallCAsmVariable variable = scope.variables[
                        scope.variables.length - 1] as SmallCAsmVariable
                if (initializer != null && initializer.children.length > 0) {

                    String actual = emitExpression(child(initializer, 0))
                    if (!actual.equals(baseType)) {
                        fail(initializer, format(
                                
                                "initializer for '{}' requires {}, got {}",
                                
                                
                            nameNode.text,
                                
                                baseType,
                                
                                actual))
                    }

                    emitStore(variable)
                    code.op("pop")
                }

            }

        }

        i += 1
    }

}

/*
 * Write the emit compound form into the output being generated.
 *
 * node: node (AstNode). nested: nested (bool).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitCompound(AstNode node, bool nested) {
    if (nested) {
        pushScope()
    }
    int64 i = 0
    while (i < node.children.length && problem.equals("")) {
        AstNode item = child(node, i)
        if (item.name.equals("blockItem")) {
            emitBlockItem(item)
        }
        i += 1
    }
    if (nested) {
        popScope()
    }
}

/*
 * Write the emit block item form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitBlockItem(AstNode node) {

    int64 i = 0
    while (i < node.children.length && problem.equals("")) {
        AstNode part = child(node, i)
        if (part.name.equals("declaration")) {
            emitDeclaration(part)
        }
        else {
            if (part.name.equals("statement")) {
                emitStatement(part)
            }
        }
        i += 1
    }

}

/*
 * Write the emit statement form into the output being generated.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCAssemblyCompiler.emitStatement(AstNode node) {
    if (node.name.equals("simpleStatement")) {
        emitAtomicStatement(node)
        return
    }
    if (node.name.equals("compoundStatement")) {
        emitCompound(node, true)
        return
    }
    if (node.name.equals("statement")
            || node.name.equals(
            
            "matchedStatement")
            || node.name.equals(
            
            "openStatement")) {
        if (node.children.length == 0) {
            return
        }
        String first = child(node, 0).text
        if (first.equals("if")) {
            emitIf(node)
            return
        }
        if (first.equals("while")) {
            emitWhile(node)
            return
        }
        if (first.equals("for")) {
            emitFor(node)
            return
        }
        if (node.children.length > 1
                && child(node, 0).name.equals(
                
                "IDENT")
                && child(
                
                node,
                
                1).text.equals(
                
                ":")) {
            fail(
                    
                    child(node, 0),
                    
                    "CVM backend does not support labels or goto")
            return
        }

        int64 i = 0
        while (i < node.children.length && problem.equals("")) {
            AstNode part = child(node, i)
            if (part.name.equals("statement")
                    || part.name.equals(
                    
                    "matchedStatement")
                    || part.name.equals(
                    
                    "openStatement")
                    || part.name.equals(
                    
                    "simpleStatement")
                    || part.name.equals(
                    
                    "compoundStatement")) {
                emitStatement(part)
            }
            i += 1
        }

        return
    }
    if (node.name.equals("switchStatement")) {
        fail(
                
                child(node, 0),
                
                "CVM backend does not support switch statements")
        return
    }
    fail(node, format(
            
            "CVM backend does not support statement node '{}'",
            
            node.name))
}
