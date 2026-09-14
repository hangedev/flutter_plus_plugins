/// Native stub for the web coverage (see [web_coverage_web.dart]).
///
/// On non-web platforms [SharePlusWebPlugin] is not available, so this file
/// provides a no-op implementation that the conditional import resolves to.
Future<void> runWebCoverage() async {
  // No-op on native platforms.
}
