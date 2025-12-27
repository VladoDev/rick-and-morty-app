sealed class Result<T> {
  const Result();
  R when<R>({
    required R Function(T data) ok,
    required R Function(Object error, StackTrace st) err,
  });
}

class Ok<T> extends Result<T> {
  final T data;
  const Ok(this.data);

  @override
  R when<R>({
    required R Function(T data) ok,
    required R Function(Object error, StackTrace st) err,
  }) {
    return ok(data);
  }
}

class Err<T> extends Result<T> {
  final Object error;
  final StackTrace st;
  const Err(this.error, this.st);

  @override
  R when<R>({
    required R Function(T data) ok,
    required R Function(Object error, StackTrace st) err,
  }) {
    return err(error, st);
  }
}
