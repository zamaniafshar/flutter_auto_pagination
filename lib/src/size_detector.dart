import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A widget that detects and reports the size of its child.
///
/// This widget wraps a child and calls the [onSizeChanged] callback
/// whenever the child's size changes.
class SizeDetector extends SingleChildRenderObjectWidget {
  /// Creates a size detector widget.
  ///
  /// The [onSizeChanged] callback is called whenever the child's size changes.
  const SizeDetector({
    super.key,
    required this.onSizeChanged,
    super.child,
  });

  /// Callback that is called when the child's size changes.
  final ValueChanged<Size> onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSizeDetector(onSizeChanged: onSizeChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSizeDetector renderObject,
  ) {
    renderObject.onSizeChanged = onSizeChanged;
  }
}

class _RenderSizeDetector extends RenderProxyBox {
  _RenderSizeDetector({
    required ValueChanged<Size> onSizeChanged,
  }) : _onSizeChanged = onSizeChanged;

  ValueChanged<Size> _onSizeChanged;
  set onSizeChanged(ValueChanged<Size> value) {
    if (_onSizeChanged != value) {
      _onSizeChanged = value;
    }
  }

  Size? _previousSize;

  @override
  void performLayout() {
    super.performLayout();

    // Check if the size has changed
    if (_previousSize != size) {
      _previousSize = size;
      // Schedule the callback to be called after the current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onSizeChanged(size);
      });
    }
  }
}
