/*
 * src/grammar_emitter_1.cw — Out-of-line methods for GrammarEmitter.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarEmitter methods out of src/emitter.cw while
 *              applying the coding standard.
 */

/*
 * Reads only the shared, already-validated Analysis; it recomputes nothing.
 *
 * model: model (GrammarModel).
 *
 * Returns the new object.
 */
GrammarEmitter GrammarEmitter.GrammarEmitter(GrammarModel model) {
    grammar = model
    analysis = model.analysis
    literals = analysis.literals
    expressions = analysis.expressions
    visitorNames = []
    visitorSuffixes = []
    int64 i = 0
    while (i < analysis.parserRules.length) {
        String name = (analysis.parserRules[i] as ParserRuleFacts).name
        visitorNames.append(name)
        visitorSuffixes.append(format("rule_{}", name))
        i += 1
    }
    i = 0
    while (i < analysis.lexers.length) {
        LexerPlan plan = analysis.lexers[i] as LexerPlan
        if (!plan.skip) {
            visitorNames.append(plan.name)
            visitorSuffixes.append(format("token_{}", plan.name))
        }
        i += 1
    }
    i = 0
    while (i < literals.length) {
        visitorNames.append(literalKind(i))
        visitorSuffixes.append(format("literal_{}", i))
        i += 1
    }
}

/*
 * Return a Cwhip string literal for value, escaping quotes, backslashes, and
 * common controls.
 *
 * value: value (String).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarEmitter.quoted(String value) {

    String result = "\""
    int64 i = 0
    while (i < value.length) {
        int64 byte = int64(value[i])
        if (byte == 34 || byte == 92) {
            result.append("\\")
        }

        if (byte == 10) {
            result.append("\\n")
        }
        else {

            if (byte == 13) {
                result.append("\\r")
            }
            else {
                if (byte == 9) {
                    result.append("\\t")
                }
                else {
                    result.append(byteSpan(value, i, i + 1))
                }
            }

        }

        i += 1
    }

    result.append("\"")
    return(result)
}

/*
 * Perform literal kind for GrammarEmitter.
 *
 * index: index (int64).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarEmitter.literalKind(int64 index) {
    return(format("@literal{}", index))
}

/*
 * Write the emit insertions form into the output being generated.
 *
 * output: output (String). target: target (String). boundary: boundary
 * (String).
 *
 * Does not return a value.
 */
void GrammarEmitter.emitInsertions(
        
        String output,
        
        String target,
        
        String boundary) {
    int64 i = 0
    while (i < grammar.insertions.length) {
        CodeInsertion block = grammar.insertions[i] as CodeInsertion
        if (block.target.equals(target) && block.boundary.equals(boundary)) {
            output.append("\n")
            output.append(block.content)
            output.append("\n")
        }
        i += 1
    }
}

/*
 * Write the emit scanner form into the output being generated.
 *
 * output: output (String).
 *
 * Does not return a value.
 */
void GrammarEmitter.emitScanner(String output) {
    output.append("import system as Sys\n\n")
    emitInsertions(output, "cwhip", "imports")
    emitInsertions(output, "cwhip", "declarations")
    output.append("class LexToken {\n")
    output.append("    public:\n")
    output.append("    String kind\n")
    output.append("    String text\n")
    output.append("    int64 offset\n")
    output.append("    LexToken(String k, String t, int64 at) {\n")
    output.append("        kind = k\n")
    output.append("        text = t\n")
    output.append("        offset = at\n")
    output.append("    }\n")
    output.append("}\n")
    emitInsertions(output, "cwhip", "ast_pre")
    output.append("class AstNode {\n")
    output.append("    public:\n")
    output.append("    String name\n")
    output.append("    String text\n")
    output.append("    list children\n")
    output.append("    AstNode(String n, String t) {\n")
    output.append("        name = n\n")
    output.append("        text = t\n")
    output.append("        children = []\n")
    output.append("    }\n")
    output.append("    String kind() {\n")
    output.append("        return(name)\n")
    output.append("    }\n")
    output.append("    String lexeme() {\n")
    output.append("        return(text)\n")
    output.append("    }\n")
    output.append("    int64 childCount() {\n")
    output.append("        return(children.length)\n")
    output.append("    }\n")
    output.append("    AstNode childAt(int64 index) {\n")
    output.append("        return(children[index] as AstNode)\n")
    output.append("    }\n")
    output.append("    String render() {\n")
    output.append("        String result = \"\"\n")
    output.append("        result.append(name)\n")
    output.append("        result.append(\"(\")\n")
    output.append("        if (children.length == 0) {\n")
    output.append("            result.append(text)\n")
    output.append("        }\n")
    output.append("        int64 i = 0\n")
    output.append("        while (i < children.length) {\n")
    output.append("            if (i > 0) {\n")
    output.append("                result.append(\", \")\n")
    output.append("            }\n")
    output.append(
            "            result.append((children[i] as AstNode).render())\n")
    output.append("            i += 1\n")
    output.append("        }\n")
    output.append("        result.append(\")\")\n")
    output.append("        return(result)\n")
    output.append("    }\n")
    output.append("}\n")
    emitInsertions(output, "cwhip", "ast_post")
    emitInsertions(output, "cwhip", "scanner_pre")
    output.append("class ScanRange {\n")
    output.append("    public:\n")
    output.append("    int64 first\n")
    output.append("    int64 last\n")
    output.append("    ScanRange(int64 a, int64 b) {\n")
    output.append("        first = a\n")
    output.append("        last = b\n")
    output.append("    }\n")
    output.append("}\n")
    output.append("class ScanState {\n")
    output.append("    public:\n")
    output.append("    int64 kind\n")
    output.append("    list ranges\n")
    output.append("    int64 next\n")
    output.append("    int64 alternate\n")
    output.append("    ScanState(int64 k, list r, int64 n, int64 a) {\n")
    output.append("        kind = k\n")
    output.append("        ranges = r\n")
    output.append("        next = n\n")
    output.append("        alternate = a\n")
    output.append("    }\n")
    output.append("    bool accepts(int64 byte) {\n")
    output.append("        int64 i = 0\n")
    output.append("        while (i < ranges.length) {\n")
    output.append("            ScanRange interval = ranges[i] as ScanRange\n")
    output.append(
            "            if (byte >= interval.first && byte <= interval.last) {\n")
    output.append("                return(true)\n")
    output.append("            }\n")
    output.append("            i += 1\n")
    output.append("        }\n")
    output.append("        return(false)\n")
    output.append("    }\n")
    output.append("}\n")
    output.append("class ScanRule {\n")
    output.append("    public:\n")
    output.append("    String name\n")
    output.append("    int64 entry\n")
    output.append("    bool skip\n")
    output.append("    int64 quote\n")
    output.append("    ScanRule(String n, int64 e, bool s, int64 q) {\n")
    output.append("        name = n\n")
    output.append("        entry = e\n")
    output.append("        skip = s\n")
    output.append("        quote = q\n")
    output.append("    }\n")
    output.append("}\n")
    output.append("class InputScanner {\n")
    output.append("    public:\n")
    output.append("    int64 byteSpanBound(int64 value, int64 length) {\n")
    output.append("        int64 index = value\n")
    output.append("        if (index < 0) {\n")
    output.append("            index = index + length\n")
    output.append("        }\n")
    output.append("        if (index < 0) {\n")
    output.append("            return(0)\n")
    output.append("        }\n")
    output.append("        if (index > length) {\n")
    output.append("            return(length)\n")
    output.append("        }\n")
    output.append("        return(index)\n")
    output.append("    }\n")
    output.append(
            "    String byteSpan(String text, int64 first, int64 last) {\n")
    output.append("        int64 lower = byteSpanBound(first, text.length)\n")
    output.append("        int64 end = byteSpanBound(last, text.length)\n")
    output.append("        if (end <= lower) {\n")
    output.append("            return(\"\")\n")
    output.append("        }\n")
    output.append("        return(text[lower..(end - 1)])\n")
    output.append("    }\n")
    output.append("    String input\n")
    output.append("    list tokens\n")
    output.append("    list rules\n")
    output.append("    list states\n")
    output.append("    list lineComments\n")
    output.append("    list blockComments\n")
    output.append("    int64 errorOffset\n")
    output.append("    String problem\n")
    output.append("    int64 steps\n")
    output.append("    InputScanner(String text) {\n")
    output.append("        input = text\n")
    output.append("        tokens = []\n")
    output.append("        rules = []\n")
    output.append("        states = []\n")
    output.append("        lineComments = []\n")
    output.append("        blockComments = []\n")
    output.append("        errorOffset = -1\n")
    output.append("        problem = \"\"\n")
    output.append("        steps = 0\n")
    int64 comment = 0
    while (comment < analysis.lexical.lineComments.length) {
        output.append(format("        lineComments.append({})\n",
                quoted(analysis.lexical.lineComments[
                
                
                comment] as String)))
        comment += 1
    }
    comment = 0

    while (comment < analysis.lexical.blockComments.length) {
        list markers = analysis.lexical.blockComments[comment] as list
        output.append(format("        blockComments.append([{}, {}])\n",
                quoted(markers[
                
                
                0] as String), quoted(markers[
                
                
                1] as String)))
        comment += 1
    }

    int64 s = 0
    while (s < analysis.lexerStates.length) {
        LexerState state = analysis.lexerStates[s] as LexerState
        output.append(format("        list ranges{} = []\n", s))

        int64 n = 0
        while (n < state.ranges.length) {
            ByteRange interval = state.ranges[n] as ByteRange
            output.append(format(
                    
                    
                    "        ranges{}.append(ScanRange({}, {}))\n",
                    
                    
                    s,
                    
                    
                    interval.first,
                    
                    
                    interval.last))
            n += 1
        }

        output.append(format(
                
                
                "        states.append(ScanState({}, ranges{}, {}, {}))\n",
                
                
                state.kind,
                
                
                s,
                
                
                state.next,
                
                
                state.alternate))
        s += 1
    }

    int64 r = 0
    while (r < analysis.lexers.length) {
        LexerPlan rule = analysis.lexers[r] as LexerPlan
        String skipped = "false"
        if (rule.skip) {
            skipped = "true"
        }
        output.append(format("        rules.append(ScanRule({}, {}, {}, {}))\n",
                quoted(
                
                
                rule.name), rule.entry, skipped, rule.quote))
        r += 1
    }

    output.append("    }\n")
    output.append("    bool startsAt(int64 at, String marker) {\n")
    output.append(
            "        return(input.length - at >= marker.length && byteSpan(input, at,\n")
    output.append("                 at + marker.length).equals(marker))\n")
    output.append("    }\n")
    output.append("    int64 skipComment(int64 at) {\n")
    output.append("        int64 c = 0\n")
    output.append("        while (c < lineComments.length) {\n")
    output.append("            String marker = lineComments[c] as String\n")
    output.append("            if (startsAt(at, marker)) {\n")
    output.append("                int64 end = at + marker.length\n")
    output.append(
            "                while (end < input.length && int64(input[end]) != 10 && int64(\n")
    output.append("                        input[end]) != 13) {\n")
    output.append("                    end += 1\n")
    output.append("                }\n")
    output.append("                return(end)\n")
    output.append("            }\n")
    output.append("            c += 1\n")
    output.append("        }\n")
    output.append("        c = 0\n")
    output.append("        while (c < blockComments.length) {\n")
    output.append("            list markers = blockComments[c] as list\n")
    output.append("            String opening = markers[0] as String\n")
    output.append("            String closing = markers[1] as String\n")
    output.append("            if (startsAt(at, opening)) {\n")
    output.append("                int64 end = at + opening.length\n")
    output.append(
            "                while (end < input.length && !startsAt(end, closing)) {\n")
    output.append("                    end += 1\n")
    output.append("                }\n")
    output.append("                if (end == input.length) {\n")
    output.append("                    errorOffset = at\n")
    output.append("                    problem = format(\n")
    output.append(
            "                            \"unterminated block comment at byte {}\",\n")
    output.append("                            at)\n")
    output.append("                    return(-1)\n")
    output.append("                }\n")
    output.append("                return(end + closing.length)\n")
    output.append("            }\n")
    output.append("            c += 1\n")
    output.append("        }\n")
    output.append("        return(at)\n")
    output.append("    }\n")
    output.append("    int64 matchQuote(int64 at, int64 quote) {\n")
    output.append("        if (int64(input[at]) != quote) {\n")
    output.append("            return(-1)\n")
    output.append("        }\n")
    output.append("        int64 end = at + 1\n")
    output.append("        int64 characters = 0\n")
    output.append(
            "        while (end < input.length && int64(input[end]) != quote) {\n")
    output.append("            int64 byte = int64(input[end])\n")
    output.append("            if (byte < 32 || byte > 126) {\n")
    output.append("                break\n")
    output.append("            }\n")
    output.append("            if (byte == 92) {\n")
    output.append("                end += 1\n")
    output.append("                if (end == input.length) {\n")
    output.append("                    break\n")
    output.append("                }\n")
    output.append("                byte = int64(input[end])\n")
    output.append(
            "                if (byte != 92 && byte != 34 && byte != 39 &&\n")
    output.append(
            "                        byte != 110 && byte != 114 &&\n")
    output.append("                        byte != 116 && byte != 48) {\n")
    output.append("                    errorOffset = end\n")
    output.append(
            "                    problem = format(\"invalid quoted escape at byte {}\", end)\n")
    output.append("                    return(-1)\n")
    output.append("                }\n")
    output.append("            }\n")
    output.append("            characters += 1\n")
    output.append("            end += 1\n")
    output.append("        }\n")
    output.append(
            "        if (end >= input.length || int64(input[end]) != quote) {\n")
    output.append("            errorOffset = at\n")
    output.append(
            "            problem = format(\"unterminated quoted token at byte {}\", at)\n")
    output.append("            return(-1)\n")
    output.append("        }\n")
    output.append("        if (quote == 39 && characters != 1) {\n")
    output.append("            errorOffset = at\n")
    output.append("            problem = format(\n")
    output.append(
            "                    \"character literal must contain one byte or escape at byte {}\",\n")
    output.append("                    at)\n")
    output.append("            return(-1)\n")
    output.append("        }\n")
    output.append("        return(end + 1)\n")
    output.append("    }\n")
    output.append("    void addState(list active, list seen, int64 index) {\n")
    output.append("        if (index >= 0 && !(seen[index] as bool)) {\n")
    output.append("            seen[index] = true\n")
    output.append("            active.append(index)\n")
    output.append("        }\n")
    output.append("    }\n")
    output.append("    bool closure(list active, list seen) {\n")
    output.append("        int64 i = 0\n")
    output.append("        while (i < active.length) {\n")
    output.append("            steps += 1\n")
    output.append("            if (steps > 100000) {\n")
    output.append(
            "                problem = \"scanner resource limit exceeded\"\n")
    output.append("                return(false)\n")
    output.append("            }\n")
    output.append(
            "            ScanState state = states[active[i] as int64] as ScanState\n")
    output.append("            if (state.kind == 1) {\n")
    output.append("                addState(active, seen, state.next)\n")
    output.append("                addState(active, seen, state.alternate)\n")
    output.append("            }\n")
    output.append("            i += 1\n")
    output.append("        }\n")
    output.append("        return(true)\n")
    output.append("    }\n")
    output.append("    int64 matchStates(int64 entry, int64 offset) {\n")
    output.append("        list active = []\n")
    output.append("        list seen = []\n")
    output.append("        int64 s = 0\n")
    output.append("        while (s < states.length) {\n")
    output.append("            seen.append(false)\n")
    output.append("            s += 1\n")
    output.append("        }\n")
    output.append("        addState(active, seen, entry)\n")
    output.append("        int64 best = -1\n")
    output.append("        int64 at = offset\n")
    output.append("        while (active.length > 0) {\n")
    output.append("            if (!closure(active, seen)) {\n")
    output.append("                return(-1)\n")
    output.append("            }\n")
    output.append("            list next = []\n")
    output.append("            s = 0\n")
    output.append("            while (s < seen.length) {\n")
    output.append("                seen[s] = false\n")
    output.append("                s += 1\n")
    output.append("            }\n")
    output.append("            s = 0\n")
    output.append("            while (s < active.length) {\n")
    output.append(
            "                ScanState state = states[active[s] as int64] as ScanState\n")
    output.append("                if (state.kind == 2) {\n")
    output.append("                    best = at\n")
    output.append("                }\n")
    output.append(
            "                if (state.kind == 0 && at < input.length && state.accepts(\n")
    output.append("                        int64(input[at]))) {\n")
    output.append("                    addState(next, seen, state.next)\n")
    output.append("                }\n")
    output.append("                s += 1\n")
    output.append("            }\n")
    output.append("            if (at == input.length) {\n")
    output.append("                return(best)\n")
    output.append("            }\n")
    output.append("            active = next\n")
    output.append("            at += 1\n")
    output.append("        }\n")
    output.append("        return(best)\n")
    output.append("    }\n")
    output.append("    bool scan() {\n")
    output.append("        tokens = []\n")
    output.append("        errorOffset = -1\n")
    output.append("        problem = \"\"\n")
    output.append("        int64 i = 0\n")
    output.append("        while (i < input.length) {\n")
    output.append("            int64 afterComment = skipComment(i)\n")
    output.append("            if (afterComment < 0) {\n")
    output.append("                return(false)\n")
    output.append("            }\n")
    output.append("            if (afterComment > i) {\n")
    output.append("                i = afterComment\n")
    output.append("            }\n")
    output.append("            else {\n")
    output.append("                int64 bestEnd = i\n")
    output.append("                String bestKind = \"\"\n")
    output.append("                bool skip = false\n")
    output.append("                int64 r = 0\n")
    output.append("                steps = 0\n")
    output.append("                while (r < rules.length) {\n")
    output.append("                    ScanRule rule = rules[r] as ScanRule\n")
    output.append("                    int64 end = -1\n")
    output.append("                    if (rule.quote != 0) {\n")
    output.append("                        end = matchQuote(i, rule.quote)\n")
    output.append("                    }\n")
    output.append("                    else {\n")
    output.append("                        end = matchStates(rule.entry, i)\n")
    output.append("                    }\n")
    output.append("                    if (!problem.equals(\"\")) {\n")
    output.append("                        if (errorOffset < 0) {\n")
    output.append("                            errorOffset = i\n")
    output.append("                        }\n")
    output.append("                        return(false)\n")
    output.append("                    }\n")
    output.append("                    if (end > bestEnd) {\n")
    output.append("                        bestEnd = end\n")
    output.append("                        bestKind = rule.name\n")
    output.append("                        skip = rule.skip\n")
    output.append("                    }\n")
    output.append("                    r += 1\n")
    output.append("                }\n")

    int64 lit = 0
    while (lit < literals.length) {
        String value = literals[lit] as String
        output.append(format(
                
                "            if (input.length - i >= {} &&\n",
                
                value.length))
        output.append(format(
                "                    byteSpan(input, i, i + {}).equals({}) &&\n",
                value.length, quoted(
                value)))
        output.append(format(
                
                "                    i + {} > bestEnd) {{\n",
                
                value.length))
        output.append(
                format("                bestEnd = i + {}\n", value.length))
        output.append(format("                bestKind = {}\n",
                quoted(literalKind(
                lit))))
        output.append("                skip = false\n")
        output.append("            }\n")
        lit += 1
    }

    if (!analysis.lexical.keywordToken.equals("")) {
        output.append(format("            if (bestKind.equals({})) {{\n",
                quoted(
                
                analysis.lexical.keywordToken)))
        output.append(
                "                String word = byteSpan(input, i, bestEnd)\n")
        lit = 0
        while (lit < literals.length) {
            output.append(format("                if (word.equals({})) {{\n",
                    quoted(literals[
                    
                    lit] as String)))
            output.append(format("                    bestKind = {}\n",
                    quoted(literalKind(
                    
                    lit))))
            output.append("                }\n")
            lit += 1
        }
        lit = 0
        while (lit < analysis.lexical.reserved.length) {
            output.append(format("                if (word.equals({})) {{\n",
                    quoted(
                    analysis.lexical.reserved[
                    lit] as String)))
            output.append("                    bestKind = \"@reserved\"\n")
            output.append("                }\n")
            lit += 1
        }
        output.append("            }\n")
    }

    output.append("            if (bestEnd == i) {\n")
    output.append("                errorOffset = i\n")
    output.append(
            "                problem = format(\"lex error at byte {}\", i)\n")
    output.append("                return(false)\n")
    output.append("            }\n")
    output.append("            if (!skip) {\n")
    output.append(
            "                tokens.append(LexToken(bestKind, byteSpan(input, i, bestEnd),\n")
    output.append("                         i))\n")
    output.append("            }\n")
    output.append("            i = bestEnd\n")
    output.append("        }\n")
    output.append("    }\n")
    output.append("    return(true)\n")
    output.append("}\n")
    output.append("}\n")
}
