const String SCENE = """
Sampler "stratified" 
  "integer xsamples" [2] "integer ysamples" [2]
  "bool jitter" ["false"]

PixelFilter "mitchell"

LookAt 0 0 -20   0 0 1   0 1 0
Camera "perspective"
  "float fov" [60]

SurfaceIntegrator "whitted"
  "integer maxdepth" [5]

WorldBegin

# ----------
# Shapes
# ----------
AttributeBegin # bluey sky, encloses the whole scene
  Translate 0 0 0
  Material "matte" "color Kd" [0 0 1]
  Shape "sphere" "float radius" [60] 
AttributeEnd

AttributeBegin # gray bowl
  Translate 0 0 0
  Rotate -200 1 0 0
  Material "matte" "color Kd" [1 1 1]
  Shape "sphere" "float radius" [5] "float phimax" [180]
AttributeEnd

AttributeBegin # yellow ball
  Translate 6 6 -4
  Material "matte" "color Kd" [1 1 0]
  Shape "sphere" "float radius" [1]
AttributeEnd

AttributeBegin # cyan ball
  Translate -6 -2 -3
  Material "matte" "color Kd" [0 1 1]
  Shape "sphere" "float radius" [1]
AttributeEnd

AttributeBegin # blue ball
  Translate 4.5 0 -4.5
  Material "matte" "color Kd" [0 0 1]
  Shape "sphere" "float radius" [1]
AttributeEnd

AttributeBegin # magenta ball
  Translate 4 8 -1
  Material "matte" "color Kd" [1 0 1]
  Shape "sphere" "float radius" [1]
AttributeEnd

AttributeBegin # green ball
  Translate -4 4 -1
  Material "matte" "color Kd" [0 1 0]
  Shape "sphere" "float radius" [1]
AttributeEnd

# ----------
# Lights
# ----------
AttributeBegin
  Translate 0 20 -20
  LightSource "point" "color I" [1 1 1] "color scale" [1000 1000 1000]
AttributeEnd
AttributeBegin
  Translate -20 -2 1
  LightSource "point" "color I" [.4 .4 .8] "color scale" [600 600 600]
AttributeEnd
AttributeBegin
  Translate 20 -2 1
  LightSource "point" "color I" [1 1 .8] "color scale" [600 600 600]
AttributeEnd

WorldEnd
""";
