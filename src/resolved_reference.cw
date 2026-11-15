/*
 * src/resolved_reference.cw — A name use linked to the declaration it means,
 * in one of the lexer or parser domains.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split ResolvedReference out of src/analysis.cw.
 */

/*
 * A name use linked to the declaration it means. Domains: 0 lexer
 * expression to lexer token, 1 parser to lexer token, 2 parser
 * expression to parser rule.
 */
class ResolvedReference {
    public:
    int64 domain
    String name
    int64 owner
    int64 target
    int64 line
    SourceSpan span
    SourceSpan targetSpan
    ResolvedReference(
            
            int64 referenceDomain,
            
            String targetName,
            
            int64 ownerIndex,
            
            int64 targetIndex,
            

                      int64 sourceLine,
            
            SourceSpan location,
            
            SourceSpan declaration)

}

/*
 * Create a ResolvedReference and store the values passed to the constructor.
 *
 * referenceDomain: reference domain (int64). targetName: target name
 * (String). ownerIndex: owner index (int64). targetIndex: target index
 * (int64). sourceLine: source line (int64). location: location (SourceSpan).
 * declaration: declaration (SourceSpan).
 *
 * Returns the new object.
 */
ResolvedReference ResolvedReference.ResolvedReference(
        
        int64 referenceDomain,
        
        String targetName,
        
        int64 ownerIndex,
        
        int64 targetIndex,
        

                  int64 sourceLine,
        
        SourceSpan location,
        
        SourceSpan declaration) {
    domain = referenceDomain
    name = targetName
    owner = ownerIndex
    target = targetIndex
    line = sourceLine
    span = location
    targetSpan = declaration
}
