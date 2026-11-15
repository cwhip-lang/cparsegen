/*
 * src/analysis.cw — Typed, target-neutral analysis of a parsed (and include-
 * expanded) grammar. Pipeline: GrammarSources.read() collects declarations
 * into a GrammarModel, then GrammarAnalyzer.run() resolves references,
 * validates them, and attaches one immutable-after-construction Analysis to
 * the model. Backends only read it. Analysis-only facts: references,
 * nullability, left-corner graph, reachability. Emitted normalization
 * records: lexer NFA plans, the numbered parser expression table and its
 * literal table.
 *
 * Created: 2026-10-22
 * Author: chuck
 *
 * Changelog:
 *   2026-10-22  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "analysis_diagnostic.cw"
include "resolved_reference.cw"
include "lexer_plan.cw"
include "left_corner_edge.cw"
include "parser_rule_facts.cw"
include "parser_expr_record.cw"
include "lexical_config.cw"
include "analysis_model.cw"
include "grammar_analyzer.cw"
