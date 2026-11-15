/*
 * src/analysis_diagnostic.cw — One analysis failure, with the phase that
 * found it and the grammar location when one exists.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split AnalysisDiagnostic out of src/analysis.cw.
 */

/*
 * One analysis failure, with the phase that found it and the grammar
 * location when one exists.
 */
class AnalysisDiagnostic {
    public:
    String phase
    GrammarDiagnostic info
    bool located
    AnalysisDiagnostic(
            
            String analysisPhase,
            
            GrammarDiagnostic diagnostic,
            
            bool hasLocation)

}

/*
 * Create a AnalysisDiagnostic and store the values passed to the
 * constructor.
 *
 * analysisPhase: analysis phase (String). diagnostic: diagnostic
 * (GrammarDiagnostic). hasLocation: has location (bool).
 *
 * Returns the new object.
 */
AnalysisDiagnostic AnalysisDiagnostic.AnalysisDiagnostic(
        
        String analysisPhase,
        
        GrammarDiagnostic diagnostic,
        
        bool hasLocation) {
    phase = analysisPhase
    info = diagnostic
    located = hasLocation
}
