class ApiStatusResponseCode {
  static const invalidCREDENTIALS = 'INVALID_CREDS';
  static const validCREDENTIALS = 'SUCCESS';
  static const failResponse = 'FAIL';
  static const passwordExpired = 'PASSWORD_EXPIRED';
  static const badPasswordFormat = 'BAD_PASSWORD';
  static const notFound = 'NOT_FOUND';
  static const overREPAYMENT = 'OVER_REPAYMENT';
  static const duplicate = 'DUPLICATE';
  static const pinExpired = 'PIN_EXPIRED';
  static const pinMaxAttempts = 'EXCEEDED_INVALID_ATTEMPTS';
  static const tokenExpiredStatus = 'Unauthorized';
  static const duplicateResponse = 'DUPLICATE';
  static const insufficientBalance = 'INSUFFICIENT_BALANCE';
  static const accountWithIssue = 'NOT_ALLOWED_TO_TRANSACT';
  static const invalidDestinationAccount = 'INVALID_DESTINATION_ACCOUNT';
  static const notAllowed = 'NOT_ALLOWED';
  static const exception = 'EXCEPTION';
  static const timeoutExceptionResponse = 'TIMEOUT_EXC';
  static const failedResponse = 'FAILED';
}
