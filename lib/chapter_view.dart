import 'package:flutter/material.dart';

import 'chapter_card.dart';
import 'details_screen.dart';

class ChapterView extends StatefulWidget {
  final body;
  final department;

  ChapterView(this.body, this.department);

  @override
  _ChapterViewState createState() => _ChapterViewState(body, department);
}

class _ChapterViewState extends State<ChapterView> {
  _ChapterViewState(this.poem, this.department);

  var poem;
  var department;

  void openDetailsPage(BuildContext ctx, int chapterIndex) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
//      return Details(poem, lines, links);
//       return Details(poem['id'], chapterIndex, '');
      return Details(poem['chapters'][chapterIndex]['name'], poem['id'], this.department, chapterIndex);
    }));
  }

  List<Widget> buildChapters() {
    List chapters = poem['chapters'] as List;
    List<Widget> items = [];
    chapters.asMap().forEach((index, chapter) {
      items.add(GestureDetector(
          onTap: () {
            openDetailsPage(context, index);
          },
          child: ChapterCard(title: chapter["name"])));
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl, // set this property
        child: Scaffold(
            appBar: AppBar(
                title: Text("الفصول"),
                backgroundColor: Colors.green,
                titleTextStyle: TextStyle(color: Colors.white)
            ),
            body: DecoratedBox(
                position: DecorationPosition.background,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/bg.png'), fit: BoxFit.cover),
                ),
                child: SingleChildScrollView(
                    child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: buildChapters(),
                  ),
                )))));
  }
}
