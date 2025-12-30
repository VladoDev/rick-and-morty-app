abstract class UseCase<Out, In> {
  Future<Out> call(In input);
}

class NoParams {
  const NoParams();
}
