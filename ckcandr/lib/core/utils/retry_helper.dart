import 'dart:async';
import 'dart:math';

/// Helper class để retry API calls khi gặp lỗi hoặc empty data
class RetryHelper {
  /// Retry một function với exponential backoff
  static Future<T> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
    double backoffMultiplier = 2.0,
    bool Function(T)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        final result = await operation();
        
        // Nếu có shouldRetry function và kết quả cần retry
        if (shouldRetry != null && shouldRetry(result)) {
          if (attempt == maxRetries - 1) {
            // Đây là lần thử cuối cùng, trả về kết quả dù có empty
            return result;
          }
          
          // Chờ trước khi retry
          await Future.delayed(delay);
          delay = Duration(
            milliseconds: (delay.inMilliseconds * backoffMultiplier).round(),
          );
          attempt++;
          continue;
        }
        
        // Kết quả OK, trả về
        return result;
      } catch (e) {
        if (attempt == maxRetries - 1) {
          // Đây là lần thử cuối cùng, throw exception
          rethrow;
        }
        
        // Chờ trước khi retry
        await Future.delayed(delay);
        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffMultiplier).round(),
        );
        attempt++;
      }
    }
    
    // Không bao giờ đến đây, nhưng để đảm bảo type safety
    throw Exception('Max retries exceeded');
  }

  /// Retry cho List data - retry nếu list empty
  static Future<List<T>> retryForList<T>(
    Future<List<T>> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
  }) async {
    return retryWithBackoff<List<T>>(
      operation,
      maxRetries: maxRetries,
      initialDelay: initialDelay,
      shouldRetry: (result) => result.isEmpty,
    );
  }

  /// Retry cho nullable data - retry nếu null
  static Future<T?> retryForNullable<T>(
    Future<T?> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
  }) async {
    return retryWithBackoff<T?>(
      operation,
      maxRetries: maxRetries,
      initialDelay: initialDelay,
      shouldRetry: (result) => result == null,
    );
  }

  /// Tạo random delay để tránh thundering herd
  static Duration randomDelay({
    Duration min = const Duration(milliseconds: 100),
    Duration max = const Duration(milliseconds: 1000),
  }) {
    final random = Random();
    final range = max.inMilliseconds - min.inMilliseconds;
    final randomMs = min.inMilliseconds + random.nextInt(range);
    return Duration(milliseconds: randomMs);
  }
}
