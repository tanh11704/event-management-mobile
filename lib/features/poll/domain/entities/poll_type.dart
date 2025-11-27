/// Loại poll: Chọn một hoặc chọn nhiều
enum PollType {
  singleChoice('SINGLE_CHOICE', 'Chọn một'),
  multipleChoice('MULTIPLE_CHOICE', 'Chọn nhiều');

  const PollType(this.value, this.label);

  final String value;
  final String label;
}
