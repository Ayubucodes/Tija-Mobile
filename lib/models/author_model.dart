class Author {
  final String id;
  final String fullName;
  final String? profilePictureUrl;
  final int totalBooks;
  final int reviewCount;
  final double? averageRating;

  Author({
    required this.id,
    required this.fullName,
    this.profilePictureUrl,
    required this.totalBooks,
    required this.reviewCount,
    this.averageRating,
  });

  factory Author.fromJson(Map<String, dynamic> json) => Author(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    profilePictureUrl: json['profilePictureUrl'] as String?,
    totalBooks: json['totalBooks'] as int,
    reviewCount: json['reviewCount'] as int,
    averageRating: json['averageRating'] as double?,
  );
}

class AuthorDetail {
  final String id;
  final String fullName;
  final String? bio;
  final String? profilePictureUrl;
  final int totalBooks;
  final int reviewCount;
  final double? averageRating;
  final PaginatedBooks books;

  AuthorDetail({
    required this.id,
    required this.fullName,
    this.bio,
    this.profilePictureUrl,
    required this.totalBooks,
    required this.reviewCount,
    this.averageRating,
    required this.books,
  });

  factory AuthorDetail.fromJson(Map<String, dynamic> json) => AuthorDetail(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    bio: json['bio'] as String?,
    profilePictureUrl: json['profilePictureUrl'] as String?,
    totalBooks: json['totalBooks'] as int,
    reviewCount: json['reviewCount'] as int,
    averageRating: json['averageRating'] as double?,
    books: PaginatedBooks.fromJson(json['books'] as Map<String, dynamic>),
  );
}

class Book {
  final String id;
  final String title;
  final String slug;
  final double priceTzs;
  final String? coverImageUrl;
  final String status;
  final AuthorInfo author;
  final List<Genre> genres;
  final String publishedAt;

  Book({
    required this.id,
    required this.title,
    required this.slug,
    required this.priceTzs,
    this.coverImageUrl,
    required this.status,
    required this.author,
    required this.genres,
    required this.publishedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as String,
    title: json['title'] as String,
    slug: json['slug'] as String,
    priceTzs: (json['priceTzs'] as num).toDouble(),
    coverImageUrl: json['coverImageUrl'] as String?,
    status: json['status'] as String,
    author: AuthorInfo.fromJson(json['author'] as Map<String, dynamic>),
    genres: (json['genres'] as List)
        .map((e) => Genre.fromJson(e as Map<String, dynamic>))
        .toList(),
    publishedAt: json['publishedAt'] as String,
  );
}

class AuthorInfo {
  final String id;
  final String fullName;

  AuthorInfo({required this.id, required this.fullName});

  factory AuthorInfo.fromJson(Map<String, dynamic> json) => AuthorInfo(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
  );
}

class Genre {
  final String id;
  final String name;
  final String slug;

  Genre({required this.id, required this.name, required this.slug});

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
    id: json['id'] as String,
    name: json['name'] as String,
    slug: json['slug'] as String,
  );
}

class PaginatedAuthors {
  final List<Author> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedAuthors({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedAuthors.fromJson(Map<String, dynamic> json) =>
      PaginatedAuthors(
        items: (json['items'] as List)
            .map((e) => Author.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCount: json['totalCount'] as int,
        page: json['page'] as int,
        pageSize: json['pageSize'] as int,
        totalPages: json['totalPages'] as int,
        hasNextPage: json['hasNextPage'] as bool,
        hasPreviousPage: json['hasPreviousPage'] as bool,
      );
}

class PaginatedBooks {
  final List<Book> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedBooks({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedBooks.fromJson(Map<String, dynamic> json) => PaginatedBooks(
    items: (json['items'] as List)
        .map((e) => Book.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalCount: json['totalCount'] as int,
    page: json['page'] as int,
    pageSize: json['pageSize'] as int,
    totalPages: json['totalPages'] as int,
    hasNextPage: json['hasNextPage'] as bool,
    hasPreviousPage: json['hasPreviousPage'] as bool,
  );
}

class AuthorDashboard {
  final int totalBooks;
  final int publishedBooks;
  final int totalSales;
  final double totalRevenueTzs;
  final double totalEarningsTzs;
  final int totalReaders;
  final int totalFreeGrants;
  final double totalPaidOutTzs;
  final double pendingBalanceTzs;

  AuthorDashboard({
    required this.totalBooks,
    required this.publishedBooks,
    required this.totalSales,
    required this.totalRevenueTzs,
    required this.totalEarningsTzs,
    required this.totalReaders,
    required this.totalFreeGrants,
    required this.totalPaidOutTzs,
    required this.pendingBalanceTzs,
  });

  factory AuthorDashboard.fromJson(Map<String, dynamic> json) =>
      AuthorDashboard(
        totalBooks: json['totalBooks'] as int,
        publishedBooks: json['publishedBooks'] as int,
        totalSales: json['totalSales'] as int,
        totalRevenueTzs: (json['totalRevenueTzs'] as num).toDouble(),
        totalEarningsTzs: (json['totalEarningsTzs'] as num).toDouble(),
        totalReaders: json['totalReaders'] as int,
        totalFreeGrants: json['totalFreeGrants'] as int,
        totalPaidOutTzs: (json['totalPaidOutTzs'] as num).toDouble(),
        pendingBalanceTzs: (json['pendingBalanceTzs'] as num).toDouble(),
      );
}
