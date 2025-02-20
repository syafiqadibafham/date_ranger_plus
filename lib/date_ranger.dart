library date_ranger;

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'src/primary_page.dart';
part 'src/secondary_page.dart';
part 'utils/enums.dart';
part 'utils/extensions.dart';
part 'src/inherted_ranger.dart';
part 'utils/type_defs.dart';

class DateRanger extends StatefulWidget {
  ///The border color of the active date type __Start date__ or __End date__ and the selected Day.
  ///It is also used as the color of the chevrons that control moving from one month to another.
  final Color? borderColors;

  ///The background color of the date picker.
  final Color? backgroundColor;

  ///The text color for errors that occur when selecting date.
  final Color? errorColor;

  ///The background color of dates that are in range of the selected __Start__ and **End** dates.
  final Color? rangeBackground;

  ///The background color of active dates both **Start** and **End**  dates.
  final Color? activeItemBackground;

  ///The text color of dates(days) that are in range of the selected __Start__ and __End__ dates.
  final Color? inRangeTextColor;

  ///The text color of dates(days) that are the selected __Start__ and __End__ dates.
  final Color? selectedTextColor;

  ///The initial [DateTimeRange] of the picker.
  ///
  ///The picker jumps to the month of the __start date__ on initialization.
  final DateTimeRange? initialRange;

  ///The initial Date of the picker.
  ///
  /// You can use this for and [DateRangerType].
  ///
  /// Usually used with [DateRangerType.single].<bt/>
  /// For [DateRangerType.range] the __start__ and __end__ dates are set to the [initialDate].
  final DateTime? initialDate;

  ///A callback function for the selected date(s).
  ///
  /// For [DateRangerType.single] both the __start__ and __end__ dates are set to the selected date
  final OnRangeChanged? onRangeChanged;

  ///The text color of dates that are not in the range of the selected __start__ and __end__ dates.
  ///
  /// Also the text color of titles for the selection output _Start Date_  and _End date_
  final Color? outOfRangeTextColor;

  ///Defines the type of picker.
  ///
  /// [DateRangerType.range] is the default and the picker selects two dates,
  /// __Start Date__ and __End Date__
  final DateRangerType rangerType;

  ///The DateFormat used for the selection outputs
  final DateFormat? outputDateFormat;

  ///FontSize of the text showing the month and year of the picker.
  ///
  /// Affects the height of the main picker.
  /// See also
  /// - [activeDateBottomSpace]
  final double activeDateFontSize;

  ///The horizontal padding of the main picker.
  ///Affects the height of the main picker
  final double horizontalPadding;

  ///The height of each date(_days_).
  ///
  /// Affects the height of the main picker.
  final double itemHeight;

  ///The vertical space between dates(_days_).
  ///
  /// Affects the height of the main picker.
  final double runSpacing;

  ///The minimum vertical space between the activeDate and the dates(_days).
  final double activeDateBottomSpace;

  final bool showDoubleTapInfo;

  final int minYear;
  final int maxYear;

  ///The error string that ask user to double tap
  final String doubleTapToFindDateTipText;

  ///Change the dateText to your language
  final String dateText;

  ///Change the startDateText to your language
  final String startDateText;

  ///Change the endDateText to your language
  final String endDateText;

  ///Color for the date text value
  final Color? dateTextColor;

  ///Textstyle for date text value
  final TextStyle? dateTextValueTextStyle;

  final Color? monthYearTextColor;

  ///Change done text in Done button in month year selection
  final String doneText;

  ///Change month selection textStyle
  final TextStyle? monthSelectionTextStyle;

  ///Change year selection textStyle
  final TextStyle? yearSelectionTextStyle;

  ///Show Error when you pick a date that;
  ///start after end date
  final String startDateError;

  ///end before start date
  final String endDateError;

  ///A date picker for selecting single dates and date ranges
  const DateRanger({
    Key? key,
    this.borderColors,
    this.backgroundColor,
    this.errorColor,
    this.rangeBackground,
    this.activeItemBackground,
    this.initialRange,
    this.initialDate,
    this.onRangeChanged,
    this.selectedTextColor,
    this.inRangeTextColor,
    this.outOfRangeTextColor,
    this.rangerType = DateRangerType.range,
    this.outputDateFormat,
    this.activeDateFontSize = 16.0,
    this.horizontalPadding = 8,
    this.itemHeight = 32,
    this.runSpacing = 10,
    this.activeDateBottomSpace = 10,
    this.showDoubleTapInfo = true,
    this.minYear = 1940,
    this.maxYear = 2100,
    this.doubleTapToFindDateTipText = "Double tap to find date",
    this.dateTextColor,
    this.dateText = "Date",
    this.startDateText = "Start date",
    this.endDateText = "End date",
    this.dateTextValueTextStyle,
    this.monthYearTextColor,
    this.doneText = "Done",
    this.monthSelectionTextStyle,
    this.yearSelectionTextStyle,
    this.startDateError = "Start date cannot be after end date",
    this.endDateError = "End date cannot be before start date",
  }) : super(key: key);

  @override
  _DateRangerState createState() => _DateRangerState();
}

class _DateRangerState extends State<DateRanger> with SingleTickerProviderStateMixin {
  late double itemWidth = widget.itemHeight + (widget.itemHeight * 0.25);
  late var isRange = widget.rangerType == DateRangerType.range;
  late final initialDate = isRange ? DateTime.now() : widget.initialDate ?? DateTime.now();
  final showInfo = ValueNotifier(false);
  final enableDatePicker = ValueNotifier(false);
  late ValueNotifier<DateTimeRange> dateRange = ValueNotifier(widget.initialRange != null
      ? DateTimeRange(
          start: DateTime(widget.initialRange!.start.year, widget.initialRange!.start.month, widget.initialRange!.start.day),
          end: DateTime(widget.initialRange!.end.year, widget.initialRange!.end.month, widget.initialRange!.end.day))
      : DateTimeRange(end: DateUtils.dateOnly(initialDate), start: DateUtils.dateOnly(initialDate)));
  late var activeYear = dateRange.value.start.year;
  late var tabController = TabController(length: 12, vsync: this);
  final activeTab = ValueNotifier(0);
  var selectingStart = true;
  final errorText = ValueNotifier("");
  var navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      tabController.addListener(() {
        var index = tabController.index;
        activeTab.value = index;
      });
      tabController.animateTo(dateRange.value.start.month - 1);
      if (widget.showDoubleTapInfo) {
        showInfo.value = true;
        await Future.delayed(Duration(seconds: 3), () => showInfo.value = false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    resetForSingleCase();
    return Theme(
      data: ThemeData(
          brightness: Theme.of(context).brightness,
          colorScheme: (Theme.of(context).brightness == Brightness.light ? ColorScheme.light() : ColorScheme.dark()).copyWith(
            secondary: widget.rangeBackground,
            error: widget.errorColor,
            background: widget.backgroundColor,
            primary: widget.activeItemBackground,
            onPrimary: widget.inRangeTextColor,
            onBackground: widget.outOfRangeTextColor,
            outline: widget.borderColors,
          )),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 55,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                pickerOutput(),
                if (widget.rangerType == DateRangerType.range) ...[
                  Center(
                      child: SizedBox(
                          width: 32,
                          child: Divider(
                            endIndent: 12,
                            indent: 12,
                            thickness: 2,
                            color: widget.dateTextValueTextStyle?.color ?? Theme.of(context).colorScheme.onBackground,
                          ))),
                  pickerOutput(false)
                ],
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: showInfo,
            builder: (context, value, child) => AnimatedSize(
                duration: Duration(seconds: 2),
                child: Visibility(
                  visible: value,
                  replacement: SizedBox(height: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Text(
                      widget.doubleTapToFindDateTipText,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12),
                    ),
                  ),
                )),
          ),
          ValueListenableBuilder<bool>(
              valueListenable: enableDatePicker,
              builder: (context, value, child) {
                return value
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            constraints: BoxConstraints(maxHeight: calculateHeight(constraints) + 95),
                            margin: EdgeInsets.only(bottom: 26),
                            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding, vertical: 15).copyWith(top: 0),
                            decoration:
                                BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.6))]),
                            child: InheritedRanger(
                              selectingStart: selectingStart,
                              activeYear: activeYear,
                              tabController: tabController,
                              rangerType: widget.rangerType,
                              activeTab: activeTab,
                              dateRange: dateRange,
                              navKey: navKey,
                              itemHeight: widget.itemHeight,
                              itemWidth: itemWidth,
                              runSpacing: widget.runSpacing,
                              activeDateBottomSpace: widget.activeDateBottomSpace,
                              activeDateFontSize: widget.activeDateFontSize,
                              minYear: widget.minYear,
                              maxYear: widget.maxYear,
                              child: Navigator(
                                key: navKey,
                                onGenerateRoute: (settings) {
                                  Widget widget;
                                  if (settings.name == "/")
                                    widget = PrimaryPage(
                                      onNewDate: onNewDate,
                                      onRangeChanged: onRangeChanged,
                                      onError: onError,
                                      doneText: this.widget.doneText,
                                      monthYearTextColor: this.widget.monthYearTextColor,
                                      selectedTextColor: this.widget.selectedTextColor ?? Theme.of(context).colorScheme.onPrimary,
                                      onTap: () => enableDatePicker.value = false,
                                      startDateError: this.widget.startDateError,
                                      endDateError: this.widget.endDateError,
                                    );
                                  else
                                    widget = SecondaryPage(
                                      dateTime: settings.arguments as DateTime,
                                      monthYearTextColor: this.widget.monthYearTextColor,
                                      doneText: this.widget.doneText,
                                      monthSelectionTextStyle: this.widget.monthSelectionTextStyle,
                                      yearSelectionTextStyle: this.widget.yearSelectionTextStyle,
                                    );
                                  return MaterialPageRoute(builder: (context) => widget);
                                },
                              ),
                            ),
                          );
                        },
                      )
                    : Container();
              }),
          ValueListenableBuilder<String>(
              valueListenable: errorText,
              builder: (context, value, child) => AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    reverseDuration: Duration(seconds: 2),
                    child: value.isEmpty || value == ''
                        ? SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              value,
                              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
                            ),
                          ),
                  )),
        ],
      ),
    );
  }

  double calculateHeight(BoxConstraints constraints) {
    var itemsPerRole = (constraints.maxWidth - (widget.horizontalPadding * 2)) ~/ itemWidth;
    var maxDaysPerMonth = 31;
    return maxDaysPerMonth / itemsPerRole * (widget.itemHeight + widget.runSpacing + widget.activeDateBottomSpace + widget.activeDateFontSize);
  }

  ///adjust selections for single case on state changes with different rangeTypes
  void resetForSingleCase() {
    if (widget.rangerType == DateRangerType.single) {
      selectingStart = true;
      var currentRange = dateRange.value;
      if (currentRange.start.compareTo(currentRange.end) != 0) dateRange.value = currentRange.copyWith(end: currentRange.start);
    }
  }

  onRangeChanged(DateTimeRange range) {
    if (widget.onRangeChanged != null) widget.onRangeChanged!(range);
  }

  void onNewDate(DateTime newDate) {
    return setState(() {
      activeYear = newDate.year;
      tabController.animateTo(newDate.month - 1);
    });
  }

  Widget pickerOutput([bool start = true]) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          selectingStart = start;
          enableDatePicker.value = true;
        }),
        onDoubleTap: () {
          var range = dateRange.value;
          setState(() {
            activeYear = (start ? range.start : range.end).year;
          });
          tabController.animateTo(start ? range.start.month - 1 : range.end.month - 1);
        },
        child: ValueListenableBuilder<bool>(
          valueListenable: enableDatePicker,
          builder: (context, value, child) {
            var isRange = widget.rangerType == DateRangerType.range;
            return AnimatedContainer(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
              decoration: BoxDecoration(
                  border: Border.all(color: (selectingStart && start || !selectingStart && !start) && value ? Theme.of(context).colorScheme.outline : Colors.transparent),
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(7)),
              duration: Duration(milliseconds: 100),
              child: Column(
                crossAxisAlignment: isRange ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isRange ? "${start ? widget.startDateText : widget.endDateText}" : widget.dateText,
                    maxLines: 1,
                    style: TextStyle(color: widget.dateTextColor ?? Theme.of(context).colorScheme.onBackground.withOpacity(0.3), fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  ValueListenableBuilder<DateTimeRange>(
                    valueListenable: dateRange,
                    builder: (context, value, child) => FittedBox(
                      child: Text(
                        (widget.outputDateFormat ?? DateFormat.yMd()).format(start ? value.start : value.end),
                        maxLines: 1,
                        style: widget.dateTextValueTextStyle,
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> onError(String error) async {
    errorText.value = error;
    await Future.delayed(Duration(seconds: 1), () => errorText.value = "");
  }
}
