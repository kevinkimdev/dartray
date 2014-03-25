const String SCENE = """
Sampler "stratified" 
  "integer xsamples" [1]  "integer ysamples" [1]
  "bool jitter" ["false"]

PixelFilter "mitchell"

Accelerator "grid"

LookAt 2 4 -6   0 0 0   0 1 0

Camera "perspective"
  "float fov" [20]

#SurfaceIntegrator "whitted"
# "integer maxdepth" [5]
SurfaceIntegrator "directlighting"
  "string strategy" ["all"]

WorldBegin

# ----------
# Shapes
# ----------
#AttributeBegin # large white disk
# Rotate 90 1 0 0
# Material "matte" "color Kd" [1 1 1]
# Shape "disk" "float height" [1] "float radius" [6]  
#AttributeEnd



AttributeBegin # white sphere
  Rotate -40 1 0 -1
  Rotate -110 1 0 0
  Material "matte" "color Kd" [1 1 1]
  Shape "sphere" "float radius" [1.1]
AttributeEnd


# ----------
# Lights
# ----------
#AttributeBegin
# LightSource "distant" "color L" [1 1 1]  "color scale" [3 3 3]
# "point from" [-100 100 -100] "point to" [0 0 0]
#AttributeEnd

AttributeBegin
  LightSource "infinite" "color L" [0.9 0.9 1]  "color scale" [0.15 0.15 0.15]
AttributeEnd

WorldEnd
""";
