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
  String? coverImageUrl;
  String status;
  Author author;
  List<Genre> genres;
  DateTime? publishedAt;

  Item({
    required this.id,
    required this.title,
    required this.slug,
    required this.priceTzs,
    this.coverImageUrl,
    required this.status,
    required this.author,
    required this.genres,
    this.publishedAt,
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
    publishedAt: json["publishedAt"] != null
        ? DateTime.parse(json["publishedAt"])
        : null,
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
    "publishedAt": publishedAt?.toIso8601String(),
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
  String? coverImageUrl;
  String status;
  DateTime? publishedAt;
  Author author;
  String? bookFileUrl;
  int totalPages;
  List<Genre> genres;
  DateTime createdAt;

  BookDetail({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.priceTzs,
    this.coverImageUrl,
    required this.status,
    this.publishedAt,
    required this.author,
    this.bookFileUrl,
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
    publishedAt: json["publishedAt"] != null
        ? DateTime.parse(json["publishedAt"])
        : null,
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
    "publishedAt": publishedAt?.toIso8601String(),
    "author": author.toJson(),
    "bookFileUrl": bookFileUrl,
    "totalPages": totalPages,
    "genres": List<dynamic>.from(genres.map((x) => x.toJson())),
    "createdAt": createdAt.toIso8601String(),
  };
}

Review reviewFromJson(String str) => Review.fromJson(json.decode(str));

String reviewToJson(Review data) => json.encode(data.toJson());

class Review {
  String id;
  String userId;
  String reviewerName;
  String? reviewerProfilePictureUrl;
  String bookId;
  String bookTitle;
  int rating;
  String comment;
  DateTime createdAt;
  DateTime? lastModifiedAt;

  Review({
    required this.id,
    required this.userId,
    required this.reviewerName,
    this.reviewerProfilePictureUrl,
    required this.bookId,
    required this.bookTitle,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.lastModifiedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json["id"],
    userId: json["userId"],
    reviewerName: json["reviewerName"],
    reviewerProfilePictureUrl: json["reviewerProfilePictureUrl"],
    bookId: json["bookId"],
    bookTitle: json["bookTitle"],
    rating: json["rating"],
    comment: json["comment"],
    createdAt: DateTime.parse(json["createdAt"]),
    lastModifiedAt: json["lastModifiedAt"] != null
        ? DateTime.parse(json["lastModifiedAt"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "reviewerName": reviewerName,
    "reviewerProfilePictureUrl": reviewerProfilePictureUrl,
    "bookId": bookId,
    "bookTitle": bookTitle,
    "rating": rating,
    "comment": comment,
    "createdAt": createdAt.toIso8601String(),
    "lastModifiedAt": lastModifiedAt?.toIso8601String(),
  };
}

Reviews reviewsFromJson(String str) => Reviews.fromJson(json.decode(str));

String reviewsToJson(Reviews data) => json.encode(data.toJson());

class Reviews {
  List<Review> items;
  int totalCount;
  int page;
  int pageSize;
  int totalPages;
  bool hasNextPage;
  bool hasPreviousPage;

  Reviews({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory Reviews.fromJson(Map<String, dynamic> json) => Reviews(
    items: List<Review>.from(json["items"].map((x) => Review.fromJson(x))),
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
