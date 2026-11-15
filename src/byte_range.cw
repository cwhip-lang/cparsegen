/*
 * src/byte_range.cw — An inclusive range of byte values accepted by a
 * character class.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split ByteRange out of src/grammar.cw.
 */

/*
 * An inclusive range of byte values accepted by a character class.
 */
class ByteRange {
    public:
    int64 first
    int64 last
    ByteRange(int64 lower, int64 upper)

}

/*
 * Create a ByteRange and store the values passed to the constructor.
 *
 * lower: lower (int64). upper: upper (int64).
 *
 * Returns the new object.
 */
ByteRange ByteRange.ByteRange(int64 lower, int64 upper) {
    first = lower
    last = upper
}
