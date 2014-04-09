part of image_samplers;

class TileImageSampler extends ImageSampler {
  final int tileSize;

  TileImageSampler(int xPixelStart, int xPixelEnd, int yPixelStart,
                   int yPixelEnd, {this.tileSize: 32, bool randomize: true}) :
    super(xPixelStart, xPixelEnd, yPixelStart, yPixelEnd),
    _numSamples = (xPixelEnd - xPixelStart) *
                  (yPixelEnd - yPixelStart),
    _samples = new Int32List((xPixelEnd - xPixelStart) *
                             (yPixelEnd - yPixelStart) * 2) {
    int width = xPixelEnd - xPixelStart;
    int height = yPixelEnd - yPixelStart;
    int numXTiles = width ~/ tileSize + ((width % tileSize == 0) ? 0 : 1);
    int numYTiles = height ~/ tileSize + ((height % tileSize == 0) ? 0 : 1);

    Int32List tiles = new Int32List(numXTiles * numYTiles * 2);
    for (int yi = 0, ti = 0; yi < numYTiles; ++yi) {
      for (int xi = 0; xi < numXTiles; ++xi) {
        tiles[ti++] = xi;
        tiles[ti++] = yi;
      }
    }

    final int numTiles = tiles.length ~/ 2;

    if (randomize) {
      RNG rng = new RNG();

      // Shuffle the tiles
      for (int ti = 01; ti < numTiles; ++ti) {
        int lx = ti * 2;
        int ly = lx + 1;
        int rx = (rng.randomUInt() % numTiles) * 2;
        int ry = rx + 1;

        int t = tiles[lx];
        tiles[lx] = tiles[rx];
        tiles[rx] = t;

        t = tiles[ly];
        tiles[ly] = tiles[ry];
        tiles[ry] = t;
      }
    }

    int si = 0;
    for (int i = 0, ti = 0; i < numTiles; ++i) {
      int tx = tiles[ti++];
      int ty = tiles[ti++];

      int sx = xPixelStart + (tx * tileSize);
      int sy = yPixelStart + (ty * tileSize);

      for (int yi = 0; yi < tileSize; ++yi) {
        int y = sy + yi;
        if (y >= yPixelEnd) {
          break;
        }
        for (int xi = 0; xi < tileSize; ++xi) {
          int x = sx + xi;
          if (x >= xPixelEnd) {
            break;
          }

          _samples[si++] = x;
          _samples[si++] = y;
        }
      }
    }
  }

  int numPixels() => _numSamples;

  void getPixel(int index, List<int> pixel) {
    index *= 2;
    if (index >= _samples.length - 1) {
      return;
    }
    pixel[0] = _samples[index];
    pixel[1] = _samples[index + 1];
  }

  final int _numSamples;
  final Int32List _samples;
}
