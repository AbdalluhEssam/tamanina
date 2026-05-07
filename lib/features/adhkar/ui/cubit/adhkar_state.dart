part of 'adhkar_cubit.dart';

abstract class AdhkarState extends Equatable {
  const AdhkarState();

  @override
  List<Object> get props => [];
}

class AdhkarInitial extends AdhkarState {}

class AdhkarLoading extends AdhkarState {}

class AdhkarLoaded extends AdhkarState {
  final List<AdhkarModel> adhkarList;
  final AdhkarCategory category;

  const AdhkarLoaded({
    required this.adhkarList,
    required this.category,
  });

  @override
  List<Object> get props => [adhkarList, category];
}

class AdhkarError extends AdhkarState {
  final String message;

  const AdhkarError({required this.message});

  @override
  List<Object> get props => [message];
}
