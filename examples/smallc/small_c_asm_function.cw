/*
 * examples/smallc/small_c_asm_function.cw — A SmallC function lowered to a
 * CVM procedure, including its locals and body.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCAsmFunction out of
 *              examples/smallc/smallc_backend.cw.
 */

/*
 * A SmallC function lowered to a CVM procedure, including its locals and
 * body.
 */
class SmallCAsmFunction {
    public:
    String name
    String asmName
    String returnType
    AstNode declaration
    AstNode parameters
    AstNode body
    list parameterTypes
    list parameterSymbols
    int64 localCount
    list declarations
    bool defined
    SmallCAsmFunction(String functionName, String resultType)

}

/*
 * Create a SmallCAsmFunction and store the values passed to the constructor.
 *
 * functionName: function name (String). resultType: result type (String).
 *
 * Returns the new object.
 */
SmallCAsmFunction SmallCAsmFunction.SmallCAsmFunction(
        String functionName,
        String resultType) {
    name = functionName
    asmName = format("sc_{}", functionName)
    returnType = resultType
    declaration = null
    parameters = null
    body = null
    parameterTypes = []
    parameterSymbols = []
    localCount = 0
    declarations = []
    defined = false
}
