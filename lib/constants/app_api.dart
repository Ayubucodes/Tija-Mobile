class AppApi {
  static Future<String> appURL(String url) async {
    String baseURL = 'https://api.ebooks.tija.co.tz/api';
    String dynamicURL = baseURL + url;
    return dynamicURL;
  }

  static final getBooksUrl = '/books';
  static final getBooksFullUrl = appURL(getBooksUrl);

  static final loginUrl = '/auth/login';
  static final loginFullUrl = appURL(loginUrl);

  static final registerUrl = '/auth/register';
  static final registerFullUrl = appURL(registerUrl);

  static final registerAuthorUrl = '/auth/register/author';
  static final registerAuthorFullUrl = appURL(registerAuthorUrl);

  static final forgotPasswordUrl = '/auth/forgot-password';
  static final forgotPasswordFullUrl = appURL(forgotPasswordUrl);

  static final authorsUrl = '/authors';
  static get authorsFullUrl => appURL(authorsUrl);

  static Future<String> authorByIdFullUrl(String id) async {
    return appURL('/authors/$id');
  }

  static Future<String> bookByIdFullUrl(String id) async {
    return appURL('/books/$id');
  }

  static final genresUrl = '/genres';
  static get genresFullUrl => appURL(genresUrl);

  static Future<String> readerOpenBookFullUrl(String bookId) async {
    return appURL('/reader/books/$bookId/open');
  }

  static Future<String> readerProgressFullUrl(String bookId) async {
    return appURL('/reader/books/$bookId/progress');
  }

  static final uploadBookUrl = '/books';
  static get uploadBookFullUrl => appURL(uploadBookUrl);

  static Future<String> uploadBookFileFullUrl(String bookId) async {
    return appURL('/uploads/book-file/$bookId');
  }

  static final uploadCoverUrl = '/uploads/cover';
  static get uploadCoverFullUrl => appURL(uploadCoverUrl);

  static final authorDashboardUrl = '/author/dashboard/summary';
  static get authorDashboardFullUrl => appURL(authorDashboardUrl);

  static final readerLibraryUrl = '/reader/library';
  static get readerLibraryFullUrl => appURL(readerLibraryUrl);

  static final initiatePaymentUrl = '/payments/initiate';
  static get initiatePaymentFullUrl => appURL(initiatePaymentUrl);

  static final requestPayoutUrl = '/payouts/request';
  static get requestPayoutFullUrl => appURL(requestPayoutUrl);

  static Future<String> submitReviewFullUrl(String bookId) async {
    return appURL('/books/$bookId/reviews');
  }

  static Future<String> getReviewsFullUrl(String bookId) async {
    return appURL('/books/$bookId/reviews');
  }

  static final authorBooksUrl = '/books/my';
  static get authorBooksFullUrl => appURL(authorBooksUrl);

  static Future<String> updateBookFullUrl(String id) async {
    return appURL('/books/$id');
  }

  static Future<String> deleteBookFullUrl(String id) async {
    return appURL('/books/$id');
  }

  static Future<String> submitBookFullUrl(String id) async {
    return appURL('/books/$id/submit');
  }

  static final profileUrl = '/profile';
  static get profileFullUrl => appURL(profileUrl);
}
