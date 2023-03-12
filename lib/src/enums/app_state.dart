/// This enum defines [AppState], i.e. the current state of the app.
enum AppState {
  /// [open] means that the app is in the foreground, i.e. currently open.
  open,

  /// [background] means that the app is in the background.
  background,

  /// [terminated] means that the app is completely closed.
  terminated,
}
