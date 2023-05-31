import 'package:date_ranger_plus/date_ranger.dart';
import 'package:flutter/material.dart';

class Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  var initialDate = DateTime.now();
  var initialDateRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(),
        Padding(
          padding: const EdgeInsets.all(24),
          child: DateRanger(
            initialRange: initialDateRange,
            onRangeChanged: (range) {
              setState(() {
                initialDateRange = range;
              });
            },
          ),
        )
      ],
    ));
  }

  DateRanger singleDatePicker() {
    return DateRanger(
      initialDate: initialDate,
      rangerType: DateRangerType.single,
      onRangeChanged: (range) {
        setState(() {
          initialDate = range.start;
        });
      },
    );
  }

  DateRanger dateRangePicker() {
    return DateRanger(
      initialRange: initialDateRange,
      onRangeChanged: (range) {
        setState(() {
          initialDateRange = range;
        });
      },
    );
  }
}
