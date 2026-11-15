/*
 * examples/smallc/small_c_asm_code.cw — Buffer of textual CVM assembly and
 * the counter used to mint labels.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCAsmCode out of examples/smallc/smallc_backend.cw.
 */

/*
 * Buffer of textual CVM assembly and the counter used to mint labels.
 */
class SmallCAsmCode {
    public:
    String text
    int64 labelCounter
    SmallCAsmCode()

    void op(String instruction)

    void op1(String mnemonic, String operand)

    String newLabel()

    void mark(String name)

}

/*
 * Create a SmallCAsmCode and store the values passed to the constructor.
 *
 * Returns the new object.
 */
SmallCAsmCode SmallCAsmCode.SmallCAsmCode() {
    text = ""
    labelCounter = 0
}

/*
 * Perform op for SmallCAsmCode.
 *
 * instruction: instruction (String).
 *
 * Does not return a value.
 */
void SmallCAsmCode.op(String instruction) {
    text.append("    ")
    text.append(instruction)
    text.append("\n")
}

/*
 * Perform op1 for SmallCAsmCode.
 *
 * mnemonic: mnemonic (String). operand: operand (String).
 *
 * Does not return a value.
 */
void SmallCAsmCode.op1(String mnemonic, String operand) {
    op(format("{} {}", mnemonic, operand))
}

/*
 * Perform new label for SmallCAsmCode.
 *
 * Returns the string result. An empty string means failure where this method
 * documents that convention.
 */
String SmallCAsmCode.newLabel() {
    String result = format("L{}", labelCounter)
    labelCounter += 1
    return(result)
}

/*
 * Perform mark for SmallCAsmCode.
 *
 * name: name (String).
 *
 * Does not return a value.
 */
void SmallCAsmCode.mark(String name) {
    text.append(name)
    text.append(":\n")
}
