/*
 * src/grammar.cw — Grammar model, scanner, and reader. Each type lives
 * in its own file.
 *
 * Created: 2026-10-18
 * Author: chuck
 *
 * Changelog:
 *   2026-10-18  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "source_location.cw"
include "source_span.cw"
include "grammar_diagnostic.cw"
include "grammar_token.cw"
include "grammar_scanner.cw"
include "lexer_rule.cw"
include "lexer_expr.cw"
include "lexer_state.cw"
include "byte_range.cw"
include "rule_expr.cw"
include "parser_rule.cw"
include "grammar_directive.cw"
include "code_insertion.cw"
include "grammar_model.cw"
include "grammar_reader.cw"
include "grammar_source.cw"
include "grammar_sources.cw"
