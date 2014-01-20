library component.camera;

import 'package:angular/angular.dart';
import 'dart:html';
import 'package:snapboothchat/camera.dart';

const int CONTAINER_PADDING = 5;
const int SNAPSHOT_WIDTH = 140;
const int SNAPSHOT_PADDING = 14;
const int SNAPSHOT_TOTAL_WIDTH = SNAPSHOT_WIDTH + SNAPSHOT_PADDING;

@NgComponent(
    selector: 'camera',
    templateUrl: 'components/camera.html',
    cssUrl: 'components/camera.css',
    publishAs: 'ctrl'
)
class CameraComponent implements NgShadowRootAware {

  Camera camera;
  DivElement photoContainer;
  int photoCount = 0;

  @override
  onShadowRoot(ShadowRoot shadowRoot) {
    CanvasElement cameraView = shadowRoot.querySelector('.video-container canvas') as CanvasElement
        ..width = 640
        ..height = 480;
    ButtonElement takePhotoButton = shadowRoot.querySelector('#take-photo');
    photoContainer = shadowRoot.querySelector('.taken-photos-inner');

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

}
