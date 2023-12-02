import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:ticketonline/SseatReservationComponent/model/seat_layout_state_model.dart';
import 'package:ticketonline/SseatReservationComponent/model/seat_model.dart';
import 'package:ticketonline/SseatReservationComponent/utils/seat_state.dart';
import 'package:ticketonline/SseatReservationComponent/widgets/seat_widget.dart';


class SeatLayoutWidget extends StatelessWidget {

  final SeatLayoutStateModel stateModel;
  void Function(SeatModel model)? onSeatTap;

  SeatLayoutWidget({
    Key? key,
    required this.stateModel,
    this.onSeatTap,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      alignment: Alignment.topLeft,
      maxScale: 5,
      minScale: 0.8,
      boundaryMargin: const EdgeInsets.all(8),
      constrained: false,
      child: Column(
        children: [
          ...List<int>.generate(stateModel.rows, (rowI) => rowI)
              .map<Row>(
                (rowI) => Row(
                  children: [
                    ...List<int>.generate(stateModel.cols, (colI) => colI)
                        .map<Widget>((colI) {
                          var seatModel = createSeat(colI, rowI);
                          if(seatModel.boxModel != null)
                          {
                            return Tooltip(
                              message: seatModel.boxModel!.toShortString()??"",
                              child: SeatWidget(
                                model: seatModel,
                                onSeatTap: onSeatTap,
                              ),
                            );
                          }

                          return SeatWidget(
                            model: seatModel,
                            onSeatTap: onSeatTap,
                          );
                        })
                        .toList()
                  ],
                ),
              )
              .toList()
        ],
      ),
    );
  }

  SeatModel createSeat(int colI, int rowI) {
    var model =  SeatModel(
      boxModel: stateModel.currentBoxes.firstWhereOrNull((b)=>b.x==colI&&b.y==rowI),
      seatState: stateModel.currentBoxes.firstWhereOrNull((b)=>b.x==colI&&b.y==rowI)?.getState()??SeatState.empty,
      rowI: rowI,
      colI: colI,
      seatSvgSize: stateModel.seatSvgSize,
      pathSelectedSeat: stateModel.pathSelectedSeat,
      pathDisabledSeat: stateModel.pathDisabledSeat,
      pathSoldSeat: stateModel.pathSoldSeat,
      pathUnSelectedSeat:
      stateModel.pathUnSelectedSeat,
      pathEmptySpace: stateModel.pathEmptySpace,
    );
    stateModel.allBoxes.add(model);
    return model;
  }
}
