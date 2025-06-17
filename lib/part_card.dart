import 'package:flutter/material.dart';

class PartCard extends StatelessWidget {
  PartCard({required this.title, required this.index, required this.listSize, this.fontSize = 28, this.textColor = 0xFF000000});

  final String title;
  final int index;
  final int listSize;
  final double fontSize;
  final int textColor;



  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            // color: Color.fromRGBO(255, 255, 255, 0.8),
            color: Color(0xffe1ffe1),
            borderRadius: BorderRadius.all(Radius.circular(15))),
        padding: const EdgeInsets.only(bottom: 16, right: 8, left: 8),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          children: <Widget>[
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "("+(index+ 1).toString() + ")" ,
                  style: TextStyle(
                    fontSize: fontSize/1.5,
                    color: Color(0xff666666)
                  ),
                ),
                SizedBox(width: 8),
                // Container(
                //   margin: EdgeInsets.only(top: 10, bottom: 10, left: 16.0, right: 0.0),
                //   child: Image.asset("assets/book.png", width: this.fontSize - 4),
                // ),
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
