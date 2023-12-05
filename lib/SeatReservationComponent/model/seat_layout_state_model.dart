import 'package:ticketonline/models/BoxModel.dart';
import 'package:ticketonline/SeatReservationComponent/model/seat_model.dart';

class SeatLayoutStateModel {
  final int rows;
  final int cols;
  final List<BoxModel> currentBoxes;
  final List<SeatModel> allBoxes;
  final int seatSvgSize;
  final String pathSelectedSeat;
  final String pathUnSelectedSeat;
  final String pathSoldSeat;
  final String pathDisabledSeat;
  final String pathEmptySpace;

  const SeatLayoutStateModel({
    required this.rows,
    required this.cols,
    required this.currentBoxes,
    required this.allBoxes,
    this.seatSvgSize = 50,
    required this.pathSelectedSeat,
    required this.pathDisabledSeat,
    required this.pathSoldSeat,
    required this.pathUnSelectedSeat,
    required this.pathEmptySpace,
  });
}
