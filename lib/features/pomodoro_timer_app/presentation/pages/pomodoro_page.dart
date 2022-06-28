import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_pomodoro_timer/core/themes/my_globals.dart';

import '../bloc/pomodoro_bloc.dart';

class PomodoroTimerPage extends StatefulWidget {
  void Function() onNextPressed;

  PomodoroTimerPage({Key? key, required this.onNextPressed}) : super(key: key);

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  bool pomodoroStartPressed = true;
  bool isStartedPomodoro = false;
  String parseDuration(Duration duration) {
    var seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    var minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  _showMyDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to take a short break?',
                    style: TextStyle(color: pomodoroColor)),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    widget.onNextPressed();

                    Navigator.of(context).pop();
                    BlocProvider.of<PomodoroBloc>(context).add(
                        const PomodoroEvent.resetPressed(
                            resetValue: Duration(minutes: 5)));
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocConsumer<PomodoroBloc, PomodoroState>(
            listener: (context, state) {
              state.map(
                initial: (s) {},
                loading: (s) {},
                loaded: (s) {},
                started: (s) {},
                stop: (s) {},
                decrement: (s) {},
                resetPressed: (s) {},
                setTimerType: (s) {},
              );
            },
            builder: (context, state) {
              // state.maybeMap(setTimerType: (value) {
              //   print(value.setValue);
              // }, orElse: () {
              //   print('other state');
              // });

              return Text(
                state.map(
                  initial: (value) => '25:00',
                  loading: (s) => 'Loading',
                  loaded: (loaded) => loaded.initialValue.toString(),
                  started: (started) => 'Started',
                  stop: (s) => parseDuration(s.timer),
                  decrement: (value) => parseDuration(value.currentDuration),
                  resetPressed: (value) => parseDuration(value.resetValue),
                  setTimerType: (value) => parseDuration(value.setValue),
                ),
                // '$minutes:$seconds',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          isStartedPomodoro
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: SizedBox()),
                    Container(
                      // alignment: Alignment.center,
                      // padding: const EdgeInsets.only(left: 50),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      height: 55,
                      width: 200,
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              isStartedPomodoro = false;
                            });
                            BlocProvider.of<PomodoroBloc>(context)
                                .add(const PomodoroEvent.stop());
                          },
                          child: Text(
                            'STOP',
                            style:
                                TextStyle(fontSize: 22, color: pomodoroColor),
                          )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                            color: pomodoroColor,
                            onPressed: _showMyDialog,
                            icon: const Icon(
                              Icons.skip_next,
                              color: Colors.white,
                              size: 35,
                            )),
                      ),
                    ),
                  ],
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  height: 55,
                  width: 200,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        isStartedPomodoro = true;
                      });
                      if (pomodoroStartPressed) {
                        BlocProvider.of<PomodoroBloc>(context).add(
                            const PomodoroEvent.setTimerType(
                                setValue: Duration(minutes: 25)));
                        setState(() {
                          pomodoroStartPressed = false;
                        });
                      }

                      BlocProvider.of<PomodoroBloc>(context).add(
                          const PomodoroEvent.decrement(
                              decrementValue: Duration(seconds: 1)));
                      // isStartedShortBreak = true;
                    },
                    child: Text(
                      'START',
                      style: TextStyle(fontSize: 22, color: pomodoroColor),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}