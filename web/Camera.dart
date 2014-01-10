import 'dart:html';
import 'dart:async';

class Camera {

  static final int COUNTDOWN_TIME = 3000;

  MediaStream cameraStream;
  CanvasElement cameraView;
  CanvasRenderingContext2D cameraViewContext;
  VideoElement video;

  int width;
  int height;
  bool isTakingPhoto = false;
  double photoStartTime;
  Completer photoCompleter;
  double flashValue = 0.0;

  Camera(this.cameraView) {

    video = new VideoElement()
      ..autoplay = true;

    width = cameraView.width;
    height = cameraView.height;

    cameraViewContext = cameraView.getContext('2d') as CanvasRenderingContext2D
        ..fillRect(0, 0, width, height);
  }

  Future start() {

    if (cameraStream != null) {
      throw new StateError('camera already started');
    }

    return window.navigator.getUserMedia(video: true)
      .then(_onUserMediaStarted);
  }

  Future<String> takePhoto() {

    isTakingPhoto = true;
    photoStartTime = window.performance.now();
    photoCompleter = new Completer();
    flashValue = 0.0;

    return photoCompleter.future;
  }

  void _updateCameraView(double time) {
    cameraViewContext.drawImage(video, 0, 0);

    if (isTakingPhoto) {

      double timeSincePhotoRequest = (time - photoStartTime);

      if (timeSincePhotoRequest > Camera.COUNTDOWN_TIME) {

        isTakingPhoto = false;
        flashValue = 1.0;
        photoCompleter.complete(cameraView.toDataUrl());

      } else {

        String timeSincePhotoRequestAsString = _timeSincePhotoRequest(timeSincePhotoRequest);

        cameraViewContext
          ..font = 'bold 180px Arial'
          ..textAlign = 'center'
          ..textBaseline = 'middle'
          ..fillStyle = '#FFF'
          ..shadowOffsetY = 3
          ..shadowBlur = 3
          ..shadowColor = 'rgba(0,0,0,0.4)'
          ..fillText(timeSincePhotoRequestAsString, width / 2, height / 2);
      }
    }

    cameraViewContext
      ..fillStyle = 'rgba(255, 255, 255, $flashValue)'
      ..fillRect(0, 0, width, height);

    flashValue += (0.0 - flashValue) * 0.03;
    window.animationFrame.then(_updateCameraView);
  }

  void _onUserMediaStarted(MediaStream cameraStream) {
    cameraStream = cameraStream;
    video.src = Url.createObjectUrlFromStream(cameraStream);
    window.animationFrame.then(_updateCameraView);
  }

  String _timeSincePhotoRequest(timeSincePhotoRequest) {
    return ((Camera.COUNTDOWN_TIME - timeSincePhotoRequest) * 0.001).ceil().toString();
  }

  bool get canTakePhoto => !isTakingPhoto;
}