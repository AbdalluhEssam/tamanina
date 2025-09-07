import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base class for all use cases
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case when no parameters are needed
class NoParams {
  const NoParams();
}
