import 'dart:io';
import 'dart:math';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';

class PlayerPage2 extends StatefulWidget {
  PlayerPage2({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _PlayerPage2State createState() => _PlayerPage2State();
}

class _PlayerPage2State extends State<PlayerPage2> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  bool _isPlaying = false;
  AudioPlayer audioPlayer;
  Offset _offset = Offset(0, 0); //Panドラッグ時のポジション
  double _radians = 0.0; //Scaleの回転値
  double _scale = 1.0; //Scaleのスケール値
  bool _visible = false;
  var filedata = null;
  String filedataPath = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    initPlayer();
  }

  void initPlayer() {
    audioPlayer = AudioPlayer();
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer.seek(newDuration);
  }

  pauseAudio() async {
    await audioPlayer.pause();
  }

  stopAudio() async {
    await audioPlayer.stop();
  }

  // resumeのメソッドはないのでplay()と同じ
  resumeAudio() async {
    await audioPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [],
                ),
                Text(
                  filedata != null ? 'name : ' + filedata.name : '',
                  softWrap: true,
                ),
                Text(
                  filedata != null
                      ? 'bytes : ' + filedata.bytes.toString()
                      : '',
                ),
                Text(
                  filedata != null ? 'size : ' + filedata.size.toString() : '',
                ),
                Text(
                  filedata != null
                      ? 'extension : ' + filedata.extension.toString()
                      : '',
                ),
                Text(
                  filedataPath != '' ? 'path : ' + filedataPath : '',
                  softWrap: true,
                ),
              ],
            ),
            Positioned(
              left: 20.0,
              bottom: 70.0,
              child: FlatButton(
                color: Colors.grey[200],
                onPressed: () async {
                  FilePickerResult result =
                      await FilePicker.platform.pickFiles(type: FileType.audio);
                  setState(() {
                    _isPlaying = true;
                    if (result != null) {
                      filedata = result.files.single;
                    }
                  });
                  if (result != null) {
                    File file = File(result.files.single.path);
                    Directory directory =
                        await getApplicationDocumentsDirectory();
                    setState(() {
                      filedataPath =
                          '${directory.path}/${result.files.single.name}';
                    });
                    await file.copy(filedataPath);
                    // filepathを渡してから再生する必要がある
                    await audioPlayer.setFilePath(filedataPath);
                    await audioPlayer.play();
                  }
                },
                child: Text('Load Audio File'),
              ),
            ),
            Positioned(
              left: 180.0,
              bottom: 20.0,
              child: SizedBox(
                width: 50,
                height: 30,
                child: FlatButton(
                  onPressed: () {
                    stopAudio();
                    setState(() {
                      _isPlaying = false;
                    });
                  },
                  color: Colors.grey[200],
                  child: Icon(Icons.stop),
                ),
              ),
            ),
            Positioned(
              left: 20.0,
              bottom: 20.0,
              child: StreamBuilder<Duration>(
                stream: audioPlayer.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: audioPlayer.positionStream,
                    builder: (context, snapshot) {
                      var position = snapshot.data ?? Duration.zero;
                      if (position > duration) {
                        position = duration;
                      }
                      return SeekBar(
                        duration: duration,
                        position: position,
                        onChangeEnd: (newPosition) {
                          audioPlayer.seek(newPosition);
                        },
                      );
                    },
                  );
                },
              ),
            ),
//            Positioned(
//              right: -50, // 移動の値（x）
//              bottom: -50, // 移動の値（y）
//              child: GestureDetector(
//                // ドラッグの移動を更新
//                onPanUpdate: (DragUpdateDetails details) {
//                  setState(() {
//                    _offset = Offset(_offset.dx + details.delta.dx,
//                        _offset.dy + details.delta.dy);
//                    seekToSecond(
//                      (_offset.dx - _offset.dy).toInt(),
//                    );
//                  });
//                },
//                child: Visibility(
//                  visible: _visible,
//                  child: Container(
//                    width: 200,
//                    height: 200,
//                    decoration: BoxDecoration(
//                      color: Colors.grey[900].withAlpha(30),
//                      shape: BoxShape.circle,
//                    ),
//                    child: Center(
//                      child: Text(
//                        'X:${_offset.dx.toInt()}\nY:${_offset.dy.toInt()}',
//                        style: TextStyle(
//                          color: Colors.white,
//                        ),
//                      ),
//                    ),
//                  ),
//                ),
//              ),
//            ),
//            // |◀
//            Positioned(
//              right: 94,
//              bottom: 22.5,
//              child: Visibility(
//                visible: _visible,
//                child: SizedBox(
//                  width: 50,
//                  height: 50,
//                  child: FlatButton(
//                    onPressed: () {
//                      //
//                    },
//                    shape: CircleBorder(),
//                    child: Icon(Icons.skip_previous, color: Colors.grey[500]),
//                  ),
//                ),
//              ),
//            ),
//            // ▶
//            Positioned(
//              right: 73.5,
//              bottom: 70.5,
//              child: Visibility(
//                visible: _visible,
//                child: SizedBox(
//                  width: 50,
//                  height: 50,
//                  child: FlatButton(
//                    onPressed: () {
//                      if (_isPlaying == true) {
//                        pauseAudio();
//                        setState(() {
//                          _isPlaying = false;
//                        });
//                      } else {
//                        resumeAudio();
//                        setState(() {
//                          _isPlaying = true;
//                        });
//                      }
//                    },
//                    shape: CircleBorder(),
//                    child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
//                        color: Colors.grey[500]),
//                  ),
//                ),
//              ),
//            ),
//            // ▶|
//            Positioned(
//              right: 26,
//              bottom: 90.5,
//              child: Visibility(
//                visible: _visible,
//                child: SizedBox(
//                  width: 50,
//                  height: 50,
//                  child: FlatButton(
//                    onPressed: () {
//                      //
//                    },
//                    shape: CircleBorder(),
//                    child: Icon(Icons.skip_next, color: Colors.grey[500]),
//                  ),
//                ),
//              ),
//            ),
            // Scale用のウィジェット
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FabCircularMenu(
          key: fabKey,
          // Cannot be `Alignment.center`
          alignment: Alignment.bottomRight,
          ringColor: Colors.grey.withAlpha(60),
          ringDiameter: 205.0,
          ringWidth: 70.0,
          fabSize: 64.0,
          fabElevation: 8.0,
          fabIconBorder: CircleBorder(),
          // Also can use specific color based on wether
          // the menu is open or not:
          // fabOpenColor: Colors.white
          // fabCloseColor: Colors.white
          // These properties take precedence over fabColor
          fabColor: Colors.white,
          fabOpenIcon: Icon(Icons.menu, color: Colors.grey[600]),
          fabCloseIcon: Icon(Icons.close, color: Colors.grey[600]),
          fabMargin: const EdgeInsets.all(16.0),
          animationDuration: const Duration(milliseconds: 100),
          animationCurve: Curves.easeInOutCirc,
          onDisplayChange: (isOpen) {
//              _showSnackBar(
//                  context, "The menu is ${isOpen ? "open" : "closed"}");
            print('${isOpen ? "open" : "closed"}');
            setState(() {
              _visible = isOpen ? false : true;
            });
          },
          children: <Widget>[
            RawMaterialButton(
              onPressed: () async {
//              _showSnackBar(context, "You pressed 1");
                await audioPlayer.seek(Duration(milliseconds: 1200));
              },
              shape: CircleBorder(),
              padding: const EdgeInsets.all(24.0),
              child: Icon(Icons.skip_previous, color: Colors.grey[500]),
            ),
            RawMaterialButton(
              onPressed: () {
                if (_isPlaying == true) {
                  pauseAudio();
                  setState(() {
                    _isPlaying = false;
                  });
                } else {
                  resumeAudio();
                  setState(() {
                    _isPlaying = true;
                  });
                }
              },
              shape: CircleBorder(),
              padding: const EdgeInsets.all(24.0),
              child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.grey[500]),
            ),
            RawMaterialButton(
              onPressed: () async {
                //await audioPlayer.seek(Duration(milliseconds: -1200));
              },
              shape: CircleBorder(),
              padding: const EdgeInsets.all(24.0),
              child: Icon(Icons.skip_next, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    @required this.duration,
    @required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.red[700],
            inactiveTrackColor: Colors.red[100],
            trackShape: RectangularSliderTrackShape(),
            trackHeight: 6.0,
            thumbColor: Colors.transparent,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0),
            overlayColor: Colors.red.withAlpha(32),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 4.0),
          ),
          child: Container(
            color: Colors.grey[200],
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: SizedBox(
                height: 10,
                width: 150,
                child: Slider(
                  min: 0.0,
                  max: widget.duration.inMilliseconds.toDouble(),
                  value: min(
                      _dragValue ?? widget.position.inMilliseconds.toDouble(),
                      widget.duration.inMilliseconds.toDouble()),
                  onChanged: (value) {
                    setState(() {
                      _dragValue = value;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged(Duration(milliseconds: value.round()));
                    }
                  },
                  onChangeEnd: (value) {
                    if (widget.onChangeEnd != null) {
                      widget.onChangeEnd(Duration(milliseconds: value.round()));
                    }
                    _dragValue = null;
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                      .firstMatch("$_remaining")
                      ?.group(1) ??
                  '$_remaining',
              style: Theme.of(context).textTheme.caption),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}
