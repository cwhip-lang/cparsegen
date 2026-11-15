/*
 * src/grammar_emitter_2.cw — Out-of-line methods for GrammarEmitter.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarEmitter methods out of src/emitter.cw while
 *              applying the coding standard.
 */

/*
 * Write the emit parser form into the output being generated.
 *
 * output: output (String).
 *
 * Does not return a value.
 */
void GrammarEmitter.emitParser(String output) {
    output.append("class ParserExpr {\n")
    output.append("    public:\n")
    output.append("    int64 kind\n")
    output.append("    String value\n")
    output.append("    list children\n")
    output.append("    int64 minimum\n")
    output.append("    int64 maximum\n")
    output.append("    int64 required\n")
    output.append(
            "    ParserExpr(int64 k, String v, list c, int64 a, int64 b, int64 r) {\n")
    output.append("        kind = k\n")
    output.append("        value = v\n")
    output.append("        children = c\n")
    output.append("        minimum = a\n")
    output.append("        maximum = b\n")
    output.append("        required = r\n")
    output.append("    }\n")
    output.append("}\n")
    output.append("class ParserRuleDef {\n")
    output.append("    public:\n")
    output.append("    String name\n")
    output.append("    ParserExpr expression\n")
    output.append("    ParserRuleDef(String n, ParserExpr e) {\n")
    output.append("        name = n\n")
    output.append("        expression = e\n")
    output.append("    }\n")
    output.append("}\n")
    output.append("class ParseResult {\n")
    output.append("    public:\n")
    output.append("    int64 end\n")
    output.append("    list nodes\n")
    output.append("    ParseResult(int64 at, list children) {\n")
    output.append("        end = at\n")
    output.append("        nodes = children\n")
    output.append("    }\n")
    output.append("}\n")
    output.append("class GeneratedParser {\n")
    output.append("    public:\n")
    output.append("    list tokens\n")
    output.append("    list rules\n")
    output.append("    int64 position\n")
    output.append("    int64 errorPosition\n")
    output.append("    int64 steps\n")
    output.append("    int64 endLimit\n")
    output.append("    String problem\n")
    output.append("    GeneratedParser(list inputTokens) {\n")
    output.append("        tokens = inputTokens\n")
    output.append("        rules = []\n")
    output.append("        position = 0\n")
    output.append("        errorPosition = 0\n")
    output.append("        steps = 0\n")
    output.append("        endLimit = tokens.length\n")
    output.append("        problem = \"\"\n")

    int64 i = 0
    while (i < expressions.length) {
        ParserExprRecord expression = expressions[i] as ParserExprRecord
        String children = "["
        int64 c = 0
        while (c < expression.children.length) {
            if (c > 0) {
                children.append(", ")
            }
            children.append(format("e{}", expression.children[c] as int64))
            c += 1
        }
        children.append("]")
        String value = expression.value
        if (expression.kind == 1) {
            value = literalKind(expression.literal)
        }
        output.append(format(
                "        ParserExpr e{} = ParserExpr({}, {}, {}, {}, {}, {})\n",
            i, expression.kind, quoted(
                
                
                value), children, expression.minimum, expression.maximum,
                        expression.required))
        i += 1
    }

    i = 0
    while (i < analysis.parserRules.length) {
        ParserRuleFacts rule = analysis.parserRules[i] as ParserRuleFacts
        output.append(format("        rules.append(ParserRuleDef({}, e{}))\n",
                quoted(
                
                
                rule.name), rule.root))
        i += 1
    }
    output.append("    }\n")
    output.append("    list joined(list first, list second) {\n")
    output.append("        list result = []\n")
    output.append("        int64 i = 0\n")
    output.append("        while (i < first.length) {\n")
    output.append("            result.append(first[i])\n")
    output.append("            i += 1\n")
    output.append("        }\n")
    output.append("        i = 0\n")
    output.append("        while (i < second.length) {\n")
    output.append("            result.append(second[i])\n")
    output.append("            i += 1\n")
    output.append("        }\n")
    output.append("        return(result)\n")
    output.append("    }\n")
    output.append("    void addResult(list results, ParseResult value) {\n")
    output.append("        if (results.length >= 4096) {\n")
    output.append("            problem = \"parser result limit exceeded\"\n")
    output.append("            return\n")
    output.append("        }\n")
    output.append("        results.append(value)\n")
    output.append("    }\n")
    output.append("    list matchRule(String name, int64 at, int64 depth) {\n")
    output.append("        list results = []\n")
    output.append("        int64 i = 0\n")
    output.append("        while (i < rules.length) {\n")
    output.append(
            "            ParserRuleDef rule = rules[i] as ParserRuleDef\n")
    output.append("            if (rule.name.equals(name)) {\n")
    output.append(
            "                list matches = match(rule.expression, at, depth + 1)\n")
    output.append("                int64 m = 0\n")
    output.append(
            "                while (m < matches.length && problem.equals(\"\")) {\n")
    output.append(
            "                    ParseResult found = matches[m] as ParseResult\n")
    output.append("                    AstNode node = AstNode(name, \"\")\n")
    output.append("                    node.children = found.nodes\n")
    output.append(
            "                    addResult(results, ParseResult(found.end, [node]))\n")
    output.append("                    m += 1\n")
    output.append("                }\n")
    output.append("                return(results)\n")
    output.append("            }\n")
    output.append("            i += 1\n")
    output.append("        }\n")
    output.append("        return(results)\n")
    output.append("    }\n")
    output.append(
            "    list match(ParserExpr expression, int64 at, int64 depth) {\n")
    output.append("        list results = []\n")
    output.append("        if (!problem.equals(\"\")) {\n")
    output.append("            return(results)\n")
    output.append("        }\n")
    output.append("        steps += 1\n")
    output.append("        if (steps > 100000 || depth > 256) {\n")
    output.append("            problem = \"parser resource limit exceeded\"\n")
    output.append("            return(results)\n")
    output.append("        }\n")
    output.append("        if (at > errorPosition) {\n")
    output.append("            errorPosition = at\n")
    output.append("        }\n")
    output.append(
            "        if (at > endLimit || expression.required > endLimit - at) {\n")
    output.append("            return(results)\n")
    output.append("        }\n")
    output.append(
            "        if (expression.kind == 0 || expression.kind == 1) {\n")
    output.append("            if (expression.kind == 0) {\n")
    output.append(
            "                list nested = matchRule(expression.value, at, depth)\n")
    output.append(
            "                if (nested.length > 0 || !problem.equals(\"\")) {\n")
    output.append("                    return(nested)\n")
    output.append("                }\n")
    output.append("                int64 r = 0\n")
    output.append("                while (r < rules.length) {\n")
    output.append(
            "                    if ((rules[r] as ParserRuleDef).name.equals(\n")
    output.append("                            expression.value)) {\n")
    output.append("                        return(results)\n")
    output.append("                    }\n")
    output.append("                    r += 1\n")
    output.append("                }\n")
    output.append("            }\n")
    output.append("            if (at < endLimit) {\n")
    output.append("                LexToken token = tokens[at] as LexToken\n")
    output.append(
            "                if (token.kind.equals(expression.value)) {\n")
    output.append(
            "                    addResult(results, ParseResult(at + 1, [AstNode(token.kind,\n")
    output.append("                             token.text)]))\n")
    output.append("                }\n")
    output.append("            }\n")
    output.append("            return(results)\n")
    output.append("        }\n")
    output.append("        if (expression.kind == 3) {\n")
    output.append("            int64 c = 0\n")
    output.append(
            "            while (c < expression.children.length && problem.equals(\"\")) {\n")
    output.append(
            "                list alternatives = match(expression.children[c] as ParserExpr,\n")
    output.append("                         at, depth)\n")
    output.append("                int64 a = 0\n")
    output.append(
            "                while (a < alternatives.length && problem.equals(\"\")) {\n")
    output.append(
            "                    addResult(results, alternatives[a] as ParseResult)\n")
    output.append("                    a += 1\n")
    output.append("                }\n")
    output.append("                c += 1\n")
    output.append("            }\n")
    output.append("            return(results)\n")
    output.append("        }\n")
    output.append("        list states = [ParseResult(at, [])]\n")
    output.append("        if (expression.kind == 2) {\n")
    output.append("            int64 limit = endLimit\n")
    output.append("            int64 remaining = 0\n")
    output.append("            int64 c = 0\n")
    output.append("            while (c < expression.children.length) {\n")
    output.append(
            "                remaining += (expression.children[c] as ParserExpr).required\n")
    output.append("                c += 1\n")
    output.append("            }\n")
    output.append("            c = 0\n")
    output.append(
            "            while (c < expression.children.length &&\n")
    output.append(
            "                    states.length > 0 && problem.equals(\"\")) {\n")
    output.append(
            "                ParserExpr child = expression.children[c] as ParserExpr\n")
    output.append("                remaining -= child.required\n")
    output.append("                list next = []\n")
    output.append("                int64 s = 0\n")
    output.append(
            "                while (s < states.length && problem.equals(\"\")) {\n")
    output.append(
            "                    ParseResult state = states[s] as ParseResult\n")
    output.append("                    if (remaining <= limit - state.end) {\n")
    output.append("                        endLimit = limit - remaining\n")
    output.append(
            "                        list matches = match(child, state.end, depth)\n")
    output.append("                        endLimit = limit\n")
    output.append("                        int64 m = 0\n")
    output.append(
            "                        while (m < matches.length && problem.equals(\"\")) {\n")
    output.append(
            "                            ParseResult found = matches[m] as ParseResult\n")
    output.append(
            "                            addResult(next, ParseResult(found.end, joined(\n")
    output.append(
            "                                    state.nodes, found.nodes)))\n")
    output.append("                            m += 1\n")
    output.append("                        }\n")
    output.append("                    }\n")
    output.append("                    s += 1\n")
    output.append("                }\n")
    output.append("                states = next\n")
    output.append("                c += 1\n")
    output.append("            }\n")
    output.append("            return(states)\n")
    output.append("        }\n")
    output.append("        if (expression.minimum == 0) {\n")
    output.append("            addResult(results, states[0] as ParseResult)\n")
    output.append("        }\n")
    output.append("        int64 count = 0\n")
    output.append(
            "        while (states.length > 0 &&\n")
    output.append(
            "                (expression.maximum < 0 || count < expression.maximum) &&\n")
    output.append("                problem.equals(\"\")) {\n")
    output.append("            list next = []\n")
    output.append("            int64 s = 0\n")
    output.append(
            "            while (s < states.length && problem.equals(\"\")) {\n")
    output.append(
            "                ParseResult state = states[s] as ParseResult\n")
    output.append(
            "                list matches = match(expression.children[0] as ParserExpr,\n")
    output.append("                         state.end, depth)\n")
    output.append("                int64 m = 0\n")
    output.append(
            "                while (m < matches.length && problem.equals(\"\")) {\n")
    output.append(
            "                    ParseResult found = matches[m] as ParseResult\n")
    output.append("                    if (found.end <= state.end) {\n")
    output.append(
            "                        problem = \"nullable repetition reached parser\"\n")
    output.append("                        return([])\n")
    output.append("                    }\n")
    output.append(
            "                    addResult(next, ParseResult(found.end, joined(state.nodes,\n")
    output.append("                             found.nodes)))\n")
    output.append("                    m += 1\n")
    output.append("                }\n")
    output.append("                s += 1\n")
    output.append("            }\n")
    output.append("            count += 1\n")
    output.append("            if (count >= expression.minimum) {\n")
    output.append("                int64 n = 0\n")
    output.append(
            "                while (n < next.length && problem.equals(\"\")) {\n")
    output.append(
            "                    addResult(results, next[n] as ParseResult)\n")
    output.append("                    n += 1\n")
    output.append("                }\n")
    output.append("            }\n")
    output.append("            states = next\n")
    output.append("        }\n")
    output.append("        return(results)\n")
    output.append("    }\n")
    output.append("    AstNode select(String name, bool complete) {\n")
    output.append("        problem = \"\"\n")
    output.append("        errorPosition = position\n")
    output.append("        steps = 0\n")
    output.append("        endLimit = tokens.length\n")
    output.append("        list matches = matchRule(name, position, 0)\n")
    output.append("        if (!problem.equals(\"\")) {\n")
    output.append("            return(null)\n")
    output.append("        }\n")
    output.append("        ParseResult best = null\n")
    output.append("        int64 i = 0\n")
    output.append("        while (i < matches.length) {\n")
    output.append("            ParseResult found = matches[i] as ParseResult\n")
    output.append(
            "            if ((!complete || found.end == tokens.length) &&\n")
    output.append(
            "                    (best == null || found.end < best.end)) {\n")
    output.append("                best = found\n")
    output.append("            }\n")
    output.append("            i += 1\n")
    output.append("        }\n")
    output.append("        if (best == null) {\n")
    output.append(
            "            problem = format(\"parse error at token {}\", errorPosition)\n")
    output.append("            return(null)\n")
    output.append("        }\n")
    output.append("        position = best.end\n")
    output.append("        return(best.nodes[0] as AstNode)\n")
    output.append("    }\n")
    ParserRule startRule = grammar.parserRules[0] as ParserRule
    output.append("    AstNode parseAll() {\n")
    output.append(format("        return(select({}, true))\n", quoted(
            startRule.name)))
    output.append("    }\n")
    i = 0
    while (i < grammar.parserRules.length) {
        ParserRule rule = grammar.parserRules[i] as ParserRule
        output.append(format("    AstNode parse_{}() {{\n", rule.name))
        output.append(format("        return(select({}, false))\n", quoted(
                rule.name)))
        output.append("    }\n")
        i += 1
    }
    output.append("}\n\n")
    emitInsertions(output, "cwhip", "parser_post")
    emitInsertions(output, "cwhip", "visitor_pre")
    output.append("class GeneratedVisitor {\n")
    output.append("    public:\n")
    output.append("    enum {\n")
    output.append(
            "        VISIT_CONTINUE = 0, VISIT_SKIP = 1, VISIT_STOP = 2, VISIT_ERROR = -1\n")
    output.append("    }\n")
    output.append("    int64 onNode(AstNode node) {\n")
    output.append("        return(VISIT_CONTINUE)\n")
    output.append("    }\n")
    output.append("    int64 enter(AstNode node) {\n")
    output.append("        return(VISIT_CONTINUE)\n")
    output.append("    }\n")
    output.append("    int64 leave(AstNode node) {\n")
    output.append("        return(VISIT_CONTINUE)\n")
    output.append("    }\n")
    output.append("    int64 checkedResult(int64 result, int64 phase) {\n")
    output.append(
            "        if (result != VISIT_CONTINUE && result != VISIT_SKIP &&\n")
    output.append(
            "                result != VISIT_STOP && result != VISIT_ERROR) {\n")
    output.append("            return(VISIT_ERROR)\n")
    output.append("        }\n")
    output.append("        if (phase == 2 && result == VISIT_SKIP) {\n")
    output.append("            return(VISIT_ERROR)\n")
    output.append("        }\n")
    output.append("        return(result)\n")
    output.append("    }\n")

    list phases = ["on", "enter", "leave"]
    int64 phase = 0
    while (phase < phases.length) {
        String prefix = phases[phase] as String
        String fallback = prefix
        String dispatcher = format("dispatch_{}", prefix)
        if (phase == 0) {
            fallback = "onNode"
            dispatcher = "dispatch"
        }
        output.append(format("    int64 {}(AstNode node) {{\n", dispatcher))
        output.append("        if (node == null) {\n")
        output.append("            return(VISIT_ERROR)\n")
        output.append("        }\n")
        i = 0

        while (i < visitorNames.length) {
            output.append(format("        if (node.kind().equals({})) {{\n",
                    quoted(
                    visitorNames[
                    i] as String)))
            output.append(format(
                    "            return(checkedResult({}_{}(node), {}))\n",
                    prefix, visitorSuffixes[
                    i] as String, phase))
            output.append("        }\n")
            i += 1
        }

        output.append(format(
                
                "        return(checkedResult({}(node), {}))\n",
                fallback,
                phase))
        output.append("    }\n")
        i = 0
        while (i < visitorNames.length) {
            output.append(format("    int64 {}_{}(AstNode node) {{\n", prefix,
                    visitorSuffixes[
                    i] as String))
            output.append(format("        return({}(node))\n", fallback))
            output.append("    }\n")
            i += 1
        }
        phase += 1
    }

    output.append("    int64 walk(AstNode node) {\n")
    output.append("        int64 result = dispatch_enter(node)\n")
    output.append(
            "        if (result == VISIT_STOP || result == VISIT_ERROR) {\n")
    output.append("            return(result)\n")
    output.append("        }\n")
    output.append("        if (result == VISIT_CONTINUE) {\n")
    output.append("            int64 i = 0\n")
    output.append("            while (i < node.childCount()) {\n")
    output.append("                result = walk(node.childAt(i))\n")
    output.append("                if (result != VISIT_CONTINUE) {\n")
    output.append("                    return(result)\n")
    output.append("                }\n")
    output.append("                i += 1\n")
    output.append("            }\n")
    output.append("        }\n")
    output.append("        return(dispatch_leave(node))\n")
    output.append("    }\n")
    output.append("    void visit(AstNode node) {\n")
    i = 0

    while (i < grammar.parserRules.length) {
        ParserRule rule = grammar.parserRules[i] as ParserRule
        output.append(format("        if (node.name.equals({})) {{\n", quoted(
                rule.name)))
        output.append(format("            pre_{}(node)\n", rule.name))
        output.append("            int64 i = 0\n")
        output.append("            while (i < node.children.length) {\n")
        output.append("                visit(node.children[i] as AstNode)\n")
        output.append("                i += 1\n")
        output.append("            }\n")
        output.append(format("            post_{}(node)\n", rule.name))
        output.append("            return\n")
        output.append("        }\n")
        i += 1
    }

    output.append("    }\n")
    i = 0

    while (i < grammar.parserRules.length) {
        ParserRule rule = grammar.parserRules[i] as ParserRule
        output.append(format("    void pre_{}(AstNode node) {{\n", rule.name))
        output.append("    }\n")
        output.append(format("    void post_{}(AstNode node) {{\n", rule.name))
        output.append("    }\n")
        i += 1
    }

    output.append("}\n")
}

/*
 * Emit a Cwhip library or a small parser driver. library selects the library
 * form.
 *
 * library: library (bool).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarEmitter.emitProgram(bool library) {
    String output = ""
    emitInsertions(output, "cwhip", "file_pre")
    emitScanner(output)
    emitInsertions(output, "cwhip", "scanner_post")
    emitInsertions(output, "cwhip", "parser_pre")
    emitParser(output)
    emitInsertions(output, "cwhip", "visitor_post")
    if (library) {
        emitInsertions(output, "cwhip", "file_post")
        return(output)
    }
    output.append("\n")
    output.append("start {\n")
    output.append("    Sys.Process process()\n")
    output.append(
            "    bool complete = process.argc() == 3 && process.arg(1).equals(\"--complete\")\n")
    output.append("    if (process.argc() != 2 && !complete) {\n")
    output.append(
            "        print(\"usage: generated-parser [--complete] INPUT\\n\")\n")
    output.append("        process.exit(2)\n")
    output.append("    }\n")
    output.append("    int64 argument = 1\n")
    output.append("    if (complete) {\n")
    output.append("        argument = 2\n")
    output.append("    }\n")
    output.append(
            "    String input = Sys.File(process.arg(argument), \"r\").readAll()\n")
    output.append("    InputScanner scanner(input)\n")
    output.append("    if (!scanner.scan()) {\n")
    output.append("        print(format(\"{}\\n\", scanner.problem))\n")
    output.append("        process.exit(1)\n")
    output.append("    }\n")
    output.append("    GeneratedParser parser(scanner.tokens)\n")
    output.append("    AstNode root = null\n")
    ParserRule startRule = grammar.parserRules[0] as ParserRule
    output.append("    if (complete) {\n")
    output.append("        root = parser.parseAll()\n")
    output.append("    }\n")
    output.append("    else {\n")
    output.append(format("        root = parser.parse_{}()\n", startRule.name))
    output.append("    }\n")
    output.append("    if (root == null) {\n")
    output.append("        print(format(\"{}\\n\", parser.problem))\n")
    output.append("        process.exit(1)\n")
    output.append("    }\n")
    output.append("    print(format(\"{}\\n\", root.render()))\n")
    output.append("}\n")
    emitInsertions(output, "cwhip", "file_post")
    return(output)
}

/*
 * Perform dot expression for GrammarEmitter.
 *
 * output: output (String). owner: owner (String). index: index (int64).
 * order: order (String).
 *
 * Does not return a value.
 */
void GrammarEmitter.dotExpression(
        
        String output,
        
        String owner,
        
        int64 index,
        
        String order) {
    ParserExprRecord expression = expressions[index] as ParserExprRecord
    if (expression.kind == 0) {
        output.append(format("    {} -> {} [label={}];\n", owner,
                expression.value, quoted(
                
                
                order)))
    }
    if (expression.kind == 1) {
        output.append(format("    {} -> __cpg_literal{} [label={}];\n", owner,
                expression.literal, quoted(
                
                
                order)))
    }

    int64 i = 0
    while (i < expression.children.length) {
        dotExpression(output, owner, expression.children[i] as int64, format(
                
                
                "{}.{}",
                
                
                order,
                
                
                i + 1))
        i += 1
    }

}

/*
 * Emit a Graphviz digraph of parser rules, lexer tokens, and literals.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarEmitter.emitDot() {
    String output = "digraph grammar {\n    rankdir=LR;\n"
    int64 i = 0
    while (i < grammar.parserRules.length) {
        ParserRule rule = grammar.parserRules[i] as ParserRule
        output.append(format("    {} [shape=box];\n", rule.name))
        i += 1
    }
    i = 0
    while (i < analysis.lexers.length) {
        LexerPlan rule = analysis.lexers[i] as LexerPlan
        output.append(format("    {} [shape=ellipse];\n", rule.name))
        i += 1
    }
    i = 0
    while (i < literals.length) {
        output.append(format("    __cpg_literal{} [shape=diamond,label={}];\n",
                i, quoted(literals[
                
                
                i] as String)))
        i += 1
    }
    i = 0
    while (i < analysis.parserRules.length) {
        ParserRuleFacts rule = analysis.parserRules[i] as ParserRuleFacts
        dotExpression(output, rule.name, rule.root, "alt")
        i += 1
    }
    output.append("}\n")
    return(output)
}

/*
 * Clamp a byte index into the half-open range from 0 through length. A
 * negative index counts back from length.
 *
 * value: value (int64). length: length (int64).
 *
 * Returns the clamped index, from 0 through length.
 */
int64 GrammarEmitter.byteSpanBound(int64 value, int64 length) {
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
String GrammarEmitter.byteSpan(String text, int64 first, int64 last) {
    int64 lower = byteSpanBound(first, text.length)
    int64 end = byteSpanBound(last, text.length)
    if (end <= lower) {
        return("")
    }
    return(text[lower..(end - 1)])
}
