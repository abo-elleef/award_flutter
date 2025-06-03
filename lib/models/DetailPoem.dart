class DetailPoem {
  final String id;
  final String name;
  final String desc;

  DetailPoem({ required this.id, required this.name, required this.desc});

  factory DetailPoem.fromJson(Map<String, dynamic> json){
    return DetailPoem(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
    );
  }
}