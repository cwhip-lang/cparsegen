/*
 * examples/smallc/small_c_asm_array.cw — A fixed array's assembly symbol,
 * element type, and optional static initializer.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCAsmArray out of examples/smallc/smallc_backend.cw.
 */

/*
 * A fixed array's assembly symbol, element type, and optional static
 * initializer.
 */
class SmallCAsmArray {
    public:
    String asmName
    String elementType
    int64 length
    String staticInitializer
    bool isGlobal
    SmallCAsmArray(String symbol, String valueType, int64 capacity)

}

/*
 * Create a SmallCAsmArray and store the values passed to the constructor.
 *
 * symbol: symbol (String). valueType: value type (String). capacity:
 * capacity (int64).
 *
 * Returns the new object.
 */
SmallCAsmArray SmallCAsmArray.SmallCAsmArray(
        String symbol,
        String valueType,
        int64 capacity) {
    asmName = symbol
    elementType = valueType
    length = capacity
    staticInitializer = ""
    isGlobal = false
}
