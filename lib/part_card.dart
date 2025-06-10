import 'package:flutter/material.dart';

class PartCard extends StatelessWidget {
  PartCard({required this.title, this.fontSize = 28, this.textColor = 0xFF000000});

  final String title;
  final double fontSize;
  final int textColor;



  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            // color: Color.fromRGBO(255, 255, 255, 0.8),
            color: Color(0xffe1ffe1),
            borderRadius: BorderRadius.all(Radius.circular(15))),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Column(
          children: <Widget>[
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 20, left: 16.0, right: 16.0),
                  padding: EdgeInsets.only(bottom: 20),
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
          ],
        ));
  }
}
