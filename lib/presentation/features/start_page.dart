import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:plan/presentation/features/schedule_page.dart';

class Course {
  final String name;
  final String link;
  final String schedule;

  Course(this.name, this.link, this.schedule);
}

class CoursesPage extends StatefulWidget {
  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  Future<List<Course>> fetchCourses() async {
    final response = await http.get(Uri.parse(
      'http://www.plan.pwsz.legnica.edu.pl/schedule_view.php?site=show_kierunek.php&id=1',
    ));
    if (response.statusCode == 200) {
      var document = parser.parse(response.body);
      List<dom.Element> links = document.querySelectorAll('a');
      List<Course> courses = [];
      for (var i = 0; i < links.length; i++) {
        String schedule = (i + 1 < links.length &&
                links[i + 1].text.contains('harmonogram na ca³y semestr'))
            ? links[i + 1].attributes['href'] ?? ''
            : '';
        courses.add(
            Course(links[i].text, links[i].attributes['href'] ?? '', schedule));
        if (schedule.isNotEmpty) i++;
         }
      return courses;
    } else {
      throw Exception('Failed to load courses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Harmonogram Studiów'),
      ),
      body: FutureBuilder<List<Course>>(
        future: fetchCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var course = snapshot.data![index];
                return (course.schedule.isNotEmpty) ? ExpansionTile(
                  title: Text(course.name),
                  children: <Widget>[
                    if (course.schedule.isNotEmpty)
                      ListTile(
                        title: Text('Harmonogram zajęć'),
                        onTap: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailedCoursePage(
                                    courseUrl:
                                    "http://www.plan.pwsz.legnica.edu.pl/${course.link}")),
                          ),
                      ),
                  ],
                ) : Container();
              },
            );
          }
        },
      ),
    );
  }
}
