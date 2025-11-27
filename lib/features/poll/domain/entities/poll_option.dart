import 'package:equatable/equatable.dart';

/// Entity đại diện cho một lựa chọn trong poll
class PollOption extends Equatable {
  const PollOption({required this.text, this.id, this.voteCount = 0});

  final String? id;
  final String text;
  final int voteCount;

  PollOption copyWith({String? id, String? text, int? voteCount}) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      voteCount: voteCount ?? this.voteCount,
    );
  }

  @override
  List<Object?> get props => [id, text, voteCount];
}
