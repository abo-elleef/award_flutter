import 'package:flutter/material.dart';

class PartCard extends StatelessWidget {
  PartCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            // color: Color.fromRGBO(255, 255, 255, 0.8),
            color: Color(0xffe1ffe1),
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
                      fontSize: 28,
                      color: Color(0xff444444),
                    ),
                  ),
                )
              ],
            ),
          ],
        ));
  }
}
