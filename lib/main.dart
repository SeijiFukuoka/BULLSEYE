import 'dart:math';

import 'package:BullsEye/styledbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:BullsEye/prompt.dart';
import 'package:BullsEye/control.dart';
import 'package:BullsEye/score.dart';
import 'package:BullsEye/gamemodel.dart';
import 'package:BullsEye/textstyles.dart';
import 'package:BullsEye/hitmebutton.dart';

void main() => runApp(BullsEyeApp());

class BullsEyeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      title: 'BullsEye',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GamePage(title: 'BullsEye'),
    );
  }
}

class GamePage extends StatefulWidget {
  GamePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool _alertIsVisible = false;
  GameModel _model;

  @override
  void initState() {
    super.initState();
    _model = GameModel(_newTargetValue());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
              image: AssetImage("images/background.png"), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 48.0, bottom: 32.0),
                child: Prompt(targetValue: _model.target),
              ),
              Control(
                model: _model,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: HitMeButton(
                  text: 'Hit Me!',
                  onPressed: () {
                    _showAlert(context);
                    this._alertIsVisible = true;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Score(
                  totalScore: _model.totalScore,
                  round: _model.round,
                  onStartOver: _startNewGame,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _sliderValue() => _model.current;

  int _pointsForCurrentRound() {
    var maximumScore = 100;
    var difference = _amountOff();
    var bonus = 0;
    if (difference == 0) {
      bonus = 100;
    } else if (difference == 1) {
      bonus = 50;
    }
    return maximumScore - difference + bonus;
  }

  int _newTargetValue() => Random().nextInt(100) + 1;

  void _startNewGame() {
    setState(() {
      _model.totalScore = GameModel.SCORE_START;
      _model.round = GameModel.ROUND_START;
      _model.target = _newTargetValue();
      _model.current = GameModel.SLIDE_START;
    });
  }

  void _showAlert(BuildContext context) {
    Widget okButton = StyledButton(
        icon: Icons.close,
        onPressed: () {
          Navigator.of(context).pop();
          this._alertIsVisible = false;
          setState(() {
            _model.totalScore += _pointsForCurrentRound();
            _model.target = _newTargetValue();
            _model.round += 1;
          });
        });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            _alertTitle(),
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "THE SLIDER'S VALUE IS",
                textAlign: TextAlign.center,
              ),
              Text(
                "${_sliderValue()}",
                style: TargetTextStyle.bodyText1(context),
                textAlign: TextAlign.center,
              ),
              Text(
                "\nYou scored ${_pointsForCurrentRound()} points this round.",
                textAlign: TextAlign.center,
              )
            ],
          ),
          actions: <Widget>[
            okButton,
          ],
          elevation: 5,
        );
      },
    );
  }

  int _amountOff() => (_model.target - _sliderValue()).abs();

  String _alertTitle() {
    var difference = _amountOff();

    String title;

    if (difference == 0) {
      title = "Perfect!";
    } else if (difference < 5) {
      title = "You almost had it!";
    } else if (difference <= 10) {
      title = "Not bad.";
    } else {
      title = "Are you even trying?";
    }
    return title;
  }
}
