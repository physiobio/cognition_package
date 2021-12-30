part of cognition_package_ui;

/// The [RPUIFlankerActivityBody] class defines the UI for the
/// instructions and test phase of the continuous visual tracking task.
class RPUIFlankerActivityBody extends StatefulWidget {
  /// The [RPUIFlankerActivityBody] activity.
  final RPFlankerActivity activity;

  /// The results function for the [RPUIFlankerActivityBody].
  final Function(dynamic) onResultChange;

  /// the [RPActivityEventLogger] for the [RPUIFlankerActivityBody].
  final RPActivityEventLogger eventLogger;

  /// The [RPUIFlankerActivityBody] constructor.
  RPUIFlankerActivityBody(this.activity, this.eventLogger, this.onResultChange);

  @override
  _RPUI_FlankerActivityBodyState createState() =>
      _RPUI_FlankerActivityBodyState();
}

// ignore: camel_case_types
class _RPUI_FlankerActivityBodyState extends State<RPUIFlankerActivityBody> {
  late ActivityStatus activityStatus;

  @override
  initState() {
    super.initState();
    if (widget.activity.includeInstructions) {
      activityStatus = ActivityStatus.Instruction;
      widget.eventLogger.instructionStarted();
    } else {
      activityStatus = ActivityStatus.Test;
      widget.eventLogger.testStarted();
      startTest();
    }
  }

  late Timer testTimer;
  int seconds = 0;
  void startTimer() {
    const oneSec = Duration(seconds: 1);
    testTimer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (seconds < 0) {
            timer.cancel();
          } else {
            seconds = seconds + 1;
          }
        },
      ),
    );
  }

  late Timer flankerTimer;
  int flankerSeconds = 0;
  void startFlankerTimer() {
    const oneSec = Duration(milliseconds: 1);
    flankerTimer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (flankerSeconds < 0) {
            timer.cancel();
          } else {
            flankerSeconds = flankerSeconds + 1;
          }
        },
      ),
    );
  }

  void startTest() async {
    startTimer();
    await Future.delayed(Duration(seconds: 1));
    Timer(Duration(seconds: widget.activity.lengthOfTest), () {
      if (mounted) {
        widget.eventLogger.testEnded();
        print("flanker scoring begins 2");
        var flankerScore = widget.activity.calculateScore({
          'mistakes': wrongSwipe,
          'correct': rightSwipe,
          'congruentTimes': congruentTimes,
          'incongruentTimes': incongruentTimes
        });
        print("done the score");
        RPFlankerResult flankerResult =
            RPFlankerResult(identifier: 'FlankerTaskResult');
        var taskResults = flankerResult.makeResult(
            wrongSwipe, rightSwipe, seconds, flankerScore);
        testTimer.cancel();
        seconds = 0;
        widget.onResultChange(taskResults.results);
        if (widget.activity.includeResults) {
          widget.eventLogger.resultsShown();
          setState(() {
            activityStatus = ActivityStatus.Result;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (flankerScore == widget.activity.numberOfCards) {
      flankerScore = 0;
      if (mounted) {
        widget.eventLogger.testEnded();
        print("flanker scoring begins 3");
        var flankerScore = widget.activity.calculateScore({
          'mistakes': wrongSwipe,
          'correct': rightSwipe,
          'congruentTimes': congruentTimes,
          'incongruentTimes': incongruentTimes
        });
        print("done the score");
        RPFlankerResult flankerResult =
            RPFlankerResult(identifier: 'FlankerTaskResult');
        var taskResults = flankerResult.makeResult(
            wrongSwipe, rightSwipe, seconds, flankerScore);
        testTimer.cancel();
        widget.onResultChange(taskResults.results);
        if (widget.activity.includeResults) {
          widget.eventLogger.resultsShown();
          setState(() {
            activityStatus = ActivityStatus.Result;
          });
        }
      }
    }

    switch (activityStatus) {
      case ActivityStatus.Instruction:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Each card has 5 arrows on it.',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 10,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Swipe the cards in the direction of the middle arrow on each card.',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 10,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Ignore all other arrows on the cards, they are only there to distract you',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 10,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Container(
                height: MediaQuery.of(context).size.height / 2.5,
                width: MediaQuery.of(context).size.width / 1.1,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage(
                            'packages/cognition_package/assets/images/flanker.png'))),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              // ignore: deprecated_member_use
              child: OutlineButton(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onPressed: () {
                  widget.eventLogger.instructionEnded();
                  widget.eventLogger.testStarted();
                  setState(() {
                    activityStatus = ActivityStatus.Test;
                  });
                  startTest();
                },
                child: Text(
                  'Ready',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        );
      case ActivityStatus.Test:
        return Scaffold(
          body: Center(
              child: _Flanker(
                  numberOfCards: widget.activity.numberOfCards,
                  parentClass: this)),
        );
      case ActivityStatus.Result:
        return Center(
          child: Text(
            'results:  $flankerScore',
            style: TextStyle(fontSize: 22),
            textAlign: TextAlign.center,
          ),
        );
      default:
        return Container();
    }
  }
}

/// score counter for the flanker task used in [RPUIFlankerActivityBody]
int flankerScore = 0;

/// counter for the wrong swipes in the flanker task used in [RPUIFlankerActivityBody]
int wrongSwipe = 0;

/// counter for the right swipes in the flanker task used in [RPUIFlankerActivityBody]
int rightSwipe = 0;

List<int> congruentTimes = [];
List<int> incongruentTimes = [];

class _Flanker extends StatefulWidget {
  final int numberOfCards;
  final _RPUI_FlankerActivityBodyState parentClass;
  const _Flanker({required this.numberOfCards, required this.parentClass});
  @override
  _FlankerState createState() => _FlankerState(numberOfCards, parentClass);
}

class _FlankerState extends State<_Flanker> {
  final int numberOfCards;
  final _RPUI_FlankerActivityBodyState parentClass;
  bool even = false;

  List<Widget> flankerCards = [];
  List<_FlankerCard> cards(amount) {
    List<_FlankerCard> cards = [];
    for (var i = 0; i < amount; i++) {
      even = !even;
      if (Random().nextBool()) {
        cards.add(
          _FlankerCard('→', even ? 0xff003F6E : 0xffC32C39, parentClass),
        );
      } else {
        cards.add(
            _FlankerCard('←', even ? 0xff003F6E : 0xffC32C39, parentClass));
      }
    }
    parentClass.startFlankerTimer();
    return cards;
  }

  _FlankerState(this.numberOfCards, this.parentClass);

  @override
  initState() {
    super.initState();
    flankerCards = cards(numberOfCards);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.7,
      child: Stack(
        children: flankerCards,
      ),
    );
  }
}

class _FlankerCard extends StatelessWidget {
  final int color;
  final String direction;
  final _RPUI_FlankerActivityBodyState parentClass;
  _FlankerCard(this.direction, this.color, this.parentClass);

  final String right = '→';
  final String left = '←';
  final bool congruent = Random().nextBool();

  String stimuli() {
    String ret = '';
    for (var i = 0; i < 5; i++) {
      if (i == 2) {
        ret += direction;
      } else if (congruent) {
        ret += direction;
      } else {
        if (direction == '→') {
          ret += '←';
        } else {
          ret += '→';
        }
      }
    }
    return ret;
  }

  void onSwipeRight(offset) {
    if (direction == '→') {
      rightSwipe = rightSwipe + 1;
      if (congruent) {
        congruentTimes.add(parentClass.flankerSeconds);
      } else {
        incongruentTimes.add(parentClass.flankerSeconds);
      }
    } else {
      wrongSwipe = wrongSwipe + 1;
    }
    flankerScore = flankerScore + 1;
    parentClass.flankerSeconds = 0;
  }

  void onSwipeLeft(offset) {
    if (direction == '←') {
      rightSwipe = rightSwipe + 1;
      if (congruent) {
        congruentTimes.add(parentClass.flankerSeconds);
      } else {
        incongruentTimes.add(parentClass.flankerSeconds);
      }
    } else {
      wrongSwipe = wrongSwipe + 1;
    }
    flankerScore = flankerScore + 1;
    parentClass.flankerSeconds = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Swipable(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Color(color),
        ),
        child: Center(
            child: Text(
          stimuli(),
          style: TextStyle(fontSize: 55, color: Colors.white),
        )),
      ),
      onSwipeRight: onSwipeRight,
      onSwipeLeft: onSwipeLeft,
    );
  }
}