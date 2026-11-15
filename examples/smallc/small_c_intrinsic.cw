/*
 * examples/smallc/small_c_intrinsic.cw — A compiler-recognized
 * pseudo-function. It has no definition in SmallC source.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCIntrinsic out of
 *              examples/smallc/smallc_frontend.cw.
 */

/*
 * A compiler-recognized pseudo-function. It has no definition or
 * declaration in SmallC source. The checker validates calls against
 * this signature and the CVM backend lowers each one to a single sys
 * service. A void result may only be an expression statement. char[]
 * accepts a char array name or a string literal, and byte accepts char
 * or int.
 */
class SmallCIntrinsic {
    public:
    String name
    String resultType
    list parameterTypes
    String service
    SmallCIntrinsic(
            
            String intrinsicName,
            
            String result,
            
            list parameters,
            

            String serviceName)

}

/*
 * Create a SmallCIntrinsic and store the values passed to the constructor.
 *
 * intrinsicName: intrinsic name (String). result: result (String).
 * parameters: parameters (list). serviceName: service name (String).
 *
 * Returns the new object.
 */
SmallCIntrinsic SmallCIntrinsic.SmallCIntrinsic(
        
        String intrinsicName,
        
        String result,
        
        list parameters,
        

        String serviceName) {
    name = intrinsicName
    resultType = result
    parameterTypes = parameters
    service = serviceName
}
