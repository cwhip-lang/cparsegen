/*
 * examples/smallc/small_c_assembly_compiler.cw — Lowers a checked SmallC AST
 * to textual CVM v1 assembly. It does not encode a CVM binary.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCAssemblyCompiler out of
 *              examples/smallc/smallc_backend.cw.
 */

/*
 * Lowers a checked SmallC AST to textual CVM v1 assembly. It does not encode
 * a CVM binary.
 */
class SmallCAssemblyCompiler {
    public:
    SmallCAsmFunction entryFunction
    list functions
    list globals
    list arrays
    list globalInitializers
    SmallCAsmFunction currentFunction
    SmallCAsmCode code
    SmallCAsmScope scope
    SmallCAsmLoop loop
    SmallCFrontend frontend
    SmallCIntrinsics intrinsics
    String problem
    AstNode errorNode
    int64 scalarGlobalCount
    String functionText
    SmallCAssemblyCompiler()

    AstNode child(AstNode node, int64 index)

    void fail(AstNode node, String message)

    String elementType(String valueType)

    String asmType(String valueType)

    SmallCAsmFunction findFunction(String name)

    SmallCAsmVariable findGlobal(String name)

    SmallCAsmVariable findVariable(String name)

    void pushScope()

    void popScope()

    int64 slotCount()

    String declareLocal(String name, String valueType, String prefix)

    void addLocal(String name, String valueType)

    String addTemporary(String valueType)

    int64 integerValue(String spelling, int64 limit, AstNode node)

    bool isMinimumIntegerLiteral(String spelling)

    int64 decodeEscape(int64 value)

    int64 characterValue(String spelling)

    buffer stringBytes(String spelling)

    String hexByte(int64 value)

    String assemblyString(buffer bytes)

    int64 initializerCount(AstNode initializer)

    AstNode declarationInitializer(AstNode declarator)

    int64 declaredArrayLength(AstNode declarator, AstNode initializer)

    String literalText(AstNode node, String valueType)

    String staticArrayInitializer(
            
            String arrayElementType,
            
            int64 length,
            

            AstNode initializer,
            
            String name)

    void collectGlobalDeclaration(AstNode declaration)

    void collectFunction(AstNode external)

    bool collectProgram(AstNode root)

    String compile(AstNode root, SmallCFrontend frontendModel)

    String assemble(String initText)

    String compileGlobalInitializers()

    String declarationText()

    void compileUserFunction(SmallCAsmFunction function)

    bool guaranteesReturn(AstNode node)

    bool isStatementNode(AstNode node)

    list statementChildren(AstNode node)

    void emitInt(int64 value)

    void emitByte(int64 value)

    void promoteToInt(String valueType)

    void discard(String valueType)

    void emitLoad(SmallCAsmVariable variable)

    void emitStore(SmallCAsmVariable variable)

    void emitArrayReference(SmallCAsmVariable variable)

    void emitArrayInitializer(SmallCAsmVariable variable, AstNode initializer)

    void emitDeclaration(AstNode declaration)

    void emitCompound(AstNode node, bool nested)

    void emitBlockItem(AstNode node)

    void emitStatement(AstNode node)

    void emitAtomicStatement(AstNode node)

    void emitIf(AstNode node)

    void emitWhile(AstNode node)

    void emitFor(AstNode node)

    void emitForInitializer(AstNode node)

    String emitExpression(AstNode node)

    String binaryMnemonic(String operation)

    String emitBinaryChain(AstNode node)

    String emitLogical(AstNode node, bool conjunction)

    String emitUnary(AstNode node)

    String emitPrimary(AstNode node)

    list callArguments(AstNode node)

    String emitCall(AstNode node)

    AstNode arrayArgumentName(AstNode argument)

    String emitPrint(AstNode argument)

    void emitBufferArgument(AstNode argument)

    String emitIntrinsic(AstNode node, SmallCIntrinsic intrinsic)

    String emitLvalue(AstNode node)

    String evaluateIndex(AstNode lvalue)

    String emitAssignment(AstNode node)

    void emitCompoundOperation(String operation, AstNode operator)

    String emitIncrement(AstNode lvalue, bool postfix, bool increment)

    int64 byteSpanBound(int64 value, int64 length)
    String byteSpan(String text, int64 first, int64 last)

}

include "small_c_assembly_compiler_1.cw"
include "small_c_assembly_compiler_2.cw"
include "small_c_assembly_compiler_3.cw"
include "small_c_assembly_compiler_4.cw"
include "small_c_assembly_compiler_5.cw"
include "small_c_assembly_compiler_6.cw"
include "small_c_assembly_compiler_7.cw"
include "small_c_assembly_compiler_8.cw"
include "small_c_assembly_compiler_9.cw"
