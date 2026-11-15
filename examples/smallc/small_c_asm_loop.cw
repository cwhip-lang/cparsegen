/*
 * examples/smallc/small_c_asm_loop.cw — Break and continue labels for the
 * loop currently being lowered.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCAsmLoop out of examples/smallc/smallc_backend.cw.
 */

/*
 * Break and continue labels for the loop currently being lowered.
 */
class SmallCAsmLoop {
    public:
    String breakLabel
    String continueLabel
    SmallCAsmLoop parent
    SmallCAsmLoop(
            
            String breakTarget,
            
            String continueTarget,
            

            SmallCAsmLoop outer)

}

/*
 * Create a SmallCAsmLoop and store the values passed to the constructor.
 *
 * breakTarget: break target (String). continueTarget: continue target
 * (String). outer: outer (SmallCAsmLoop).
 *
 * Returns the new object.
 */
SmallCAsmLoop SmallCAsmLoop.SmallCAsmLoop(
        
        String breakTarget,
        
        String continueTarget,
        

        SmallCAsmLoop outer) {
    breakLabel = breakTarget
    continueLabel = continueTarget
    parent = outer
}
