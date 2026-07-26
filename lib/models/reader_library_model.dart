import 'dart:convert';

List<ReaderLibraryBook> readerLibraryBookFromJson(String str) =>
    List<ReaderLibraryBook>.from(
      json.decode(str).map((x) => ReaderLibraryBook.fromJson(x)),
    );

String readerLibraryBookToJson(List<ReaderLibraryBook> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReaderLibraryBook {
  final String bookId;
  final String title;
  final String slug;
  final String? coverImageUrl;
  final String authorName;
  final double priceTzs;
  final String accessType;
  final String? grantType;
  final int? currentPage;
  final double? progressPercentage;
  final DateTime? lastReadAt;

  ReaderLibraryBook({
    required this.bookId,
    required this.title,
    required this.slug,
    this.coverImageUrl,
    required this.authorName,
    required this.priceTzs,
    required this.accessType,
    this.grantType,
    this.currentPage,
    this.progressPercentage,
    this.lastReadAt,
  });

  factory ReaderLibraryBook.fromJson(Map<String, dynamic> json) =>
      ReaderLibraryBook(
        bookId: json["bookId"],
        title: json["title"],
        slug: json["slug"],
        coverImageUrl: json["coverImageUrl"],
        authorName: json["authorName"],
        priceTzs: (json["priceTzs"] as num).toDouble(),
        accessType: json["accessType"],
        grantType: json["grantType"],
        currentPage: json["currentPage"],
        progressPercentage: json["progressPercentage"]?.toDouble(),
        lastReadAt: json["lastReadAt"] != null
            ? DateTime.parse(json["lastReadAt"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "bookId": bookId,
        "title": title,
        "slug": slug,
        "coverImageUrl": coverImageUrl,
        "authorName": authorName,
        "priceTzs": priceTzs,
        "accessType": accessType,
        "grantType": grantType,
        "currentPage": currentPage,
        "progressPercentage": progressPercentage,
        "lastReadAt": lastReadAt?.toIso8601String(),
      };
}
