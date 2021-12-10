part of cognition_package_model;

/// A Trail Making Test
@JsonSerializable()
class RPTrailMakingActivity extends RPActivityStep {
  /// Contructor for creating a Trail Making Test.
  RPTrailMakingActivity(String identifier,
      {includeInstructions = true,
      includeResults = true,
      this.trailType = TrailType.A})
      : super(identifier,
            includeInstructions: includeInstructions,
            includeResults: includeResults);

  /// The type of trail used in the test.
  /// [TrailType.A] uses numbers only.
  /// [TrailType.B] uses numbers AND letters alternating.
  TrailType trailType;

  @override
  Widget stepBody(dynamic Function(dynamic) onResultChange,
      RPActivityEventLogger eventLogger) {
    return RPUITrailMakingActivityBody(this, eventLogger, onResultChange);
  }
}

@override
calculateScore(dynamic result) {
  var sum = 5 - result['mistakeCount'];
  print('trailmaking score: ' + sum.toString());
  return sum;
}

/// The type of Trail used in a Trail Making Test.
enum TrailType { A, B }
