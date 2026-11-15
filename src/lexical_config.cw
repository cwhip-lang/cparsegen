/*
 * src/lexical_config.cw — Skip, keyword, reserved, quote, and comment
 * settings collected from directives.
 *
 * Created: 2026-11-15
 * Author: Auto
 *
 * Changelog:
 *   2026-11-15  Split LexicalConfig out of src/analysis.cw.
 */

/*
 * Skip, keyword, reserved, quote, and comment settings collected from
 * directives.
 */
class LexicalConfig {
    public:
    String keywordToken
    SourceSpan keywordSpan
    SourceSpan reservedSpan
    list reserved
    list lineComments
    list blockComments
    LexicalConfig()

}

/*
 * Create a LexicalConfig and store the values passed to the constructor.
 *
 * Returns the new object.
 */
LexicalConfig LexicalConfig.LexicalConfig() {
    keywordToken = ""
    keywordSpan = null
    reservedSpan = null
    reserved = []
    lineComments = []
    blockComments = []
}
