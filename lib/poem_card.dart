import 'package:flutter/material.dart';

class PoemCard extends StatelessWidget {
  PoemCard({required this.title, this.desc = '', this.fontSize = 24, this.textColor = 0xff444444 });

  final String title;
  final String desc;
  final double fontSize;
  // late int textColor = 0xff3a863d;
  final int textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.8),
            borderRadius: BorderRadius.all(Radius.circular(15))),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
        child: Column(
          children: <Widget>[
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
                  child: Image.asset("assets/book.png", width: 16),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Color(textColor),
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    child: Text(
                      desc,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
