/*
 * src/grammar_sources_2.cw — Out-of-line methods for GrammarSources.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarSources methods out of src/grammar.cw while
 *              applying the coding standard.
 */

/*
 * Perform include file for GrammarSources.
 *
 * payload: payload (String). parent: parent (String). includeSpan: include
 * span (SourceSpan). grammar: grammar (GrammarModel).
 *
 * Does not return a value.
 */
void GrammarSources.includeFile(
        
        String payload,
        
        String parent,
        
        SourceSpan includeSpan,
        

                 GrammarModel grammar) {

    int64 line = includeSpan.first.logicalLine
    String name = payload.trim()
    bool valid = name.length > 0
    if (valid) {

        int64 quote = int64(name[0])
        if (quote == 34 || quote == 39) {
            valid = name.length > 2 && int64(name[name.length - 1]) == quote
            if (valid) {
                name = byteSpan(name, 1, name.length - 1)
                int64 i = 0
                while (i < name.length) {
                    if (int64(name[i]) == quote || int64(name[i]) < 32) {
                        valid = false
                    }
                    i += 1
                }
            }
        }
        else {
            int64 i = 0
            while (i < name.length) {
                int64 byte = int64(name[i])
                if (byte <= 32 || byte == 34 || byte == 39) {
                    valid = false
                }
                i += 1
            }
        }

    }

    if (!valid) {
        problem = format(
                "line {}: @include requires exactly one nonempty path (quote paths containing spaces)", line)
        diagnosticSpan = includeSpan
        return
    }
    Sys.FileSystem fs()
    if (name.startsWith("/")) {
        load(name, includeSpan, grammar)
        return
    }
    String candidate = fs.join(fs.dirname(parent), name)
    if (fs.exists(candidate) || fs.isDir(candidate)) {
        load(candidate, includeSpan, grammar)
        return
    }
    int64 i = 0
    while (i < paths.length) {
        candidate = fs.join(paths[i] as String, name)
        if (fs.exists(candidate) || fs.isDir(candidate)) {
            load(candidate, includeSpan, grammar)
            return
        }
        i += 1
    }
    problem = format("line {}: cannot find included grammar {}", line, name)
    diagnosticSpan = includeSpan
}

/*
 * Load the root grammar, expand includes, and return the model. problem is
 * set on failure.
 *
 * path: path (String).
 *
 * Returns the GrammarModel result, or null when the operation fails and this
 * method uses null for that.
 */
GrammarModel GrammarSources.read(String path) {
    GrammarModel grammar()
    load(path, null, grammar)
    if (problem.equals("")) {
        GrammarAnalyzer analyzer(grammar)
        problem = analyzer.run()
        diagnosticSpan = grammar.diagnosticSpan
        relatedSpan = grammar.relatedSpan
        diagnosticInfo = grammar.diagnosticInfo
        if (!problem.equals("") && !problem.startsWith("line ")) {
            problem = format("{}: {}", path, problem)
        }
    }
    return(grammar)
}

/*
 * Clamp a byte index into the half-open range from 0 through length. A
 * negative index counts back from length.
 *
 * value: value (int64). length: length (int64).
 *
 * Returns the clamped index, from 0 through length.
 */
int64 GrammarSources.byteSpanBound(int64 value, int64 length) {
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
String GrammarSources.byteSpan(String text, int64 first, int64 last) {
    int64 lower = byteSpanBound(first, text.length)
    int64 end = byteSpanBound(last, text.length)
    if (end <= lower) {
        return("")
    }
    return(text[lower..(end - 1)])
}
