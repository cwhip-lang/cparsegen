/*
 * examples/smallc/small_c_semantic_checker_5.cw — Out-of-line methods for
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
 * Validate block item and record a problem when it is illegal or
 * unsupported.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.checkBlockItem(AstNode node) {

    int64 i = 0
    while (i < node.children.length && problem.equals("")) {
        AstNode part = child(node, i)
        if (part.name.equals("declaration")) {
            checkDeclaration(part, false)
        }
        else {
            if (part.name.equals("statement")) {
                checkStatement(part)
            }
        }
        i += 1
    }

}

/*
 * Validate switch and record a problem when it is illegal or unsupported.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.checkSwitch(AstNode node) {
    list cases = []
    bool hasDefault = false
    switchDepth += 1

    int64 i = 0
    while (i < node.children.length && problem.equals("")) {

        AstNode part = child(node, i)
        if (part.name.equals("expression")) {
            String valueType = expressionType(part)
            if (!isScalar(valueType)) {
                fail(
                        
                        part,
                        
                        "switch expression must have integral scalar type")
            }
        }
        else {

            if (part.name.equals("switchSection")) {

                AstNode keyword = child(part, 0)
                if (keyword.text.equals("default")) {
                    if (hasDefault) {
                        fail(keyword, "duplicate default label")
                    }
                    hasDefault = true
                }
                else {
                    AstNode value = child(part, 1)
                    String key = caseKey(value)
                    int64 c = 0
                    while (c < cases.length && problem.equals("")) {
                        if ((cases[c] as String).equals(key)) {
                            fail(value, format(
                                    
                                    "duplicate case constant {}",
                                    
                                    key))
                        }
                        c += 1
                    }
                    cases.append(key)
                }

                int64 j = 0
                while (j < part.children.length && problem.equals("")) {
                    AstNode item = child(part, j)
                    if (item.name.equals("blockItem")) {
                        checkBlockItem(item)
                    }
                    j += 1
                }
            }

        }

        i += 1
    }

    switchDepth -= 1
}

/*
 * Validate simple statement and record a problem when it is illegal or
 * unsupported.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.checkSimpleStatement(AstNode node) {
    AstNode keyword = child(node, 0)
    if (keyword.text.equals("break") && loopDepth == 0 && switchDepth == 0) {
        fail(keyword, "break requires an enclosing loop or switch")
    }
    if (keyword.text.equals("continue") && loopDepth == 0) {
        fail(keyword, "continue requires an enclosing loop")
    }
    if (keyword.text.equals("goto")) {
        AstNode target = child(node, 1)
        if (findLabel(target.text) == null) {
            fail(target, format("unresolved goto label '{}'", target.text))
        }
    }

    bool isReturn = false
    AstNode returnedValue = null
    int64 i = 0
    while (i < node.children.length && problem.equals("")) {

        AstNode part = child(node, i)
        if (part.text.equals("return")) {
            isReturn = true
        }
        else {

            if (part.name.equals("expression")) {
                returnedValue = part
                String actual = expressionType(part)
                if (isReturn && problem.equals("")) {
                    exactType(actual, returnType, part, "return value")
                }
            }
            else {
                if (part.name.equals("compoundStatement")) {
                    checkCompound(part, true)
                }
                else {
                    if (part.name.equals("switchStatement")) {
                        checkSwitch(part)
                    }
                }
            }

        }

        i += 1
    }

    if (isReturn && returnedValue == null && problem.equals("")) {
        fail(node, format(
                
                "function returning {} requires a return value",
                
                returnType))
    }
}

/*
 * Validate statement and record a problem when it is illegal or unsupported.
 *
 * node: node (AstNode).
 *
 * Does not return a value.
 */
void SmallCSemanticChecker.checkStatement(AstNode node) {
    if (node.name.equals("compoundStatement")) {
        checkCompound(node, true)
        return
    }
    if (node.name.equals("switchStatement")) {
        checkSwitch(node)
        return
    }
    if (node.name.equals("simpleStatement")) {
        checkSimpleStatement(node)
        return
    }
    bool loopScope = (node.name.equals("matchedStatement") ||
            node.name.equals(
                    "openStatement")) && node.children.length > 0 && child(node,
                            0).text.equals("for")
    bool loop = loopScope || ((node.name.equals("matchedStatement") ||
            node.name.equals("openStatement")) && node.children.length > 0 &&
                    child(node, 0).text.equals("while"))
    if (isLabel(node)) {
        AstNode label = child(node, 0)
        if (findLabel(label.text) != label) {
            fail(label, format("duplicate label '{}'", label.text))
        }
    }
    if (loopScope) {
        pushScope()
    }
    if (loop) {
        loopDepth += 1
    }

    bool inUpdate = false
    int64 i = 0
    while (i < node.children.length && problem.equals("")) {

        AstNode part = child(node, i)
        if (part.name.equals("expression")) {
            String conditionType = expressionType(part)
            if (!(loopScope && inUpdate) && problem.equals("") && !isScalar(
                    
                    conditionType)) {
                fail(part, "condition must have integral scalar type")
            }
        }
        else {
            if (part.text.equals(";") && loopScope) {
                inUpdate = true
            }

            if (part.name.equals("forInitializer")) {
                checkForInitializer(part)
            }
            else {

                if (part.name.equals("compoundStatement")) {
                    checkCompound(part, true)
                }
                else {

                    if (part.name.equals("switchStatement")) {
                        checkSwitch(part)
                    }
                    else {

                        if (part.name.equals("blockItem")) {
                            checkBlockItem(part)
                        }
                        else {
                            if (part.name.equals("simpleStatement")
                                    || part.name.equals(
                                    
                                    "statement")
                                    || part.name.equals(
                                    
                                    "matchedStatement")
                                    || part.name.equals(
                                    
                                    "openStatement")) {
                                checkStatement(part)
                            }
                        }

                    }

                }

            }

        }

        i += 1
    }

    if (loopScope) {
        popScope()
    }
    if (loop) {
        loopDepth -= 1
    }
}

/*
 * Index tokens, walk the tree, and return true only when no semantic problem
 * was recorded.
 *
 * root: root (AstNode). tokens: tokens (list).
 *
 * Returns true on success and false when the operation does not apply or has
 * failed.
 */
bool SmallCSemanticChecker.check(AstNode root, list tokens) {
    problem = ""
    errorOffset = 0
    globals = []
    currentScope = null
    locations = []
    SmallCTokenCursor cursor()
    indexLocations(root, tokens, cursor)

    int64 i = 0
    while (i < root.children.length && problem.equals("")) {
        AstNode external = child(root, i)
        if (external.children.length > 0) {
            AstNode declaration = child(external, 0)
            if (declaration.name.equals("declaration")) {
                checkDeclaration(declaration, true)
            }
            else {
                checkFunction(external)
            }
        }
        i += 1
    }

    return(problem.equals(""))
}

/*
 * Clamp a byte index into the half-open range from 0 through length. A
 * negative index counts back from length.
 *
 * value: value (int64). length: length (int64).
 *
 * Returns the clamped index, from 0 through length.
 */
int64 SmallCSemanticChecker.byteSpanBound(int64 value, int64 length) {
    int64 index = value
    if (index < 0) {
        index = index + length
    }
    if (index < 0) {
        return(0)
    }
    if (index > length) {
        return(length)
    }
    return(index)
}
