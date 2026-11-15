/*
 * src/grammar_diagnostic.cw — A grammar error message and the spans that
 * should be printed with it.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarDiagnostic out of src/grammar.cw.
 */

/*
 * A grammar error message and the spans that should be printed with it.
 */
class GrammarDiagnostic {
    public:
    String message
    SourceSpan span
    SourceSpan related
    GrammarDiagnostic(
            
            String text,
            
            SourceSpan location,
            
            SourceSpan relatedLocation)

    int64 byteSpanBound(int64 value, int64 length)
    String byteSpan(String text, int64 first, int64 last)

}

/*
 * Store the message and spans. A leading line-number prefix is stripped from
 * the message text.
 *
 * text: text (String). location: location (SourceSpan). relatedLocation:
 * related location (SourceSpan).
 *
 * Returns the new object.
 */
GrammarDiagnostic GrammarDiagnostic.GrammarDiagnostic(
        
        String text,
        
        SourceSpan location,
        
        SourceSpan relatedLocation) {
    message = text

    if (text.startsWith("line ")) {
        int64 end = 5
        while (end < text.length && int64(text[end]) >= 48 &&
               int64(text[
                
                end]) <= 57) {
            end += 1
        }
        if (end + 1 < text.length) {
            message = byteSpan(text, end + 2, text.length)
        }
    }

    span = location
    related = relatedLocation
}

/*
 * Clamp a byte index into the half-open range from 0 through length. A
 * negative index counts back from length.
 *
 * value: value (int64). length: length (int64).
 *
 * Returns the clamped index, from 0 through length.
 */
int64 GrammarDiagnostic.byteSpanBound(int64 value, int64 length) {
    int64 index = value
    if (index < 0) {
        index = index + length
    }
    if (index < 0) {
        return(0)
    }
    if (index > length) {
        return(length)
    }
    return(index)
}

/*
 * Copy the half-open byte range from first up to but not including last. An
 * empty or reversed range copies nothing.
 *
 * text: text (String). first: first (int64). last: last (int64).
 *
 * Returns the copied bytes, or an empty string when the range is empty.
 */
String GrammarDiagnostic.byteSpan(String text, int64 first, int64 last) {
    int64 lower = byteSpanBound(first, text.length)
    int64 end = byteSpanBound(last, text.length)
    if (end <= lower) {
        return("")
    }
    return(text[lower..(end - 1)])
}
