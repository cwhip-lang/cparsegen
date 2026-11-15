/*
 * examples/smallc/small_c_symbol.cw — A variable, parameter, or function
 * visible to the semantic checker.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCSymbol out of examples/smallc/smallc_frontend.cw.
 */

/*
 * A variable, parameter, or function visible to the semantic checker.
 */
class SmallCSymbol {
    public:
    String name
    String kind
    String valueType
    list parameterTypes
    bool hasPrototype
    bool hasDefinition
    SmallCSymbol(String symbolName, String symbolKind, String symbolType)

}

/*
 * Create a SmallCSymbol and store the values passed to the constructor.
 *
 * symbolName: symbol name (String). symbolKind: symbol kind (String).
 * symbolType: symbol type (String).
 *
 * Returns the new object.
 */
SmallCSymbol SmallCSymbol.SmallCSymbol(
        String symbolName,
        String symbolKind,
        String symbolType) {
    name = symbolName
    kind = symbolKind
    valueType = symbolType
    parameterTypes = []
    hasPrototype = false
    hasDefinition = false
}
