/*
 * src/file_identity.cw — Asks the host whether two paths name the same
 * file, including links.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split FileIdentity out of src/main.cw.
 */

/*
 * Asks the host whether two paths name the same file, including links.
 */
class FileIdentity {
    public:
    int64 sameFile(String first, String second)
}

int64 FileIdentity.sameFile(String first,
        String second) from "cparsegen_same_file"
