/*
 * examples/smallc/smallc_backend.cw — Lowers a checked SmallC AST to textual
 * CVM v1 assembly (see CVM's doc/BYTECODE-ASSEMBLY.md). This backend never
 * encodes CVM binary data: the separately installed `cvm-as` assembler
 * resolves symbols, branch offsets, stack metadata and the container layout.
 *
 * Created: 2026-10-22
 * Author: chuck
 *
 * Changelog:
 *   2026-10-22  Initial file.
 *   2026-11-15  Apply the Cwhip coding standard.
 */

include "small_c_asm_code.cw"
include "small_c_asm_variable.cw"
include "small_c_asm_scope.cw"
include "small_c_asm_function.cw"
include "small_c_asm_array.cw"
include "small_c_asm_loop.cw"
include "small_c_assembly_compiler.cw"
