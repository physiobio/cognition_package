part of cognition_package_model;

/// Visual Array Change Test Result
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class RPVisualArrayChangeResult extends RPActivityResult {
  RPVisualArrayChangeResult({required String identifier})
      : super(identifier: identifier);

  /// make result for Visual Array Change Test
  /// right: the number of correct answers
  /// wrong: the number of wrong answers
  /// times: time taken to find the change
  /// memorytime: time taken to memorize the shapes
  /// score: score of the test calculated in model class
  RPActivityResult makeResult(int wrong, int right, List<dynamic> times,
      List<dynamic> memoryTimes, int score) {
    var res = RPActivityResult(identifier: identifier);
    res.results.addAll({'Wrong guesses': wrong});
    res.results.addAll({'Right guesses': right});
    res.results.addAll({'Time taken to memorize': memoryTimes});
    res.results.addAll({'Time taken to guess': times});
    res.results.addAll({'score': score});
    return res;
  }

  factory RPVisualArrayChangeResult.fromJson(Map<String, dynamic> json) =>
      _$RPVisualArrayChangeResultFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RPVisualArrayChangeResultToJson(this);
}
