/*
 * examples/smallc/small_c_intrinsics.cw — The fixed catalog of SmallC built-
 * ins such as print, open, read, write, and close.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCIntrinsics out of
 *              examples/smallc/smallc_frontend.cw.
 */

/*
 * The fixed catalog of SmallC built-ins such as print, open, read, write,
 * and close.
 */
class SmallCIntrinsics {
    public:
    list entries
    SmallCIntrinsics()

    SmallCIntrinsic find(String name)

}

/*
 * Create a SmallCIntrinsics and store the values passed to the constructor.
 *
 * Returns the new object.
 */
SmallCIntrinsics SmallCIntrinsics.SmallCIntrinsics() {
    entries = []
    entries.append(SmallCIntrinsic(
            "print",
            "void",
            [
            "char[]"],
            "stdout_write"))
    entries.append(SmallCIntrinsic(
            "open",
            "int",
            [
            "char[]",
            "char[]"],
            "file_open"))
    entries.append(SmallCIntrinsic(
            "read",
            "int",
            [
            "int",
            "int",
            "char[]"],
            "file_read_handle"))
    entries.append(SmallCIntrinsic(
            "write",
            "int",
            [
            "int",
            "int",
            "char[]"],
            "file_write_handle"))
    entries.append(SmallCIntrinsic(
            "close",
            "void",
            [
            "int"],
            "file_close_handle"))
}

/*
 * Return the matching value, or null when nothing matches.
 *
 * name: name (String).
 *
 * Returns the SmallCIntrinsic result, or null when the operation fails and
 * this method uses null for that.
 */
SmallCIntrinsic SmallCIntrinsics.find(String name) {
    int64 i = 0
    while (i < entries.length) {
        SmallCIntrinsic entry = entries[i] as SmallCIntrinsic
        if (entry.name.equals(name)) {
            return(entry)
        }
        i += 1
    }
    return(null)
}
