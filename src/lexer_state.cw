/*
 * src/lexer_state.cw — One Thompson NFA state compiled from a lexer
 * expression.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split LexerState out of src/grammar.cw.
 */

/*
 * One Thompson NFA state: a byte transition, an epsilon split, or an
 * accepting state.
 */
class LexerState {
    public:
    int64 kind
    list ranges
    int64 next
    int64 alternate
    LexerState(int64 stateKind, list characters, int64 target, int64 other)

}

/*
 * Create a LexerState and store the values passed to the constructor.
 *
 * stateKind: state kind (int64). characters: characters (list). target:
 * target (int64). other: other (int64).
 *
 * Returns the new object.
 */
LexerState LexerState.LexerState(
        int64 stateKind,
        list characters,
        int64 target,
        int64 other) {
    kind = stateKind
    ranges = characters
    next = target
    alternate = other
}
