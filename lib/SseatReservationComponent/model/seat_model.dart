import 'package:ticketonline/SseatReservationComponent/utils/seat_state.dart';
import 'package:ticketonline/models/BoxModel.dart';


class SeatModel {
  SeatState seatState;
  final int rowI;
  final int colI;
  final int seatSvgSize;
  final String pathSelectedSeat;
  final String pathUnSelectedSeat;
  final String pathSoldSeat;
  final String pathDisabledSeat;
  final String pathEmptySpace;
  BoxModel? boxModel;

  SeatModel({
    required this.boxModel,
    required this.seatState,
    required this.rowI,
    required this.colI,
    this.seatSvgSize = 50,
    required this.pathSelectedSeat,
    required this.pathDisabledSeat,
    required this.pathSoldSeat,
    required this.pathUnSelectedSeat,
    required this.pathEmptySpace,
  });

}
