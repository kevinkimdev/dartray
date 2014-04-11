
const String SCENE = """
Scale -1 1 1
LookAt 18 3.5 2    8 -.5 20   0 1 0
Camera "perspective" "float fov" [50]

Sampler "lowdiscrepancy" "integer pixelsamples" [16]
PixelFilter "box"

SurfaceIntegrator "path"

WorldBegin

# lights
LightSource "spot" "color I" [7000000 7000000 7000000] "point from" [70 230 -300]
		"point to" [10 10 10] "float coneangle" [1]
		"float conedeltaangle" [.01]

Include "geometry/room-geom.pbrt"

WorldEnd
""";
