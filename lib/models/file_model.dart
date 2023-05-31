class FileModel {
  late String id;
  late String url;
  late String name;
  late String extension;

  FileModel(
      {required this.id, required this.url, required this.name, required this.extension});

  FileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    name = json['name'];
    extension = json['extension'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'name': name,
      'extension': extension,
    };
  }
}