/// Strategy for snapping minutes to a fixed interval.
///
/// Used together with [minuteInterval] to decide how a dragged time value
/// should be snapped:
///
/// - [round]: snap to the nearest interval (default)
/// - [floor]: always snap down to the previous interval
/// - [ceil]: always snap up to the next interval
/// - [none]: do not snap at all
enum SnapStrategy {
  /// Snap to the nearest interval.
  round,

  /// Always snap down to the previous interval.
  floor,

  /// Always snap up to the next interval.
  ceil,

  /// Do not snap at all.
  none,
}

