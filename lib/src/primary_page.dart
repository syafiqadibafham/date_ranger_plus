part of '../date_ranger.dart';

class PrimaryPage extends StatefulWidget {
  final Function(DateTime) onNewDate;
  final OnRangeChanged onRangeChanged;
  final void Function(String) onError;
  final Color? monthYearTextColor;
  final Color selectedTextColor;
  final String doneText;
  final Function()? onTap;
  final String startDateError;
  final String endDateError;

  PrimaryPage({
    Key? key,
    required this.onNewDate,
    required this.onRangeChanged,
    required this.onError,
    required this.selectedTextColor,
    required this.doneText,
    required this.startDateError,
    required this.endDateError,
    this.monthYearTextColor,
    this.onTap,
  }) : super(key: key);

  @override
  _PrimaryPageState createState() => _PrimaryPageState();
}

class _PrimaryPageState extends State<PrimaryPage> {
  late InheritedRanger ranger;
  late ThemeData theme;
  late ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    ranger = InheritedRanger.of(context);
    theme = Theme.of(context);
    colorScheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: ranger.activeTab,
            builder: (context, value, child) {
              var tabDate = DateTime(ranger.activeYear, value + 1);
              return Row(
                children: [
                  chevron(active: value > 0),
                  InkWell(
                    onTap: () async {
                      var newDate = await ranger.navKey.currentState!.pushNamed("secondary", arguments: tabDate);
                      print(newDate);
                      if (newDate != null) widget.onNewDate.call(newDate as DateTime);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 24),
                      child: Text(
                        DateFormat("${DateFormat.ABBR_MONTH} ${DateFormat.YEAR}").format(tabDate),
                        style: TextStyle(fontSize: 16.0).copyWith(color: widget.monthYearTextColor),
                      ),
                    ),
                  ),
                  chevron(left: false, active: value < 11)
                ],
              );
            },
          ),
          SizedBox(height: 20),
          //TODO: Add days
          // Flexible(
          //   child: GridView(
          //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          //     padding: Edgeinsets.zero
          //     children: List.generate(
          //         7,
          //         (index) => Center(
          //               child: Text(
          //                 DateFormat('EE').format(DateTime(index)).toString(),
          //                 style: TextStyle(fontSize: 14, color: widget.monthYearTextColor),
          //               ),
          //             )),
          //   ),
          // ),
          Expanded(
            child: TabBarView(
              controller: ranger.tabController,
              children: List.generate(12, (tabIndex) => tabView(tabIndex, constraints.maxWidth)),
            ),
          ),
          InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                widget.doneText,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget chevron({bool left = true, bool active = true}) {
    return Expanded(
      child: AnimatedOpacity(
        opacity: active ? 1 : 0.2,
        duration: Duration(milliseconds: 100),
        child: InkWell(
          onTap: active ? () => ranger.tabController.animateTo(ranger.tabController.index + (left ? -1 : 1)) : null,
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Align(
              alignment: left ? Alignment.centerRight : Alignment.centerLeft,
              child: Icon(
                left ? Icons.chevron_left : Icons.chevron_right,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget tabView(int tabIndex, double maxWidth) {
    double itemHeight = ranger.itemHeight;
    double itemWidth = ranger.itemWidth;
    var daysInMonth = DateUtils.getDaysInMonth(ranger.activeYear, tabIndex + 1);
    var itemsPerRole = (maxWidth ~/ itemWidth);
    var isRange = ranger.rangerType == DateRangerType.range;
    return ValueListenableBuilder<DateTimeRange>(
      valueListenable: ranger.dateRange,
      builder: (context, value, child) => GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 3),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        //runSpacing: ranger.runSpacing,
        clipBehavior: Clip.none,
        children: List.generate(daysInMonth, (wrapIndex) {
          var year = ranger.activeYear;
          var month = tabIndex + 1;
          var day = wrapIndex + 1;
          var dateTime = DateTime(year, month, day);
          var isStart = dateTime.compareTo(value.start) == 0;
          var isEnd = dateTime.compareTo(value.end) == 0;
          var primary = dateTime.compareTo(ranger.selectingStart ? value.start : value.end) == 0;
          var secondary = dateTime.compareTo(!ranger.selectingStart ? value.start : value.end) == 0;
          var inRange = dateTime.isBefore(value.end) && dateTime.isAfter(value.start) || (secondary || primary);
          var borderRadius = Radius.circular(itemWidth / 2);

          var inRangeTextColor = colorScheme.onPrimary;
          var outOfRangeTextColor = colorScheme.onBackground;

          ///Positioned at extreme ends
          var isExtremeEnd = day % itemsPerRole == 0;
          var isExtremeStart = day % itemsPerRole == 1;
          var isExtreme = isExtremeStart || isExtremeEnd;
          var isItemsEnd = wrapIndex == daysInMonth - 1;
          return Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                  // width: isItemsEnd && isExtremeStart || isStart && isExtremeEnd || (isExtremeStart && isEnd) || !isRange ? itemWidth : itemWidth,
                  //height: itemHeight,
                  margin: EdgeInsets.only(top: 3, bottom: 3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.horizontal(left: isStart ? borderRadius : Radius.zero, right: isEnd ? borderRadius : Radius.zero),
                      color: inRange && isRange && !(isStart && isEnd) ? colorScheme.secondary : colorScheme.background)),
              InkResponse(
                onTap: () async {
                  var startIsAfterEnd = ranger.selectingStart && !dateTime.compareTo(value.end).isNegative && isRange;
                  var endISBeforeStart = !ranger.selectingStart && dateTime.compareTo(value.start).isNegative && isRange;
                  if (startIsAfterEnd || endISBeforeStart) {
                    widget.onError(startIsAfterEnd ? widget.startDateError : widget.endDateError);
                  } else {
                    ///set the start and end to the same day if is single picker
                    var newRange = isRange
                        ? value.copyWith(start: ranger.selectingStart ? dateTime : value.start, end: !ranger.selectingStart ? dateTime : value.end)
                        : DateTimeRange(start: dateTime, end: dateTime);
                    ranger.dateRange.value = newRange;
                    widget.onRangeChanged(newRange);
                  }
                },
                child: AnimatedContainer(
                    key: ValueKey(dateTime),
                    // width: itemWidth,
                    // height: itemHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primary ? colorScheme.outline : Colors.transparent, width: 2),
                        color: primary || secondary ? colorScheme.primary : Colors.transparent),
                    duration: Duration(milliseconds: 500),
                    child: Text(
                      "${wrapIndex + 1}",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: primary || secondary
                              ? widget.selectedTextColor
                              : inRange && isRange
                                  ? inRangeTextColor
                                  : outOfRangeTextColor),
                    )),
              )
            ],
          );
        }),
      ),
    );
  }
}
