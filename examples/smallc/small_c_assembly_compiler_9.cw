/*
 * examples/smallc/small_c_assembly_compiler_9.cw — Out-of-line methods for
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
 * Write the emit increment form into the output being generated.
 *
 * lvalue: lvalue (AstNode). postfix: postfix (bool). increment: increment
 * (bool).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAssemblyCompiler.emitIncrement(
        AstNode lvalue,
        bool postfix,
        bool increment) {
    AstNode nameNode = child(lvalue, 0)
    SmallCAsmVariable variable = findVariable(nameNode.text)
    if (variable == null) {
        fail(nameNode, format("undeclared variable '{}'", nameNode.text))
        return("")
    }
    String valueType = elementType(variable.valueType)
    String step = "sub.i32"
    if (increment) {
        step = "add.i32"
    }

    if (!variable.array) {
        String oldSlot = addTemporary(valueType)
        emitLoad(variable)
        code.op1("stloc", oldSlot)
        code.op("pop")
        emitLoad(variable)
        promoteToInt(valueType)
        emitInt(1)
        code.op(step)
        if (valueType.equals("char")) {
            code.op("to.u8")
        }
        emitStore(variable)
        if (postfix) {
            code.op("pop")
            code.op1("ldloc", oldSlot)
        }
        return(valueType)
    }

    String indexSlot = evaluateIndex(lvalue)
    emitArrayReference(variable)
    code.op1("ldloc", indexSlot)
    code.op("aget")
    String oldSlot = addTemporary(valueType)
    code.op1("stloc", oldSlot)
    code.op("pop")
    code.op1("ldloc", oldSlot)
    promoteToInt(valueType)
    emitInt(1)
    code.op(step)
    if (valueType.equals("char")) {
        code.op("to.u8")
    }
    String newSlot = addTemporary(valueType)
    code.op1("stloc", newSlot)
    code.op("pop")
    emitArrayReference(variable)
    code.op1("ldloc", indexSlot)
    code.op1("ldloc", newSlot)
    code.op("aset")
    if (postfix) {
        code.op("pop")
        code.op1("ldloc", oldSlot)
    }
    return(valueType)
}

/*
 * Clamp a byte index into the half-open range from 0 through length. A
 * negative index counts back from length.
 *
 * value: value (int64). length: length (int64).
 *
 * Returns the clamped index, from 0 through length.
 */
int64 SmallCAssemblyCompiler.byteSpanBound(int64 value, int64 length) {
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

/*
 * Copy the half-open byte range from first up to but not including last. An
 * empty or reversed range copies nothing.
 *
 * text: text (String). first: first (int64). last: last (int64).
 *
 * Returns the copied bytes, or an empty string when the range is empty.
 */
String SmallCAssemblyCompiler.byteSpan(String text, int64 first, int64 last) {
    int64 lower = byteSpanBound(first, text.length)
    int64 end = byteSpanBound(last, text.length)
    if (end <= lower) {
        return("")
    }
    return(text[lower..(end - 1)])
}
