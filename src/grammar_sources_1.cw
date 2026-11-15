/*
 * src/grammar_sources_1.cw — Out-of-line methods for GrammarSources.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarSources methods out of src/grammar.cw while
 *              applying the coding standard.
 */

/*
 * Create a GrammarSources and store the values passed to the constructor.
 *
 * searchPaths: search paths (list).
 *
 * Returns the new object.
 */
GrammarSources GrammarSources.GrammarSources(list searchPaths) {
    paths = searchPaths
    files = []
    nextLine = 1
    depth = 0
    problem = ""
    diagnosticSpan = null
    relatedSpan = null
    diagnosticInfo = null
}

/*
 * Perform location for GrammarSources.
 *
 * line: line (int64).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarSources.location(int64 line) {

    int64 i = 0
    while (i < files.length) {
        GrammarSource file = files[i] as GrammarSource
        if (line >= file.firstLine && line < file.firstLine + file.lineCount) {
            return(format(
                    
                    "{}: line {}",
                    
                    file.displayPath,
                    
                    line - file.firstLine + 1))
        }
        i += 1
    }

    return("grammar")
}

/*
 * Format error with the current diagnostic spans and include ancestry.
 *
 * error: error (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarSources.diagnostic(String error) {
    if (diagnosticInfo == null && diagnosticSpan != null) {
        diagnosticInfo = GrammarDiagnostic(error, diagnosticSpan, relatedSpan)
    }
    if (diagnosticInfo != null) {
        return(renderDiagnostic(diagnosticInfo))
    }
    if (!error.startsWith("line ")) {
        return(error)
    }
    int64 end = 5
    int64 line = 0
    while (end < error.length && int64(error[end]) >= 48 && int64(
            error[
            end]) <= 57) {
        line = line * 10 + int64(error[end]) - 48
        end += 1
    }

    String result = format("{}{}", location(line), byteSpan(error, end,
            error.length))
    while (line != 0) {
        int64 parent = 0
        int64 i = 0
        while (i < files.length) {
            GrammarSource file = files[i] as GrammarSource
            if (line >= file.firstLine &&
                    line < file.firstLine + file.lineCount) {
                parent = file.includedAt
                break
            }
            i += 1
        }
        if (parent != 0) {
            result.append(format("\n  included from {}", location(parent)))
        }
        line = parent
    }

    return(result)
}

/*
 * Perform render location for GrammarSources.
 *
 * location: location (SourceLocation). endOffset: end offset (int64).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarSources.renderLocation(SourceLocation location, int64 endOffset) {
    return(format(
            
            "{}:{}:{}: bytes {}-{}",
            
            location.displayPath,
            
            location.line,
            
            
                  location.column,
            
            location.offset,
            
            endOffset))
}

/*
 * Format one diagnostic, including up to eight included-from sites.
 *
 * diagnostic: diagnostic (GrammarDiagnostic).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarSources.renderDiagnostic(GrammarDiagnostic diagnostic) {
    if (diagnostic.span == null) {
        return(diagnostic.message)
    }
    SourceSpan span = diagnostic.span
    String result = format("{}: {}", renderLocation(span.first,
            span.last.offset),
                           diagnostic.message)
    if (diagnostic.related != null) {
        result.append(format("\n  related: {}", renderLocation(
                
                
            diagnostic.related.first,
                
                diagnostic.related.last.offset)))
    }

    SourceLocation parent = span.first.includedFrom
    int64 count = 0
    while (parent != null && count < 8) {
        result.append(format(
                
                "\n  included from {}:{}:{}: byte {}",
                
                
            parent.displayPath,
                
                parent.line,
                
                parent.column,
                
                parent.offset))
        parent = parent.includedFrom
        count += 1
    }

    if (parent != null) {
        result.append("\n  included from ...")
    }
    return(result)
}

/*
 * Perform load for GrammarSources.
 *
 * path: path (String). includeSpan: include span (SourceSpan). grammar:
 * grammar (GrammarModel).
 *
 * Does not return a value.
 */
void GrammarSources.load(
        String path,
        SourceSpan includeSpan,
        GrammarModel grammar) {
    Sys.FileSystem fs()
    String absolute = fs.absolutePath(path)
    int64 includedAt = 0
    SourceLocation includedFrom = null
    if (includeSpan != null) {
        includedAt = includeSpan.first.logicalLine
        includedFrom = includeSpan.first
    }

    int64 i = 0
    while (i < files.length) {
        GrammarSource previous = files[i] as GrammarSource
        if (previous.path.equals(absolute)) {
            if (previous.active) {
                problem = format("line {}: include cycle involving {}",
                        includedAt, absolute)
                diagnosticSpan = includeSpan
            }
            return
        }
        i += 1
    }

    if (depth >= 128 || files.length >= 1024) {
        problem = format(
                "line {}: grammar include limit exceeded (128 levels, 1024 files)", includedAt)
        diagnosticSpan = includeSpan
        return
    }
    if (!fs.isFile(absolute)) {
        problem = format("{}: expected a readable regular grammar file",
                absolute)
        if (includedAt != 0) {
            problem = format("line {}: {}", includedAt, problem)
        }
        diagnosticSpan = includeSpan
        return
    }
    String source = ""
    try {
        Sys.File file(absolute, "r")
        source = file.readAll()
        file.close()
        if (source.length != fs.fileSize(absolute)) {
            problem = format("{}: incomplete grammar read", absolute)
        }
    }
    except() as error {
        problem = format("{}: {}", absolute, error)
    }
    if (!problem.equals("")) {
        if (includedAt != 0) {
            problem = format("line {}: {}", includedAt, problem)
        }
        diagnosticSpan = includeSpan
        return
    }
    int64 count = 1
    i = 0

    bool previousCR = false
    while (i < source.length) {

        int64 value = int64(source[i])
        if (value == 13) {
            count += 1
            previousCR = true
        }
        else {
            if (value == 10) {
                if (!previousCR) {
                    count += 1
                }
                previousCR = false
            }
            else {
                previousCR = false
            }
        }

        i += 1
    }

    GrammarSource file(absolute, nextLine, count, includedFrom)
    if (includedAt == 0) {
        file.displayPath = path
    }
    else {
        file.displayPath = absolute
    }
    files.append(file)
    nextLine += count + 1
    depth += 1

    GrammarReader reader(
            
            source,
            
            file.firstLine,
            
            absolute,
            
            file.displayPath,
            
            includedFrom)
    while (problem.equals("")) {
        reader.readInto(grammar)
        problem = reader.problem
        if (!problem.equals("")) {
            diagnosticSpan = reader.problemSpan
            diagnosticInfo = reader.diagnosticInfo
        }
        if (!problem.equals("") || reader.inclusion == null) {
            break
        }
        includeFile(
                
                reader.inclusion.text,
                
                absolute,
                
                reader.inclusion.span,
                
                grammar)
    }

    depth -= 1
    file.active = false
}
