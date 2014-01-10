import 'dart:html';
import 'Camera.dart';

Camera camera;
DivElement photoContainer;
int photoCount;

final int CONTAINER_PADDING = 5;
final int SNAPSHOT_WIDTH = 140;
final int SNAPSHOT_PADDING = 14;
final int SNAPSHOT_TOTAL_WIDTH = SNAPSHOT_WIDTH + SNAPSHOT_PADDING;

void main() {
 
  CanvasElement cameraView = querySelector('.video-container canvas');
  ButtonElement takePhotoButton = document.getElementById('take-photo');
  photoContainer = querySelector('.taken-photos-inner');
  
  cameraView.width = 640;
  cameraView.height = 480;
  
  photoCount = 0;
  
  camera = new Camera(cameraView);
  camera.start();
  
  takePhotoButton.onClick.listen(takePhoto);
}

void takePhoto(_) {
  if (camera.canTakePhoto)
    camera.takePhoto().then(onPhotoTaken);
}

void onPhotoTaken(String photoData) {
  ImageElement snapshot = new ImageElement();
  snapshot.src = photoData;
  snapshot.width = SNAPSHOT_WIDTH;
  
  photoCount++;
  
  int newWidth = (CONTAINER_PADDING + photoCount * SNAPSHOT_TOTAL_WIDTH);

  photoContainer.style.width = newWidth.toString() + 'px';
  photoContainer.children.add(snapshot);
  photoContainer.parent.scrollLeft = newWidth;
}