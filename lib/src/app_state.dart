/// This enum defines the [AppState].
///
/// It can be either [AppState.open], [AppState.background] or [AppState.closed].
enum AppState {
  /// [open] means that the app is in the foreground, i.e. currently open.
  open,

  /// [background] means that the app is in the background.
  background,

  /// [closed] means that the app is completely closed.
  closed,
}
