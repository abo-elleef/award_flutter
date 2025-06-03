import 'package:flutter/cupertino.dart';

class Poem {
  final String id;
  final String name;
  final String desc;

  Poem({required this.id, required this.name, required this.desc});

  factory Poem.fromJson(Map<String, dynamic> json){
    return Poem(
        id: json['id'],
        name: json['name'],
        desc: json['desc'] ?? ""
    );
  }
}