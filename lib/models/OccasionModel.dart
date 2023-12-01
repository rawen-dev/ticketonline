class OccasionModel{
  static const String occasionTable = "occasions";
  static const String idColumn = "id";
  static const String createdAtColumn = "created_at";
  static const String nameColumn = "name";
  static const String priceColumn = "price";
  static const String linkColumn = "link";
  static const String descriptionColumn = "description";

  int? id;
  int? price;
  DateTime? createdAt;
  String? name;
  String? link;
  String? description;

  OccasionModel({
    this.id,
    this.price,
    this.createdAt,
    this.name,
    this.link,
    this.description,
  });

  static OccasionModel fromJson(Map<String, dynamic> json) {
    return OccasionModel(
      id: json[idColumn],
      createdAt: DateTime.parse(json[createdAtColumn]),
      name: json[nameColumn],
      price: json[priceColumn],
      link: json[linkColumn],
      description: json[descriptionColumn],
    );
  }

  Map<String, dynamic> toJson() {
    var map = {
      nameColumn: name,
      priceColumn: price,
      linkColumn: link,
      descriptionColumn: description,
    };
    if(id != null)
    {
      map[idColumn] = id.toString();
    }
    return map;
  }
}