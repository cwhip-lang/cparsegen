/*
 * examples/smallc/small_c_asm_scope.cw — One block's local variables,
 * chained to the enclosing scope.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCAsmScope out of examples/smallc/smallc_backend.cw.
 */

/*
 * One block's local variables, chained to the enclosing scope.
 */
class SmallCAsmScope {
    public:
    list variables
    SmallCAsmScope parent
    SmallCAsmScope(SmallCAsmScope outer)

}

/*
 * Create a SmallCAsmScope and store the values passed to the constructor.
 *
 * outer: outer (SmallCAsmScope).
 *
 * Returns the new object.
 */
SmallCAsmScope SmallCAsmScope.SmallCAsmScope(SmallCAsmScope outer) {
    variables = []
    parent = outer
}
