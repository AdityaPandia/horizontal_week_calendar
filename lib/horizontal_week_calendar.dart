library horizontal_week_calendar;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

enum WeekStartFrom {
  Sunday,
  Monday,
}

class HorizontalWeekCalendar extends StatefulWidget {
  final DateTime disabledFromDate;

  /// week start from [WeekStartFrom.Monday]
  final WeekStartFrom? weekStartFrom;

  ///get DateTime on date select
  final Function(DateTime)? onDateChange;

  ///get the list of DateTime on week change
  final Function(List<DateTime>)? onWeekChange;

  /// Active background color
  ///
  /// Default value [Theme.of(context).primaryColor]
  final Color? activeBackgroundColor;

  /// In-Active background color
  ///
  /// Default value [Theme.of(context).primaryColor.withOpacity(.2)]
  final Color? inactiveBackgroundColor;

  /// Disable background color
  ///
  /// Default value [Colors.grey]
  final Color? disabledBackgroundColor;

  /// Active text color
  ///
  /// Default value [Theme.of(context).primaryColor]
  final Color? activeTextColor;

  /// In-Active text color
  ///
  /// Default value [Theme.of(context).primaryColor.withOpacity(.2)]
  final Color? inactiveTextColor;

  /// Disable text color
  ///
  /// Default value [Colors.grey]
  final Color? disabledTextColor;

  /// Active Navigator color
  ///
  /// Default value [Theme.of(context).primaryColor]
  final Color? activeNavigatorColor;

  /// In-Active Navigator color
  ///
  /// Default value [Colors.grey]
  final Color? inactiveNavigatorColor;

  /// Month Color
  ///
  /// Default value [Theme.of(context).primaryColor.withOpacity(.2)]
  final Color? monthColor;

  const HorizontalWeekCalendar({
    super.key,
    this.onDateChange,
    this.onWeekChange,
    this.activeBackgroundColor,
    this.inactiveBackgroundColor,
    this.disabledBackgroundColor,
    this.activeTextColor = Colors.white,
    this.inactiveTextColor,
    this.disabledTextColor,
    this.activeNavigatorColor,
    this.inactiveNavigatorColor,
    this.monthColor,
    this.weekStartFrom = WeekStartFrom.Monday,
    required this.disabledFromDate,
  });

  @override
  State<HorizontalWeekCalendar> createState() => _HorizontalWeekCalendarState();
}

class _HorizontalWeekCalendarState extends State<HorizontalWeekCalendar> {
  CarouselController carouselController = CarouselController();

  DateTime today = DateTime.now();
  DateTime selectedDate = DateTime.now();
  List<DateTime> currentWeek = [];
  int currentWeekIndex = 0;

  List<List<DateTime>> listOfWeeks = [];

  @override
  void initState() {
    initCalender();
    super.initState();
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  initCalender() {
    // List<DateTime> minus3Days = [];
    // List<DateTime> add3Days = [];
    // for (int index = 0; index < 3; index++) {
    //   DateTime minusDate = today.add(Duration(days: -(index + 1)));
    //   minus3Days.add(minusDate);
    //   DateTime addDate = today.add(Duration(days: (index + 1)));
    //   add3Days.add(addDate);
    // }
    // currentWeek.addAll(minus3Days.reversed.toList());
    // currentWeek.add(today);
    // currentWeek.addAll(add3Days);
    // listOfWeeks.add(currentWeek);

    final date = DateTime.now();

    DateTime startOfCurrentWeek = widget.weekStartFrom == WeekStartFrom.Monday
        ? getDate(date.subtract(Duration(days: date.weekday - 1)))
        : getDate(date.subtract(Duration(days: date.weekday % 7)));

    currentWeek.add(startOfCurrentWeek);
    for (int index = 0; index < 6; index++) {
      DateTime addDate = startOfCurrentWeek.add(Duration(days: (index + 1)));
      currentWeek.add(addDate);
    }

    listOfWeeks.add(currentWeek);

    getMorePreviousWeeks();
  }

  getMorePreviousWeeks() {
    List<DateTime> minus7Days = [];
    DateTime startFrom = listOfWeeks.isEmpty
        ? DateTime.now()
        : listOfWeeks[currentWeekIndex].isEmpty
            ? DateTime.now()
            : listOfWeeks[currentWeekIndex][0];

    for (int index = 0; index < 7; index++) {
      DateTime minusDate = startFrom.add(Duration(days: -(index + 1)));
      minus7Days.add(minusDate);
    }
    listOfWeeks.add(minus7Days.reversed.toList());
    setState(() {});
  }

  onDateSelect(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    widget.onDateChange?.call(selectedDate);
  }

  onBackClick() {
    carouselController.nextPage();
  }

  onNextClick() {
    carouselController.previousPage();
  }

  onWeekChange(index) {
    currentWeekIndex = index;
    currentWeek = listOfWeeks[currentWeekIndex];

    if (currentWeekIndex + 1 == listOfWeeks.length) {
      getMorePreviousWeeks();
    }

    widget.onWeekChange?.call(currentWeek);
    setState(() {});
  }

  // =================

  isNextDisabled() {
    return listOfWeeks[currentWeekIndex].last.isBefore(widget.disabledFromDate);
  }

  isCurrentYear() {
    return DateFormat('yyyy').format(currentWeek[0]) ==
        DateFormat('yyyy').format(today);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var withOfScreen = MediaQuery.of(context).size.width;

    double boxHeight = withOfScreen / 7;

    return currentWeek.isEmpty
        ? const SizedBox()
        : Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      onBackClick();
                    },
                    child: Icon(
                      Icons.navigate_before_rounded,
                      size: 40.sp,
                      color: const Color(0xFF02012D),
                    ),
                  ),
                  Text(
                      isCurrentYear()
                          ? DateFormat('MMM, y').format(
                              currentWeek[0],
                            )
                          : DateFormat('MMMM yyyy').format(
                              currentWeek[0],
                            ),
                      style: GoogleFonts.outfit(
                          fontSize: 18.sp, fontWeight: FontWeight.w500)),
                  GestureDetector(
                    onTap: isNextDisabled()
                        ? () {
                            onNextClick();
                          }
                        : null,
                    child: Icon(
                      Icons.navigate_next_rounded,
                      size: 40.sp,
                      color: const Color(0xFF02012D),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              CarouselSlider(
                carouselController: carouselController,
                items: [
                  if (listOfWeeks.isNotEmpty)
                    for (int ind = 0; ind < listOfWeeks.length; ind++)
                      Container(
                        // margin: EdgeInsets.only(bottom: 10.h),
                        height: boxHeight,

                        width: withOfScreen,
                        color: const Color(0xFFDDE9F7),
                        // color: Colors.red,
                        child: Row(
                          children: [
                            for (int weekIndex = 0;
                                weekIndex < listOfWeeks[ind].length;
                                weekIndex++)
                              Expanded(
                                child: GestureDetector(
                                  onTap: listOfWeeks[ind][weekIndex]
                                          .isBefore(widget.disabledFromDate)
                                      ? () {
                                          onDateSelect(
                                            listOfWeeks[ind][weekIndex],
                                          );
                                        }
                                      : null,
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 7),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.w),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(
                                              111, 140, 176, 0.41),
                                          offset: Offset(4, 4),
                                          blurRadius: 20,
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: Color.fromRGBO(
                                              255, 255, 255, 0.8),
                                          offset: Offset(-6, -6),
                                          blurRadius: 20,
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: Color.fromRGBO(
                                              114, 142, 171, 0.1),
                                          offset: Offset(2, 2),
                                          blurRadius: 4,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                      color: DateFormat('dd-MM-yyyy').format(
                                                  listOfWeeks[ind]
                                                      [weekIndex]) ==
                                              DateFormat('dd-MM-yyyy')
                                                  .format(selectedDate)
                                          ? widget.activeBackgroundColor ??
                                              theme.primaryColor
                                          : listOfWeeks[ind][weekIndex]
                                                  .isBefore(
                                                      widget.disabledFromDate)
                                              ? widget.inactiveBackgroundColor ??
                                                  theme.primaryColor
                                                      .withOpacity(.2)
                                              : widget.disabledBackgroundColor ??
                                                  Colors.grey,
                                      border: Border.all(
                                          width: 1,
                                          color: const Color(0xFFD6E3F3)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        FittedBox(
                                          child: Text(
                                            // "$weekIndex: ${listOfWeeks[ind][weekIndex] == DateTime.now()}",
                                            "${listOfWeeks[ind][weekIndex].day}",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.outfit(
                                              color: DateFormat('dd-MM-yyyy')
                                                          .format(listOfWeeks[
                                                                  ind]
                                                              [weekIndex]) ==
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(selectedDate)
                                                  ? widget.activeTextColor ??
                                                      Colors.white
                                                  : listOfWeeks[ind][weekIndex]
                                                          .isBefore(widget
                                                              .disabledFromDate)
                                                      ? widget.inactiveTextColor ??
                                                          Colors.white
                                                              .withOpacity(.2)
                                                      : widget.disabledTextColor ??
                                                          Colors.white,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10.822.sp,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          DateFormat(
                                            'EEE',
                                          ).format(
                                            listOfWeeks[ind][weekIndex],
                                          ),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.outfit(
                                              color: DateFormat('dd-MM-yyyy')
                                                          .format(listOfWeeks[
                                                                  ind]
                                                              [weekIndex]) ==
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(selectedDate)
                                                  ? widget.activeTextColor ??
                                                      Colors.white
                                                  : listOfWeeks[ind][weekIndex]
                                                          .isBefore(widget
                                                              .disabledFromDate)
                                                      ? widget.inactiveTextColor ??
                                                          Colors.white
                                                              .withOpacity(.2)
                                                      : widget.disabledTextColor ??
                                                          Colors.white,
                                              fontSize: 10.822.sp,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                ],
                options: CarouselOptions(
                  scrollPhysics: const ClampingScrollPhysics(),
                  height: 47.7.h,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                  reverse: true,
                  onPageChanged: (index, reason) {
                    onWeekChange(index);
                  },
                ),
              ),
            ],
          );
  }
}
