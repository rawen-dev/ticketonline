import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ticketonline/SseatReservationComponent/model/seat_layout_state_model.dart';
import 'package:ticketonline/SseatReservationComponent/model/seat_model.dart';
import 'package:ticketonline/SseatReservationComponent/utils/seat_state.dart';
import 'package:ticketonline/SseatReservationComponent/widgets/seat_layout_widget.dart';
import 'package:ticketonline/models/BoxModel.dart';
import 'package:ticketonline/models/Occasion.dart';
import 'package:ticketonline/models/RoomModel.dart';

import 'package:ticketonline/services/DataService.dart';
import 'package:ticketonline/services/ToastHelper.dart';


class SeatReservationWidget extends StatefulWidget {
  final OccasionModel? occasion;
  Set<BoxModel> selectedSeats;
  SeatReservationWidget({Key? key, this.occasion, required this.selectedSeats}) : super(key: key);
  @override
  State<SeatReservationWidget> createState() => _SeatReservationWidgetState(occasion, selectedSeats);
}

class _SeatReservationWidgetState extends State<SeatReservationWidget> {
  Set<BoxModel> selectedSeats = {};
  OccasionModel? occasion;
  RoomModel? room;

  _SeatReservationWidgetState(this.occasion, this.selectedSeats);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  List<BoxModel>? currentBoxes;
  int currentWidth = 20;
  int currentHeight = 20;

  List<SeatModel> changedBoxes = [];
  List<SeatModel> allBoxes = [];

  static const int boxSize = 20;
  selectionMode currentSelectionMode = selectionMode.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 16,
                ),
                Text(room?.name??""),
                const SizedBox(
                  height: 16,
                ),
                Visibility(
                  visible: currentBoxes!=null,
                  child: Flexible(
                    child: SizedBox(
                      width: currentWidth*boxSize.toDouble(),
                      height: currentHeight*boxSize.toDouble(),
                      child: SeatLayoutWidget(
                        onSeatTap: (model){
                          if(currentSelectionMode==selectionMode.addBlack)
                          {
                            model.seatState = SeatState.black;
                            changedBoxes.add(model);
                          }
                          else if (currentSelectionMode==selectionMode.addAvailable)
                          {
                            model.seatState = SeatState.available;
                            changedBoxes.add(model);
                          }
                          else if (currentSelectionMode==selectionMode.normal)
                          {
                            if(model.seatState==SeatState.selected)
                            {
                              model.seatState = SeatState.available;
                              changedBoxes.remove(model);
                              return;
                            }
                            else if(model.seatState!=SeatState.available)
                            {
                              return;
                            }

                            //available
                            var alreadySelected = allBoxes.where((b) => b.seatState == SeatState.selected);
                            if(alreadySelected.isNotEmpty)
                              {
                                ToastHelper.Show("Je možné vybrat pouze jedno místo!");
                                return;
                              }

                            // for (var element in alreadySelected.toList()) {
                            //   element.seatState = SeatState.available;
                            //   changedBoxes.remove(element);
                            // }
                            model.seatState = SeatState.selected;
                            changedBoxes.add(model);
                          }
                        },
                        // onSeatStateChanged: (rowI, colI, seatState) {
                        //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(
                        //       content: seatState == SeatState.selected
                        //           ? Text("Selected Seat[$rowI][$colI]")
                        //           : Text("De-selected Seat[$rowI][$colI]"),
                        //     ),
                        //   );
                        //   if (seatState == SeatState.selected) {
                        //     selectedSeats.add(SeatNumber(rowI: rowI, colI: colI));
                        //   } else {
                        //     selectedSeats.remove(SeatNumber(rowI: rowI, colI: colI));
                        //   }
                        // },
                        stateModel: SeatLayoutStateModel(
                          pathDisabledSeat: 'assets/svg_disabled_bus_seat.svg',
                          pathSelectedSeat: 'assets/svg_selected_bus_seats.svg',
                          pathSoldSeat: 'assets/svg_sold_bus_seat.svg',
                          pathUnSelectedSeat: 'assets/svg_unselected_bus_seat.svg',
                          pathEmptySpace: 'assets/svg_empty_space.svg',
                          rows: currentWidth,
                          cols: currentHeight,
                          seatSvgSize: boxSize,
                          currentBoxes: currentBoxes??[],
                          allBoxes: allBoxes
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: (){
                              currentSelectionMode = selectionMode.addBlack;
                            },
                            child: SvgPicture.asset(
                              'assets/svg_disabled_bus_seat.svg',
                              width: 15,
                              height: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text("stůl")
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svg_sold_bus_seat.svg',
                            width: 15,
                            height: 15,
                          ),
                          const SizedBox(width: 8),
                          const Text("vyprodané")
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: (){
                              currentSelectionMode = selectionMode.addAvailable;
                            },
                            child: SvgPicture.asset(
                              'assets/svg_unselected_bus_seat.svg',
                              width: 15,
                              height: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text("dostupné")
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svg_selected_bus_seats.svg',
                            width: 15,
                            height: 15,
                          ),
                          const SizedBox(width: 8),
                          const Text("vybrané")
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("zpět"),
                  ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        var changed = changedBoxes.map((e) {
                          var newBoxModel = e.boxModel ?? BoxModel(x: e.colI, y: e.rowI, occasion: occasion!.id, room: room!.id);
                          newBoxModel.type = BoxModel.States[e.seatState];
                          return newBoxModel;
                        }).toList();

                        //only non-selected
                        selectedSeats.clear();
                        selectedSeats.addAll(changed.where((element) => element.type == BoxModel.selectedType));
                        changed = changed.where((element) => element.type != BoxModel.selectedType).toList();

                        DataService.updateBoxes(changed);
                        Navigator.pop(context);
                      },
                      child: const Text("uložit"),
                    ),
                  ]
                ),
                const SizedBox(height: 12),
                //Text(selectedSeats.join(" , "))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void loadData() async {
    // occasion = await DataService.getOccasionModelByLink(occasionLink??"");
    // if(occasion==null)
    // {
    //   ToastHelper.Show("událost nenalezena", severity: ToastSeverity.NotOk);
    //   return;
    // }
    room = (await DataService.getRooms(occasion!.id!)).first;
    var boxes = await DataService.getAllBoxes(occasion!.id!);
    for(var b in boxes)
    {
      var selected = selectedSeats.firstWhereOrNull((s)=>s.id==b.id);
      if(selected==null)
      {
        continue;
      }
      b.type = selected.type;
    }

    setState(() {
      currentBoxes = boxes;
      currentHeight = room!.height!;
      currentWidth = room!.width!;
    });
  }
}

class SeatNumber {
  final int rowI;
  final int colI;

  const SeatNumber({required this.rowI, required this.colI});

  @override
  bool operator ==(Object other) {
    return rowI == (other as SeatNumber).rowI && colI == (other as SeatNumber).colI;
  }

  @override
  int get hashCode => rowI.hashCode;

  @override
  String toString() {
    return '[$rowI][$colI]';
  }
}

enum selectionMode{
  normal,
  addBlack,
  addAvailable,
}