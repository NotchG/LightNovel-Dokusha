import 'dart:convert';

class NovelItem {

  String Title, Img, Url = "";

  NovelItem(this.Title, this.Img, this.Url);

  factory NovelItem.fromJson(Map<String, dynamic> jsonData) {
    return NovelItem(
      jsonData['title'],
      jsonData['img'],
      jsonData['url'],
    );
  }

  static Map<String, dynamic> toMap(NovelItem novel) => {
    'title': novel.Title,
    'img': novel.Img,
    'url': novel.Url,
  };

  static String encode(List<NovelItem> novels) => json.encode(
    novels
        .map<Map<String, dynamic>>((novel) => NovelItem.toMap(novel))
        .toList(),
  );

  static List<NovelItem> decode(String novels) =>
      (json.decode(novels) as List<dynamic>)
          .map<NovelItem>((item) => NovelItem.fromJson(item))
          .toList();

}