/// Lightweight success/failure wrapper used by repositories so callers handle
/// errors explicitly instead of relying on thrown exceptions bubbling through
/// the UI. Replace with a richer Failure hierarchy as features land.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) ok,
    required R Function(Object error, StackTrace? stack) err,
  }) {
    final self = this;
    return switch (self) {
      Ok<T>(:final value) => ok(value),
      Err<T>(:final error, :final stack) => err(error, stack),
    };
  }
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.error, [this.stack]);
  final Object error;
  final StackTrace? stack;
}
