/*
 * src/grammar_sources.cw — Reads the root grammar, expands includes, and
 * renders diagnostics with include ancestry.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarSources out of src/grammar.cw.
 */

/*
 * Reads the root grammar, expands includes, and renders diagnostics
 * with include ancestry. Line IDs stay unique across files while lexer
 * parsing stays line-local.
 */
class GrammarSources {
    public:
    list paths
    list files
    int64 nextLine
    int64 depth
    String problem
    SourceSpan diagnosticSpan
    SourceSpan relatedSpan
    GrammarDiagnostic diagnosticInfo
    GrammarSources(list searchPaths)

    String location(int64 line)

    String diagnostic(String error)

    String renderLocation(SourceLocation location, int64 endOffset)

    String renderDiagnostic(GrammarDiagnostic diagnostic)

    void load(String path, SourceSpan includeSpan, GrammarModel grammar)

    void includeFile(
            
            String payload,
            
            String parent,
            
            SourceSpan includeSpan,
            

                     GrammarModel grammar)

    GrammarModel read(String path)

    int64 byteSpanBound(int64 value, int64 length)
    String byteSpan(String text, int64 first, int64 last)

}

include "grammar_sources_1.cw"
include "grammar_sources_2.cw"
