/*
 * examples/smallc/small_c_assembly_compiler_2.cw — Out-of-line methods for
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
 * Perform string bytes for SmallCAssemblyCompiler.
 *
 * spelling: spelling (String).
 *
 * Returns the buffer result.
 */
buffer SmallCAssemblyCompiler.stringBytes(String spelling) {
    buffer bytes = buffer[]
    int64 i = 1
    while (i + 1 < spelling.length) {
        int64 value = int64(spelling[i])
        if (value == 92) {
            i += 1
            value = decodeEscape(int64(spelling[i]))
        }
        bytes.append(value)
        i += 1
    }
    return(bytes)
}

/*
 * Perform hex byte for SmallCAssemblyCompiler.
 *
 * value: value (int64).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.hexByte(int64 value) {
    String digits = "0123456789abcdef"
    return(format("{}{}", byteSpan(digits, value / 16, value / 16 + 1),
        byteSpan(
            
            digits,
            
            value % 16,
            
            value % 16 + 1)))
}

/*
 * Quotes decoded bytes as a CVM assembly string literal. Everything except a
 * conservative printable set is written as an exact \xHH escape, so quotes,
 * backslashes, semicolons, NULs and non-ASCII bytes survive.
 *
 * bytes: bytes (buffer).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.assemblyString(buffer bytes) {

    String safe = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 _-.,:/!?()[]{}+=<>*&%#@^~|"
    String result = "\""
    int64 i = 0
    while (i < bytes.length) {
        int64 value = int64(bytes[i])
        int64 s = 0
        bool printable = false
        while (s < safe.length && !printable) {
            if (int64(safe[s]) == value) {
                printable = true
            }
            else {
                s += 1
            }
        }
        if (printable) {
            result.append(byteSpan(safe, s, s + 1))
        }
        else {
            result.append("\\x")
            result.append(hexByte(value))
        }
        i += 1
    }

    result.append("\"")
    return(result)
}

/*
 * Perform initializer count for SmallCAssemblyCompiler.
 *
 * initializer: initializer (AstNode).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 SmallCAssemblyCompiler.initializerCount(AstNode initializer) {
    if (initializer == null) {
        return(0)
    }
    if (initializer.children.length == 1
            && child(
            
            initializer,
            
            0).name.equals(
            
            "STRING")) {
        return(stringBytes(child(initializer, 0).text).length + 1)
    }
    int64 count = 0
    int64 i = 0
    while (i < initializer.children.length) {
        if (child(initializer, i).name.equals("assignment")) {
            count += 1
        }
        i += 1
    }
    return(count)
}

/*
 * Perform declaration initializer for SmallCAssemblyCompiler.
 *
 * declarator: declarator (AstNode).
 *
 * Returns the AstNode result, or null when the operation fails and this
 * method uses null for that.
 */
AstNode SmallCAssemblyCompiler.declarationInitializer(AstNode declarator) {
    int64 i = 1
    while (i < declarator.children.length
            && !child(
            
            declarator,
            
            i).text.equals(
            
            "=")) {
        i += 1
    }
    if (i < declarator.children.length && i + 1 < declarator.children.length) {
        return(child(declarator, i + 1))
    }
    return(null)
}

/*
 * Perform declared array length for SmallCAssemblyCompiler.
 *
 * declarator: declarator (AstNode). initializer: initializer (AstNode).
 *
 * Returns the int64 result. A negative sentinel means the operation failed
 * when this method uses one.
 */
int64 SmallCAssemblyCompiler.declaredArrayLength(
        AstNode declarator,
        AstNode initializer) {
    if (declarator.children.length > 2
            && child(
            
            declarator,
            
            2).name.equals(
            
            "INTEGER")) {
        return(integerValue(child(declarator, 2).text, 2147483647, child(
                
                declarator,
                
                2)))
    }
    return(initializerCount(initializer))
}

/*
 * Decimal spelling of a plain (optionally signed) literal expression, or ""
 * when the expression must be evaluated at run time.
 *
 * node: node (AstNode). valueType: value type (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.literalText(AstNode node, String valueType) {

    AstNode current = node
    bool negative = false
    bool signSeen = false
    while (!current.name.equals("")) {

        if (current.name.equals("INTEGER")) {
            if (!valueType.equals("int")) {
                return("")
            }
            if (negative && isMinimumIntegerLiteral(current.text)) {
                return("-2147483648")
            }
            int64 value = integerValue(current.text, 2147483647, current)
            if (negative && value != 0) {
                return(format("-{}", value))
            }
            return(format("{}", value))
        }

        if (current.name.equals("CHAR")) {
            if (!valueType.equals("char") || signSeen) {
                return("")
            }
            return(format("{}", characterValue(current.text)))
        }
        if (current.name.equals("unary") && current.children.length == 2
                && !signSeen
                && (child(
                
                current,
                
                0).text.equals(
                
                "-") || child(
                
                current,
                
                0).text.equals(
                
                "+"))) {
            negative = child(current, 0).text.equals("-")
            signSeen = true
            current = child(current, 1)
        }
        else {
            if (current.children.length == 1
                    && !current.name.equals(
                    
                    "lvalue")) {
                current = child(current, 0)
            }
            else {
                return("")
            }
        }
    }

    return("")
}

/*
 * Returns an assembly array initializer for a global when every element is
 * constant and fits, or "" to initialize with code before main runs.
 *
 * arrayElementType: array element type (String). length: length (int64).
 * initializer: initializer (AstNode). name: name (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.staticArrayInitializer(
        
        String arrayElementType,
        
        int64 length,
        

        AstNode initializer,
        
        String name) {
    if (initializer == null) {
        return("")
    }
    if (initializer.children.length == 1
            && child(
            
            initializer,
            
            0).name.equals(
            
            "STRING")) {

        buffer bytes = stringBytes(child(initializer, 0).text)
        if (bytes.length > length) {
            fail(initializer, format(
                    
                    "string initializer for '{}' exceeds array capacity {}",
                    
                    
                name,
                    
                    length))
            return("")
        }

        if (bytes.length == length) {
            return("")
        }
        return(assemblyString(bytes))
    }
    if (initializerCount(initializer) > length) {
        fail(initializer, format(
                
                "too many elements in initializer for '{}'",
                
                name))
        return("")
    }

    String result = "{"
    int64 count = 0
    int64 i = 0
    while (i < initializer.children.length && problem.equals("")) {

        AstNode value = child(initializer, i)
        if (value.name.equals("assignment")) {
            String literal = literalText(value, arrayElementType)
            if (literal.equals("")) {
                return("")
            }
            if (count > 0) {
                result.append(", ")
            }
            result.append(literal)
            count += 1
        }

        i += 1
    }

    result.append("}")
    return(result)
}
