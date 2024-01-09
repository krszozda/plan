import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

class DetailedCoursePage extends StatefulWidget {
  final String courseUrl;

  DetailedCoursePage({required this.courseUrl});

  @override
  _DetailedCoursePageState createState() => _DetailedCoursePageState();
}

class DaySchedule {
  final String date;
  final List<Session> sessions;

  DaySchedule({required this.date, required this.sessions});
}

class Session {
  final String time;
  final Map<String, CourseDetails> courses;

  Session({required this.time, required this.courses});
}

class CourseDetails {
  final String name;

  CourseDetails({required this.name});
}


class _DetailedCoursePageState extends State<DetailedCoursePage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
  Future<List<DaySchedule>> parseSchedule(String html) async {
    try {
    final response = await http.get(Uri.parse(
      html,
    ));
    var document = parser.parse(response.body);
    List<DaySchedule> schedule = [];

    var days = document.querySelectorAll('.nazwaDnia');
    for (var day in days) {
      String date = day.text;
      List<Session> sessions = [];

      var nextRow = day.parent!.nextElementSibling;
      while (nextRow != null && !nextRow.classes.contains('nazwaDnia')) {
        var time = nextRow.querySelector('.godzina')?.text ?? '';
        Map<String, CourseDetails> courses = {};

        var courseCells = nextRow.querySelectorAll('.test, .test2');
        for (var cell in courseCells) {
          String courseName = cell.text;
          courses[courseName] = CourseDetails(
            name: courseName,
          );
        }

        sessions.add(Session(time: time, courses: courses));
        nextRow = nextRow.nextElementSibling;
      }

      schedule.add(DaySchedule(date: date, sessions: sessions));
    }

    return schedule;
    } catch (e, s) {
      log('Error: $e');
      log('Stacktrace: $s');
      return [];
    }
  }

  @override
Widget build(BuildContext context) {
  log('Course url: ${widget.courseUrl}');
  return FutureBuilder<List<DaySchedule>>(
    future: parseSchedule(widget.courseUrl),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(
          color: Colors.white,
            child: Center(child: CircularProgressIndicator())
        );
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        return Scaffold(
          appBar: AppBar(
            title: Text('Plan zajęć'),
            bottom: TabBar(
              controller: _tabController,
              tabs: snapshot.data!.map((day) => Tab(text: day.date)).toList(),
              isScrollable: true,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: snapshot.data!.map((day) {
              return ListView.builder(
                itemCount: day.sessions.length,
                itemBuilder: (context, index) {
                  Session session = day.sessions[index];
                  return ListTile(
                    title: Text(session.time),
                    subtitle: Column(
                      children: session.courses.values.map((course) {
                        return ListTile(
                          title: Text(course.name),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      }
    },
  );
}
}
