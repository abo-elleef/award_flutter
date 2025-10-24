import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

class HomeGridCard extends StatelessWidget {
  HomeGridCard({required this.title, this.desc = "", this.image = ""});

  final String title;
  final String desc;
  final String image;



  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            // color: Color.fromRGBO(255, 255, 255, 0.8),
            // color: Color(0xffe1ffe1),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            border: Border.all(color: Colors.green)
        ),

        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0, right: 8.0, left: 8.0),
        margin: const EdgeInsets.only(top: 16.0, bottom: 0.0, right: 8.0, left: 8.0),
        child: Column(
          children: <Widget>[
            Column(
              textDirection: AppLocalizations.of(context)!.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Container(
                //   margin: EdgeInsets.only(top: 10, bottom: 10, left: 16.0, right: 0.0),
                //   child: Image.asset("assets/book.png", width: this.fontSize - 4),
                // ),
                // SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      image: DecorationImage(
                        image: AssetImage(this.image.isNotEmpty ? this.image : 'assets/bg.png'),
    fit: BoxFit.cover,
                      ),
                  ),
                  height: 100,
                  width: 100,
                ),
                // Image.asset("assets/book.png"),
                SizedBox(height: 5.0),
                // Title.
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // SizedBox(height: 10.0),
                // description.
                // Text(
                //   desc,
                //   style: TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.normal,
                //   ),
                // )
              ],
            ),
          ],
        ));
  }
}
