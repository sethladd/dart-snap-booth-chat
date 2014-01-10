import 'dart:html';
import 'dart:async';

class Camera {
  
  static final int COUNTDOWN_TIME = 3000;
  
  MediaStream _cameraStream;
  CanvasElement _cameraView;
  CanvasRenderingContext2D _cameraViewContext;
  VideoElement _video;
  
  int _width;
  int _height;
  bool _isTakingPhoto;
  double _photoStartTime;
  Completer _photoCompleter;
  double _flashValue;
  
  Camera(CanvasElement cameraView) {
    
    _isTakingPhoto = false;
    _flashValue = 0.0;
   
    _video = new VideoElement();
    _video.autoplay = true;
    
    _cameraView = cameraView;
    
    _width = _cameraView.width;
    _height = _cameraView.height;
    
    _cameraViewContext = _cameraView.getContext('2d');
    _cameraViewContext.fillRect(0, 0, _width, _height);
  }
  
  void start() {
    
    if (_cameraStream != null)
      return;
    
    window.navigator.getUserMedia(video: true)
      .then(_onUserMediaStarted)
      .catchError(_onUserMediaError);
  }
  
  Future<String> takePhoto() {
    
    _isTakingPhoto = true;
    _photoStartTime = window.performance.now();
    _photoCompleter = new Completer();
    _flashValue = 0.0;
   
    return _photoCompleter.future;
  }
  
  void _updateCameraView(double time) {
    _cameraViewContext.drawImage(_video, 0, 0);
    
    if (_isTakingPhoto) {
      
      double timeSincePhotoRequest = (time - _photoStartTime);
      
      if (timeSincePhotoRequest > Camera.COUNTDOWN_TIME) {
        
        _isTakingPhoto = false;
        _flashValue = 1.0;
        _photoCompleter.complete(_cameraView.toDataUrl());
        
      } else {
        
        String timeSincePhotoRequestAsString = ((Camera.COUNTDOWN_TIME - timeSincePhotoRequest) * 0.001).ceil().toString();
        _cameraViewContext.font = 'bold 180px Arial';
        _cameraViewContext.textAlign = 'center';
        _cameraViewContext.textBaseline = 'middle';
        _cameraViewContext.fillStyle = '#FFF';
        _cameraViewContext.shadowOffsetY = 3;
        _cameraViewContext.shadowBlur = 3;
        _cameraViewContext.shadowColor = 'rgba(0,0,0,0.4)';
        _cameraViewContext.fillText(timeSincePhotoRequestAsString, _width / 2, _height / 2);
      }
    }
    
    _cameraViewContext.fillStyle = 'rgba(255, 255, 255, $_flashValue)';
    _cameraViewContext.fillRect(0, 0, _width, _height);
    
    _flashValue += (0.0 - _flashValue) * 0.03;
    window.animationFrame.then(_updateCameraView);
  }
  
  void _onUserMediaStarted(MediaStream cameraStream) {
    _cameraStream = cameraStream;
    _video.src = Url.createObjectUrlFromStream(cameraStream);
    window.animationFrame.then(_updateCameraView);
  }
  
  void _onUserMediaError(e) {
    print("Lolz. Error: $e");
  }
  
  bool get canTakePhoto => !_isTakingPhoto;
}