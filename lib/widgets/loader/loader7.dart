import 'package:flutter/widgets.dart';

class Loader7 extends StatefulWidget {
  const Loader7({
    Key? key,
    required this.color,
    this.size = 50.0,
    this.duration = const Duration(milliseconds: 2000), this.itemBuilder,
  })  :
        super(key: key);

  final Color color;
  final double size;
  final IndexedWidgetBuilder? itemBuilder;
  final Duration duration;

  @override
  _Loader7State createState() => _Loader7State();
}

class _Loader7State extends State<Loader7> with TickerProviderStateMixin {
  AnimationController? _scaleCtrl, _rotateCtrl;
  Animation<double>? _scale, _rotate;

  @override
  void initState() {
    super.initState();

    _scaleCtrl = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() => setState(() {}))
      ..repeat(reverse: true);
    _scale = Tween(begin: -1.0, end: 1.0).animate(CurvedAnimation(parent: _scaleCtrl!, curve: Curves.easeInOut));

    _rotateCtrl = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() => setState(() {}))
      ..repeat();
    _rotate = Tween(begin: 0.0, end: 360.0).animate(CurvedAnimation(parent: _rotateCtrl!, curve: Curves.linear));
  }

  @override
  void dispose() {
    _scaleCtrl!.dispose();
    _rotateCtrl!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: Size.square(widget.size),
        child: Transform.rotate(
          angle: _rotate!.value * 0.0174533,
          child: Stack(
            children: <Widget>[
              Positioned(top: 0.0, child: _circle(1.0 - _scale!.value.abs(), 0)),
              Positioned(bottom: 0.0, child: _circle(_scale!.value.abs(), 1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double scale, int index) {
    return Transform.scale(
      scale: scale,
      child: SizedBox.fromSize(
        size: Size.square(widget.size * 0.6),
        child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color)),
      ),
    );
  }
}