import 'package:equatable/equatable.dart';
import 'package:event_management/features/unit/data/model/page_response.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';

abstract class UnitListState extends Equatable {
  const UnitListState();

  @override
  List<Object?> get props => [];
}

class UnitListInitial extends UnitListState {
  const UnitListInitial();
}

class UnitListLoading extends UnitListState {
  const UnitListLoading();
}

class UnitListSuccess extends UnitListState {
  const UnitListSuccess({required this.pageResponse, this.query});

  final PageResponse<UnitEntity> pageResponse;
  final String? query;

  List<UnitEntity> get units => pageResponse.content;

  UnitListSuccess copyWith({
    PageResponse<UnitEntity>? pageResponse,
    String? query,
  }) {
    return UnitListSuccess(
      pageResponse: pageResponse ?? this.pageResponse,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [pageResponse, query];
}

class UnitListError extends UnitListState {
  const UnitListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
