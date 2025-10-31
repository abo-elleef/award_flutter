import 'package:flutter/material.dart';

import 'chapter_card.dart';
import 'part_card.dart';
import 'details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

class ChapterView extends StatefulWidget {
  final body;
  final department;
  late double fontSize;
  late int textColor;

  ChapterView(this.body, this.department);

  @override
  _ChapterViewState createState() => _ChapterViewState(body, department);
}

class _ChapterViewState extends State<ChapterView> {
  _ChapterViewState(this.poem, this.department);

  var poem;
  var department;
  late double fontSize = 24;
  late int textColor = 0xFF000000;

  void fetchUserPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      fontSize = pref.getDouble('fontSize') ?? fontSize;
      textColor = pref.getInt('textColor') ?? textColor;
    });
  }

  void openDetailsPage(BuildContext ctx, int chapterIndex) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          //      return Details(poem, lines, links);
          //       return Details(poem['id'], chapterIndex, '');
          return Details(
            poem['chapters'][chapterIndex]['name'],
            poem['id'],
            this.department,
            chapterIndex,
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
  }

  List<Widget> buildChapters() {
    List chapters = poem['chapters'] as List;
    List<Widget> items = [];
    chapters.asMap().forEach((index, chapter) {
      items.add(
        GestureDetector(
          onTap: () {
            openDetailsPage(context, index);
          },
          // child: ChapterCard(title: chapter["name"])));
          child: PartCard(
            title: chapter["name"].toString(),
            index: index,
            listSize: chapters.length,
            fontSize: fontSize,
            textColor: textColor,
          ),
        ),
      );
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocalizations.of(context)!.localeName == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text("الفصول"),
          backgroundColor: Colors.green,
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        body: DecoratedBox(
          position: DecorationPosition.background,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buildChapters(),
                ),
              )
            )
          )
        ),
      ),
    );
  }
}
