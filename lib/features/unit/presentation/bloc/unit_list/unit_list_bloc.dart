import 'package:bloc/bloc.dart';
import 'package:event_management/features/unit/data/model/page_response.dart';
import 'package:event_management/features/unit/domain/entity/unit_entity.dart';
import 'package:event_management/features/unit/domain/repository/unit_repository.dart';
import 'package:event_management/features/unit/presentation/bloc/unit_list/unit_list_event.dart';
import 'package:event_management/features/unit/presentation/bloc/unit_list/unit_list_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class UnitListBloc extends Bloc<UnitListEvent, UnitListState> {
  UnitListBloc(this._unitRepository) : super(const UnitListInitial()) {
    on<UnitListFetched>(_onFetched);
    on<UnitListRefreshed>(_onRefreshed);
    on<UnitListLoadMore>(_onLoadMore);
    on<UnitListSearched>(_onSearched);
    on<UnitListDeleted>(_onDeleted);
  }

  final UnitRepository _unitRepository;
  String? _currentQuery;
  int _currentPage = 0;

  Future<void> _onFetched(
    UnitListFetched event,
    Emitter<UnitListState> emit,
  ) async {
    emit(const UnitListLoading());

    try {
      final pageResponse = await _unitRepository.listUnits(
        query: event.query,
        page: event.page,
        size: event.size,
      );
      _currentQuery = event.query;
      _currentPage = event.page;
      emit(UnitListSuccess(pageResponse: pageResponse, query: event.query));
    } catch (e) {
      emit(UnitListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRefreshed(
    UnitListRefreshed event,
    Emitter<UnitListState> emit,
  ) async {
    if (state is UnitListSuccess) {
      final currentState = state as UnitListSuccess;
      emit(
        UnitListSuccess(
          pageResponse: currentState.pageResponse,
          query: currentState.query,
        ),
      );
    }

    emit(const UnitListLoading());

    try {
      final pageResponse = await _unitRepository.listUnits(
        query: event.query ?? _currentQuery,
      );
      _currentQuery = event.query ?? _currentQuery;
      _currentPage = 0;
      emit(
        UnitListSuccess(
          pageResponse: pageResponse,
          query: event.query ?? _currentQuery,
        ),
      );
    } catch (e) {
      emit(UnitListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadMore(
    UnitListLoadMore event,
    Emitter<UnitListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UnitListSuccess) return;
    if (!currentState.pageResponse.hasNext) return;

    try {
      final nextPage = _currentPage + 1;
      final pageResponse = await _unitRepository.listUnits(
        query: _currentQuery,
        page: nextPage,
      );

      final updatedContent = [
        ...currentState.pageResponse.content,
        ...pageResponse.content,
      ];

      final updatedPageResponse = PageResponse<UnitEntity>(
        content: updatedContent,
        page: pageResponse.page,
        size: pageResponse.size,
        totalElements: pageResponse.totalElements,
        totalPages: pageResponse.totalPages,
        first: pageResponse.first,
        last: pageResponse.last,
        hasNext: pageResponse.hasNext,
        hasPrevious: pageResponse.hasPrevious,
        numberOfElements: pageResponse.numberOfElements,
        empty: pageResponse.empty,
      );

      _currentPage = nextPage;
      emit(
        UnitListSuccess(
          pageResponse: updatedPageResponse,
          query: _currentQuery,
        ),
      );
    } catch (e) {
      emit(UnitListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onSearched(
    UnitListSearched event,
    Emitter<UnitListState> emit,
  ) async {
    emit(const UnitListLoading());

    try {
      final pageResponse = await _unitRepository.listUnits(
        query: event.query.isEmpty ? null : event.query,
      );
      _currentQuery = event.query.isEmpty ? null : event.query;
      _currentPage = 0;
      emit(UnitListSuccess(pageResponse: pageResponse, query: _currentQuery));
    } catch (e) {
      emit(UnitListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDeleted(
    UnitListDeleted event,
    Emitter<UnitListState> emit,
  ) async {
    try {
      await _unitRepository.deleteUnit(event.unitId);
      add(UnitListRefreshed(query: _currentQuery));
    } catch (e) {
      emit(UnitListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
