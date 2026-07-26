class ReaderResponse {
  final String bookId;
  final String title;
  final String fileUrl;
  final String fileUrlExpiresAt;
  final String encryptionKeyBase64;
  final int totalPages;
  final int currentPage;
  final double progressPercentage;
  final String? lastReadAt;

  ReaderResponse({
    required this.bookId,
    required this.title,
    required this.fileUrl,
    required this.fileUrlExpiresAt,
    required this.encryptionKeyBase64,
    required this.totalPages,
    required this.currentPage,
    required this.progressPercentage,
    this.lastReadAt,
  });

  factory ReaderResponse.fromJson(Map<String, dynamic> json) => ReaderResponse(
        bookId: json["bookId"],
        title: json["title"],
        fileUrl: json["fileUrl"],
        fileUrlExpiresAt: json["fileUrlExpiresAt"],
        encryptionKeyBase64: json["encryptionKeyBase64"],
        totalPages: json["totalPages"],
        currentPage: json["currentPage"],
        progressPercentage: (json["progressPercentage"] as num).toDouble(),
        lastReadAt: json["lastReadAt"],
      );

  Map<String, dynamic> toJson() => {
        "bookId": bookId,
        "title": title,
        "fileUrl": fileUrl,
        "fileUrlExpiresAt": fileUrlExpiresAt,
        "encryptionKeyBase64": encryptionKeyBase64,
        "totalPages": totalPages,
        "currentPage": currentPage,
        "progressPercentage": progressPercentage,
        "lastReadAt": lastReadAt,
      };
}
