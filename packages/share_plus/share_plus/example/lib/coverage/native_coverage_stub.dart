/// Web stub for the native platform coverage (see [native_coverage_io.dart]).
///
/// On the web the Windows/Linux plugins and [VersionHelper] are not available,
/// so this file provides a no-op implementation that the conditional import
/// resolves to.
Future<void> runNativeCoverage() async {
  // No-op on the web.
}
