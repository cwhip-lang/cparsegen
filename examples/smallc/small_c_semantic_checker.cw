/*
 * examples/smallc/small_c_semantic_checker.cw — Walks a SmallC AST, rejects
 * unsupported constructs, and checks types and scopes.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split SmallCSemanticChecker out of
 *              examples/smallc/smallc_frontend.cw.
 */

/*
 * Walks a SmallC AST, rejects unsupported constructs, and checks types and
 * scopes.
 */
class SmallCSemanticChecker : GeneratedVisitor {
    public:
    SmallCIntrinsics intrinsics
    list locations
    list globals
    SmallCScope currentScope
    String problem
    int64 errorOffset
    String returnType
    list labels
    int64 loopDepth
    int64 switchDepth
    list parameterNames
    list checkedParameterTypes
    SmallCSemanticChecker()

    AstNode child(AstNode node, int64 index)

    void indexLocations(AstNode node, list tokens, SmallCTokenCursor cursor)

    int64 offsetOf(AstNode node)

    void fail(AstNode node, String message)

    bool isArray(String valueType)

    String elementType(String valueType)

    bool isScalar(String valueType)

    bool isValue(String valueType)

    SmallCSymbol findGlobal(String name)

    SmallCSymbol findScoped(String name)

    SmallCSymbol findVariable(String name)

    bool currentScopeHas(String name)

    void pushScope()

    void popScope()

    void addVariable(AstNode nameNode, String valueType, bool global)

    String exactType(
            
            String actual,
            
            String expected,
            
            AstNode node,
            
            String context)

    String lvalueType(AstNode node, bool writing)

    AstNode arrayArgument(AstNode argument)

    String intrinsicCallType(AstNode node, SmallCIntrinsic intrinsic)

    String callType(AstNode node)

    String expressionType(AstNode node)

    void checkInitializer(
            
            AstNode initializer,
            
            String valueType,
            
            AstNode nameNode)

    void checkDeclaration(AstNode node, bool global)

    list parameterTypes(AstNode parameters)

    int64 enter_rule_parameter(AstNode node)

    bool isLabel(AstNode node)

    void collectLabels(AstNode node)

    AstNode findLabel(String name)

    String caseKey(AstNode node)

    void checkFunction(AstNode node)

    void checkForInitializer(AstNode node)

    void checkCompound(AstNode node, bool nested)

    void checkBlockItem(AstNode node)

    void checkSwitch(AstNode node)

    void checkSimpleStatement(AstNode node)

    void checkStatement(AstNode node)

    bool check(AstNode root, list tokens)

    int64 byteSpanBound(int64 value, int64 length)
    String byteSpan(String text, int64 first, int64 last)

}

include "small_c_semantic_checker_1.cw"
include "small_c_semantic_checker_2.cw"
include "small_c_semantic_checker_3.cw"
include "small_c_semantic_checker_4.cw"
include "small_c_semantic_checker_5.cw"
include "small_c_semantic_checker_6.cw"
