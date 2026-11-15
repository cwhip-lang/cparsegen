/*
 * src/grammar_analyzer_4.cw — Out-of-line methods for GrammarAnalyzer.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split GrammarAnalyzer methods out of src/analysis.cw while
 *              applying the coding standard.
 */

/*
 * Least fixed point over rule nullability; expression records follow it.
 *
 * Does not return a value.
 */
void GrammarAnalyzer.computeNullability() {

    bool changed = true
    while (changed) {
        changed = false

        int64 e = 0
        while (e < analysis.expressions.length) {
            ParserExprRecord entry = expressionAt(e)
            bool nullable = false
            if (entry.kind == 0) {
                nullable = entry.target >= 0 && ruleAt(entry.target).nullable
            }
            if (entry.kind == 4) {
                nullable = entry.minimum == 0 || expressionAt(
                        entry.children[0] as int64).nullable
            }
            if (entry.kind == 2) {
                nullable = true
                int64 c = 0
                while (c < entry.children.length) {
                    if (!expressionAt(entry.children[c] as int64).nullable) {
                        nullable = false
                    }
                    c += 1
                }
            }
            if (entry.kind == 3) {
                int64 c = 0
                while (c < entry.children.length) {
                    if (expressionAt(entry.children[c] as int64).nullable) {
                        nullable = true
                    }
                    c += 1
                }
            }
            entry.nullable = nullable
            e += 1
        }

        int64 r = 0
        while (r < analysis.parserRules.length) {
            ParserRuleFacts facts = ruleAt(r)
            if (!facts.nullable && expressionAt(facts.root).nullable) {
                facts.nullable = true
                changed = true
            }
            r += 1
        }
    }

}

/*
 * Record corners on the compiler or checker.
 *
 * owner: owner (ParserRuleFacts). index: index (int64). zero: zero (bool).
 *
 * Does not return a value.
 */
void GrammarAnalyzer.collectCorners(
        ParserRuleFacts owner,
        int64 index,
        bool zero) {

    ParserExprRecord entry = expressionAt(index)
    if (entry.kind == 0) {

        if (entry.target >= 0) {
            owner.corners.append(LeftCornerEdge(
                    
                    owner.index,
                    
                    entry.target,
                    
                    zero,
                    
                    entry.line,
                    
                    entry.span))
        }

        return
    }

    int64 c = 0
    while (c < entry.children.length) {
        bool childZero = zero
        if (entry.kind == 2) {
            int64 s = c + 1
            while (s < entry.children.length) {
                if (!expressionAt(entry.children[s] as int64).nullable) {
                    childZero = false
                }
                s += 1
            }
        }
        collectCorners(owner, entry.children[c] as int64, childZero)
        if (entry.kind == 2 &&
                !expressionAt(entry.children[c] as int64).nullable) {
            return
        }
        c += 1
    }

}

/*
 * Perform build left corners for GrammarAnalyzer.
 *
 * Does not return a value.
 */
void GrammarAnalyzer.buildLeftCorners() {
    int64 r = 0
    while (r < analysis.parserRules.length) {
        ParserRuleFacts facts = ruleAt(r)
        collectCorners(facts, facts.root, true)
        r += 1
    }
    r = 0

    while (r < analysis.parserRules.length) {
        ParserRuleFacts facts = ruleAt(r)
        int64 n = 0
        while (n < analysis.parserRules.length) {
            facts.reachable.append(false)
            n += 1
        }
        list pending = []
        int64 e = 0
        while (e < facts.corners.length) {
            pending.append((facts.corners[e] as LeftCornerEdge).destination)
            e += 1
        }

        int64 p = 0
        while (p < pending.length) {
            int64 node = pending[p] as int64
            if (!(facts.reachable[node] as bool)) {
                facts.reachable[node] = true
                list next = ruleAt(node).corners
                int64 k = 0
                while (k < next.length) {
                    pending.append((next[k] as LeftCornerEdge).destination)
                    k += 1
                }
            }
            p += 1
        }

        facts.leftRecursive = facts.reachable[r] as bool
        r += 1
    }

}

/*
 * Perform validate expression for GrammarAnalyzer.
 *
 * index: index (int64).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.validateExpression(int64 index) {

    ParserExprRecord entry = expressionAt(index)
    if (entry.kind == 0) {

        if (entry.token < 0 && entry.target < 0) {
            int64 first = int64(entry.value[0])
            if (first >= 65 && first <= 90) {
                return(fail("references", format(
                        
                        "line {}: unknown lexer token {}",
                        
                        entry.line,
                        
                        
                    entry.value), entry.span, null))
            }
            return(fail("references", format(
                    
                    "line {}: unknown parser rule {}",
                    
                    entry.line,
                    
                    
                entry.value), entry.span, null))
        }

        if (entry.token >= 0) {
            LexerPlan token = analysis.lexers[entry.token] as LexerPlan
            if (token.skip) {
                return(fail("references", format(
                        
                        "line {}: skipped lexer token {} cannot be matched by a parser",
                        
                        
                    entry.line,
                        
                        token.name), entry.span, token.span))
            }
            analysis.parserReferences.append(ResolvedReference(
                    
                    1,
                    
                    token.name,
                    
                    -1,
                    
                    entry.token,
                    
                    
                entry.line,
                    
                    entry.span,
                    
                    token.span))
        }
        else {
            analysis.parserReferences.append(ResolvedReference(2, ruleAt(
                    
                    entry.target).name, -1,
                entry.target, entry.line, entry.span, ruleAt(
                    
                    entry.target).span))
        }

    }

    if (entry.kind == 1 && entry.value.length == 0) {
        return(fail("references", format(
                
                "line {}: empty quoted terminals are not supported",
                
                
            entry.line), entry.span, null))
    }
    if (entry.kind == 4 && expressionAt(entry.children[0] as int64).nullable) {
        return(fail("references", format(
                
                "line {}: nullable repetition is not supported",
                
                
            entry.line), entry.span, null))
    }
    int64 i = 0
    while (i < entry.children.length) {
        String error = validateExpression(entry.children[i] as int64)
        if (!error.equals("")) {
            return(error)
        }
        i += 1
    }
    return("")
}

/*
 * Only zero-context cycles admit infinitely many equal-span trees.
 *
 * rule: rule (int64). onPath: on path (list). done: done (list).
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.zeroCycle(int64 rule, list onPath, list done) {
    onPath[rule] = true

    list corners = ruleAt(rule).corners
    int64 e = 0
    while (e < corners.length) {

        LeftCornerEdge edge = corners[e] as LeftCornerEdge
        if (edge.zeroContext) {

            if (onPath[edge.destination] as bool) {
                ParserRuleFacts target = ruleAt(edge.destination)
                return(fail("left-recursion", format(
                        
                        "line {}: left recursion through parser rule {} can repeat without consuming tokens; require a nonnullable prefix or suffix on every cycle",
                        
                        
                    edge.line,
                        
                        target.name), edge.span, target.span))
            }

            if (!(done[edge.destination] as bool)) {
                String error = zeroCycle(edge.destination, onPath, done)
                if (!error.equals("")) {
                    return(error)
                }
            }
        }

        e += 1
    }

    onPath[rule] = false
    done[rule] = true
    return("")
}

/*
 * Perform validate parser for GrammarAnalyzer.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String GrammarAnalyzer.validateParser() {
    list onPath = []
    list done = []
    int64 n = 0
    while (n < analysis.parserRules.length) {
        onPath.append(false)
        done.append(false)
        n += 1
    }

    int64 r = 0
    while (r < analysis.parserRules.length) {
        ParserRuleFacts facts = ruleAt(r)
        String error = validateExpression(facts.root)
        if (!error.equals("")) {
            return(error)
        }
        error = zeroCycle(r, onPath, done)
        if (!error.equals("")) {
            return(error)
        }
        r += 1
    }

    return("")
}
