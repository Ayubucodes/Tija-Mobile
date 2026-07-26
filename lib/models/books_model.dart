// To parse this JSON data, do
//
//     final books = booksFromJson(jsonString);

import 'dart:convert';

Books booksFromJson(String str) => Books.fromJson(json.decode(str));

String booksToJson(Books data) => json.encode(data.toJson());

class Books {
  List<Item> items;
  int totalCount;
  int page;
  int pageSize;
  int totalPages;
  bool hasNextPage;
  bool hasPreviousPage;

  Books({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory Books.fromJson(Map<String, dynamic> json) => Books(
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    totalCount: json["totalCount"],
    page: json["page"],
    pageSize: json["pageSize"],
    totalPages: json["totalPages"],
    hasNextPage: json["hasNextPage"],
    hasPreviousPage: json["hasPreviousPage"],
  );

  Map<String, dynamic> toJson() => {
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "totalCount": totalCount,
    "page": page,
    "pageSize": pageSize,
    "totalPages": totalPages,
    "hasNextPage": hasNextPage,
    "hasPreviousPage": hasPreviousPage,
  };
}

class Item {
  String id;
  String title;
  String slug;
  double priceTzs;
  String coverImageUrl;
  String status;
  Author author;
  List<Genre> genres;
  DateTime publishedAt;

  Item({
    required this.id,
    required this.title,
    required this.slug,
    required this.priceTzs,
    required this.coverImageUrl,
    required this.status,
    required this.author,
    required this.genres,
    required this.publishedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    title: json["title"],
    slug: json["slug"],
    priceTzs: (json["priceTzs"] as num).toDouble(),
    coverImageUrl: json["coverImageUrl"],
    status: json["status"],
    author: Author.fromJson(json["author"]),
    genres: List<Genre>.from(json["genres"].map((x) => Genre.fromJson(x))),
    publishedAt: DateTime.parse(json["publishedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "slug": slug,
    "priceTzs": priceTzs,
    "coverImageUrl": coverImageUrl,
    "status": status,
    "author": author.toJson(),
    "genres": List<dynamic>.from(genres.map((x) => x.toJson())),
    "publishedAt": publishedAt.toIso8601String(),
  };
}

class Author {
  String id;
  String fullName;

  Author({required this.id, required this.fullName});

  factory Author.fromJson(Map<String, dynamic> json) =>
      Author(id: json["id"], fullName: json["fullName"]);

  Map<String, dynamic> toJson() => {"id": id, "fullName": fullName};
}

class Genre {
  String id;
  String name;
  String slug;

  Genre({required this.id, required this.name, required this.slug});

  factory Genre.fromJson(Map<String, dynamic> json) =>
      Genre(id: json["id"], name: json["name"], slug: json["slug"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "slug": slug};
}

BookDetail bookDetailFromJson(String str) =>
    BookDetail.fromJson(json.decode(str));

String bookDetailToJson(BookDetail data) => json.encode(data.toJson());

class BookDetail {
  String id;
  String title;
  String slug;
  String description;
  double priceTzs;
  String coverImageUrl;
  String status;
  DateTime publishedAt;
  Author author;
  String bookFileUrl;
  int totalPages;
  List<Genre> genres;
  DateTime createdAt;

  BookDetail({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.priceTzs,
    required this.coverImageUrl,
    required this.status,
    required this.publishedAt,
    required this.author,
    required this.bookFileUrl,
    required this.totalPages,
    required this.genres,
    required this.createdAt,
  });

  factory BookDetail.fromJson(Map<String, dynamic> json) => BookDetail(
    id: json["id"],
    title: json["title"],
    slug: json["slug"],
    description: json["description"],
    priceTzs: (json["priceTzs"] as num).toDouble(),
    coverImageUrl: json["coverImageUrl"],
    status: json["status"],
    publishedAt: DateTime.parse(json["publishedAt"]),
    author: Author.fromJson(json["author"]),
    bookFileUrl: json["bookFileUrl"],
    totalPages: json["totalPages"],
    genres: List<Genre>.from(json["genres"].map((x) => Genre.fromJson(x))),
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "slug": slug,
    "description": description,
    "priceTzs": priceTzs,
    "coverImageUrl": coverImageUrl,
    "status": status,
    "publishedAt": publishedAt.toIso8601String(),
    "author": author.toJson(),
    "bookFileUrl": bookFileUrl,
    "totalPages": totalPages,
    "genres": List<dynamic>.from(genres.map((x) => x.toJson())),
    "createdAt": createdAt.toIso8601String(),
  };
}
