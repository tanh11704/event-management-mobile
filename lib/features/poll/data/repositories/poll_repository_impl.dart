import 'package:dio/dio.dart';
import 'package:event_management/features/poll/data/datasources/poll_api_client.dart';
import 'package:event_management/features/poll/data/models/create_poll_dto.dart';
import 'package:event_management/features/poll/data/models/export_format.dart';
import 'package:event_management/features/poll/data/models/my_voted_options_response.dart';
import 'package:event_management/features/poll/data/models/poll_response.dart';
import 'package:event_management/features/poll/data/models/poll_stats_response.dart';
import 'package:event_management/features/poll/data/models/update_poll_dto.dart';
import 'package:event_management/features/poll/data/models/vote_poll_dto.dart';
import 'package:event_management/features/poll/domain/repositories/poll_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PollRepository)
class PollRepositoryImpl implements PollRepository {
  PollRepositoryImpl(this._pollApiClient);

  final PollApiClient _pollApiClient;

  @override
  Future<PollResponse> createPoll(CreatePollDto pollDto) async {
    try {
      return await _pollApiClient.createPoll(pollDto);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể tạo poll.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<PollResponse> getPoll(int pollId) async {
    try {
      return await _pollApiClient.getPoll(pollId);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể lấy thông tin poll.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<List<PollResponse>> getPollsByEvent(int eventId) async {
    try {
      final result = await _pollApiClient.getPollsByEvent(eventId);
      return result;
    } on DioException catch (e) {
      // If response is 200 but data is null or empty, return empty list
      if (e.response?.statusCode == 200) {
        final responseData = e.response?.data;
        if (responseData == null ||
            responseData is List && responseData.isEmpty) {
          return <PollResponse>[];
        }
      }
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể lấy danh sách polls.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      // If it's a type error (null parsing), return empty list
      final errorString = e.toString();
      if (errorString.contains('null') &&
          (errorString.contains('String') ||
              errorString.contains('subtype') ||
              errorString.contains('Null'))) {
        return <PollResponse>[];
      }
      // Re-throw if it's already an Exception
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<List<PollStatsResponse>> getPollStatsByEvent(int eventId) async {
    try {
      final result = await _pollApiClient.getPollStatsByEvent(eventId);
      return result;
    } on DioException catch (e) {
      // If response is 200 but data is null or empty, return empty list
      if (e.response?.statusCode == 200) {
        final responseData = e.response?.data;
        if (responseData == null ||
            responseData is List && responseData.isEmpty) {
          return <PollStatsResponse>[];
        }
      }
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể lấy thống kê polls.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      // If it's a type error (null parsing), return empty list
      final errorString = e.toString();
      if (errorString.contains('null') &&
          (errorString.contains('String') ||
              errorString.contains('subtype') ||
              errorString.contains('Null'))) {
        return <PollStatsResponse>[];
      }
      // Re-throw if it's already an Exception
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<PollResponse> closePoll(int pollId) async {
    try {
      return await _pollApiClient.closePoll(pollId);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể đóng poll.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<PollResponse> updatePoll(
    int pollId,
    UpdatePollDto updatePollDto,
  ) async {
    try {
      return await _pollApiClient.updatePoll(pollId, updatePollDto);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể cập nhật poll.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<PollResponse> votePoll(int pollId, VotePollDto votePollDto) async {
    try {
      // Vote API returns MessageResponse, not PollResponse
      await _pollApiClient.votePoll(pollId, votePollDto);
      // After successful vote, fetch the poll again to get updated data
      return await _pollApiClient.getPoll(pollId);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể bỏ phiếu.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      // Re-throw if it's already an Exception
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<MyVotedOptionsResponse> getMyVotedOptions(int pollId) async {
    try {
      return await _pollApiClient.getMyVotedOptions(pollId);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(
          errorMessage ?? 'Không thể lấy danh sách option đã vote.',
        );
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }

  @override
  Future<List<int>> exportPollStats(int pollId, ExportFormat format) async {
    try {
      return await _pollApiClient.exportPollStats(pollId, format.value);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        final errorMessage = e.response!.data['message'] as String?;
        throw Exception(errorMessage ?? 'Không thể xuất báo cáo poll.');
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng thử lại.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }
}
