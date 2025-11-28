import 'package:equatable/equatable.dart';

abstract class UnitListEvent extends Equatable {
  const UnitListEvent();

  @override
  List<Object?> get props => [];
}

class UnitListFetched extends UnitListEvent {
  const UnitListFetched({this.query, this.page = 0, this.size = 20});

  final String? query;
  final int page;
  final int size;

  @override
  List<Object?> get props => [query, page, size];
}

class UnitListRefreshed extends UnitListEvent {
  const UnitListRefreshed({this.query});

  final String? query;

  @override
  List<Object?> get props => [query];
}

class UnitListLoadMore extends UnitListEvent {
  const UnitListLoadMore();
}

class UnitListSearched extends UnitListEvent {
  const UnitListSearched(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class UnitListDeleted extends UnitListEvent {
  const UnitListDeleted(this.unitId);

  final int unitId;

  @override
  List<Object?> get props => [unitId];
}
