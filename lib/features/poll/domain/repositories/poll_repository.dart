import 'package:event_management/features/poll/data/models/create_poll_dto.dart';
import 'package:event_management/features/poll/data/models/my_voted_options_response.dart';
import 'package:event_management/features/poll/data/models/poll_response.dart';
import 'package:event_management/features/poll/data/models/poll_stats_response.dart';
import 'package:event_management/features/poll/data/models/update_poll_dto.dart';
import 'package:event_management/features/poll/data/models/vote_poll_dto.dart';

abstract class PollRepository {
  /// Tạo poll mới
  Future<PollResponse> createPoll(CreatePollDto pollDto);

  /// Lấy thông tin một poll theo ID
  Future<PollResponse> getPoll(int pollId);

  /// Lấy danh sách polls theo event ID
  Future<List<PollResponse>> getPollsByEvent(int eventId);

  /// Lấy thống kê polls theo event ID
  Future<List<PollStatsResponse>> getPollStatsByEvent(int eventId);

  /// Đóng poll
  Future<PollResponse> closePoll(int pollId);

  /// Cập nhật poll
  Future<PollResponse> updatePoll(int pollId, UpdatePollDto updatePollDto);

  /// Bỏ phiếu cho poll
  Future<PollResponse> votePoll(int pollId, VotePollDto votePollDto);

  /// Lấy danh sách option IDs mà user đã vote
  Future<MyVotedOptionsResponse> getMyVotedOptions(int pollId);
}
