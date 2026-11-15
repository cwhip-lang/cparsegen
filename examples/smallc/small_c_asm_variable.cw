/*
 * examples/smallc/small_c_asm_variable.cw — A scalar or array allocated in
 * the assembly, with its storage symbol.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCAsmVariable out of
 *              examples/smallc/smallc_backend.cw.
 */

/*
 * A scalar or array allocated in the assembly, with its storage symbol.
 */
class SmallCAsmVariable {
    public:
    String name
    String valueType
    bool global
    bool array
    int64 index
    String asmName
    SmallCAsmVariable(
            
            String variableName,
            
            String variableType,
            

            bool isGlobal,
            
            bool isArray,
            
            int64 tableIndex,
            
            String symbol)

}

/*
 * Create a SmallCAsmVariable and store the values passed to the constructor.
 *
 * variableName: variable name (String). variableType: variable type
 * (String). isGlobal: true when this value is global (bool). isArray: true
 * when this value is array (bool). tableIndex: table index (int64). symbol:
 * symbol (String).
 *
 * Returns the new object.
 */
SmallCAsmVariable SmallCAsmVariable.SmallCAsmVariable(
        
        String variableName,
        
        String variableType,
        

        bool isGlobal,
        
        bool isArray,
        
        int64 tableIndex,
        
        String symbol) {
    name = variableName
    valueType = variableType
    global = isGlobal
    array = isArray
    index = tableIndex
    asmName = symbol
}
