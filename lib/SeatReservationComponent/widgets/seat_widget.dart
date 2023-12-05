import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/seat_model.dart';
import '../utils/seat_state.dart';

class SeatWidget extends StatefulWidget {
  final SeatModel model;

  void Function(SeatModel model)? onSeatTap;

  SeatWidget({
    Key? key,
    this.onSeatTap,
    required this.model,
  }) : super(key: key);

  @override
  State<SeatWidget> createState() => _SeatWidgetState();
}

class _SeatWidgetState extends State<SeatWidget> {
  SeatState seatState = SeatState.empty;
  int rowI = 0;
  int colI = 0;

  @override
  void initState() {
    super.initState();
    seatState = widget.model.seatState;
    rowI = widget.model.rowI;
    colI = widget.model.colI;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (_) {
        if(widget.onSeatTap!=null)
        {
          widget.onSeatTap!(widget.model);
          setState((){
            seatState = widget.model.seatState;
          });
        }
      },
      child: SvgPicture.asset(
        _getSvgPath(seatState),
        height: widget.model.seatSvgSize.toDouble(),
        width: widget.model.seatSvgSize.toDouble(),
        fit: BoxFit.cover,
      ),
    );
  }

  String _getSvgPath(SeatState state) {
    switch (state) {
      case SeatState.available:
        {
          return widget.model.pathUnSelectedSeat;
        }
      case SeatState.selected:
        {
          return widget.model.pathSelectedSeat;
        }
      case SeatState.black:
        {
          return widget.model.pathDisabledSeat;
        }
      case SeatState.sold:
        {
          return widget.model.pathSoldSeat;
        }
      case SeatState.empty:
        {
          return widget.model.pathEmptySpace;
        }
      default:
        {
          return widget.model.pathDisabledSeat;
        }
    }
  }
}
