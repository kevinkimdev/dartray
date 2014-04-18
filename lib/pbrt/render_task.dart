/****************************************************************************
 *  Copyright (C) 2014 by Brendan Duncan.                                   *
 *                                                                          *
 *  This file is part of DartRay.                                           *
 *                                                                          *
 *  Licensed under the Apache License, Version 2.0 (the "License");         *
 *  you may not use this file except in compliance with the License.        *
 *  You may obtain a copy of the License at                                 *
 *                                                                          *
 *  http://www.apache.org/licenses/LICENSE-2.0                              *
 *                                                                          *
 *  Unless required by applicable law or agreed to in writing, software     *
 *  distributed under the License is distributed on an "AS IS" BASIS,       *
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.*
 *  See the License for the specific language governing permissions and     *
 *  limitations under the License.                                          *
 *                                                                          *
 *   This project is based on PBRT v2 ; see http://www.pbrt.org             *
 *   pbrt2 source code Copyright(c) 1998-2010 Matt Pharr and Greg Humphreys.*
 ****************************************************************************/
part of pbrt;

/**
 * Manages a [RenderIsolate], which is controlled by the [RenderManager].
 */
class RenderTask {
  static const int CONNECTING = 1;
  static const int CONNECTED = 2;
  static const int STOPPED = 3;

  int status = CONNECTING;
  ReceivePort receivePort = new ReceivePort();
  SendPort sendPort;
  PreviewCallback previewCallback;
  int taskNum;
  int taskCount;
  Image threadImage;

  RenderTask(this.previewCallback, this.taskNum, this.taskCount);

  Future<OutputImage> render(String scene, String isolateUri) {
    Completer<OutputImage> completer = new Completer<OutputImage>();

    Isolate.spawnUri(Uri.parse(isolateUri), ['_'],
                     receivePort.sendPort).then((iso) {
    });

    receivePort.listen((msg) {
      if (status == CONNECTING) {
        _linkEstablish(msg, scene);
      } else if (status == CONNECTED) {
        if (msg is Map && msg.containsKey('cmd')) {
          var cmd = msg['cmd'];

          if (cmd == 'request') {
            int id = msg['id'];
            var subMsg = msg['msg'];
            if (subMsg is Map && subMsg.containsKey('cmd')) {
              var subCmd = subMsg['cmd'];
              if (subCmd == 'file') {
                String path = subMsg['path'];
                ResourceManager.RequestFile(path).then((bytes) {
                  var data = {'cmd': 'request',
                             'id': id,
                             'data': bytes};
                  sendPort.send(data);
                });
              }
            }
            return;
          } else if (cmd == 'preview' && msg.containsKey('image')) {
            var bytes = msg['image'];
            var extents = msg['extents'];
            var res = msg['res'];
            if (res == null) {
              return;
            }
            if (threadImage == null || threadImage.width != res[0] ||
                threadImage.height != res[1]) {
              threadImage = new Image(res[0], res[1]);
              threadImage.fill(getColor(128, 128, 128));
            }
            if (taskCount > 1) {
              _updatePreviewImage(extents, bytes);
            } else {
              threadImage.getBytes().setRange(0, bytes.length, bytes);
            }
            if (previewCallback != null) {
              previewCallback(threadImage);
            }
            return;
          } else if (cmd == 'error') {
            LogInfo('ERROR: ${msg['msg']}');
            completer.completeError(msg['msg']);
            return;
          } else if (cmd == 'final' && msg.containsKey('output')) {
            Float32List rgb = msg['output'];
            List<int> extents = msg['extents'];
            OutputImage output = new OutputImage(extents[0], extents[2],
                                                 extents[1], extents[3],
                                                 rgb);
            completer.complete(output);
            return;
          }
        }

        LogInfo(msg.toString());
      }
    });

    return completer.future;
  }

  void _updatePreviewImage(List<int> extents, List<int> bytes) {
    Uint32List src;
    if (bytes is Uint8List) {
      src = new Uint32List.view(bytes.buffer);
    } else if (bytes is List<int>) {
      Uint8List b = new Uint8List.fromList(bytes);
      src = new Uint32List.view(b.buffer);
    } else {
      assert(false);
      return;
    }
    Uint32List dst = threadImage.data;
    int w = extents[1] - extents[0];
    int dsti = extents[2] * threadImage.width + extents[0];
    for (int y = extents[2]; y < extents[3]; ++y, dsti += threadImage.width) {
      dst.setRange(dsti, dsti + w, src, dsti);
    }
  }

  void _linkEstablish(msg, [String scene]) {
    if (msg is SendPort) {
      sendPort = msg;
      sendPort.send('ping');
    } else if (msg == 'pong') {
      status = CONNECTED;
      _startIsolateRender(scene);
    }
  }

  void _startIsolateRender(String scene) {
    sendPort.send({'cmd': 'render',
                   'scene': scene,
                   'taskNum': taskNum,
                   'taskCount': taskCount,
                   'preview': previewCallback != null ? true : false});
  }
}
