import 'dart:html';
import 'camera.dart';

Camera camera;
DivElement photoContainer;
int photoCount = 0;

final int CONTAINER_PADDING = 5;
final int SNAPSHOT_WIDTH = 140;
final int SNAPSHOT_PADDING = 14;
final int SNAPSHOT_TOTAL_WIDTH = SNAPSHOT_WIDTH + SNAPSHOT_PADDING;

void main() {

  CanvasElement cameraView = querySelector('.video-container canvas') as CanvasElement
      ..width = 640
      ..height = 480;
  ButtonElement takePhotoButton = querySelector('#take-photo');
  photoContainer = querySelector('.taken-photos-inner');

  camera = new Camera(cameraView)
    ..start();

  takePhotoButton.onClick.listen(takePhoto);
}

void takePhoto(_) {
  if (camera.canTakePhoto) {
    camera.takePhoto().then(onPhotoTaken);
  }
}

void onPhotoTaken(String photoData) {
  ImageElement snapshot = new ImageElement()
    ..src = photoData
    ..width = SNAPSHOT_WIDTH;

  photoCount++;

  int newWidth = (CONTAINER_PADDING + photoCount * SNAPSHOT_TOTAL_WIDTH);

  photoContainer
    ..style.width = '${newWidth}px'
    ..children.add(snapshot)
    ..parent.scrollLeft = newWidth;
}