import 'package:flutter/material.dart';

class SplitView extends StatefulWidget {
  final Widget top;
  final Widget bottom;
  final double ratio;

  const SplitView(
      {Key key, @required this.top, @required this.bottom, this.ratio = 0.5})
      : assert(top != null),
        assert(bottom != null),
        assert(ratio >= 0),
        assert(ratio <= 1),
        super(key: key);

  @override
  _SplitViewState createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  final _dividerWidth = 10.0;

  //from 0-1
  double _ratio;
  double _maxWidth;

  get _width1 => _ratio * _maxWidth;

  get _width2 => (1 - _ratio) * _maxWidth;

  @override
  void initState() {
    super.initState();
    _ratio = widget.ratio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      assert(_ratio <= 1);
      assert(_ratio >= 0);
      if (_maxWidth == null) _maxWidth = constraints.maxHeight - _dividerWidth;
      if (_maxWidth != constraints.maxHeight) {
        _maxWidth = constraints.maxHeight - _dividerWidth;
      }

      return SizedBox(
        height: constraints.maxHeight,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: _width1,
              child: widget.top,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.black12,
                child: SizedBox(
                    height: _dividerWidth,
                    width: constraints.maxWidth
                ),
              ),
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  _ratio += details.delta.dy / _maxWidth;
                  if (_ratio > 1)
                    _ratio = 1;
                  else if (_ratio < 0.0) _ratio = 0.0;
                });
              },
            ),
            SizedBox(
              height: _width2,
              child: widget.bottom,
            ),
          ],
        ),
      );
    });
  }
}