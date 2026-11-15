/*
 * examples/insertion/words.cw — Counts words by inserting a visitor
 * into a generated parser.
 *
 * Created: 2026-10-22
 * Author: chuck
 *
 * Changelog:
 *   2026-10-22  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "parser.cw"

start {
    InsertedWords words()
    int64 count = words.count("alpha beta gamma")
    if (count < 0) {
        Sys.StandardIO().writeErrorLine("word parsing or visitor failed")
        Sys.Process().exit(1)
    }
    print(format("words={}\n", count))
}
