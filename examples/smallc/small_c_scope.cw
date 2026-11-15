/*
 * examples/smallc/small_c_scope.cw — Symbols declared in one SmallC block,
 * chained to the enclosing scope.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCScope out of examples/smallc/smallc_frontend.cw.
 */

/*
 * Symbols declared in one SmallC block, chained to the enclosing scope.
 */
class SmallCScope {
    public:
    list symbols
    SmallCScope parent
    SmallCScope(SmallCScope outer)

}

/*
 * Create a SmallCScope and store the values passed to the constructor.
 *
 * outer: outer (SmallCScope).
 *
 * Returns the new object.
 */
SmallCScope SmallCScope.SmallCScope(SmallCScope outer) {
    symbols = []
    parent = outer
}
