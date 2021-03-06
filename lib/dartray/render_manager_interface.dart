/****************************************************************************
 * Copyright (C) 2014 by Brendan Duncan.                                    *
 *                                                                          *
 * This file is part of DartRay.                                            *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 * http://www.apache.org/licenses/LICENSE-2.0                               *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 *                                                                          *
 * This project is based on PBRT v2 ; see http://www.pbrt.org               *
 * pbrt2 source code Copyright(c) 1998-2010 Matt Pharr and Greg Humphreys.  *
 ****************************************************************************/
part of dartray;

/**
 * Manages the rendering process, either rendering locally or submitting the
 * job to one or more isolates (web workers).
 */
abstract class RenderManagerInterface extends ResourceManager {
  DartRay dartray;
  String scenePath;
  OutputImage renderOutput;

  RenderManagerInterface(this.scenePath) {
    RegisterStandardPlugins();
    dartray = new DartRay(this);
  }

  static void RegisterStandardPlugins() {
    // If 'sphere' has been registered, we can assume the rest of the standard
    // plugins have been registered too.
    if (Plugin.shape('sphere') != null) {
      return;
    }

    Plugin.registerAccelerator('bvh', BVHAccel.Create);
    Plugin.registerAccelerator('grid', GridAccel.Create);
    Plugin.registerAccelerator('kdtree', KdTreeAccel.Create);
    Plugin.registerAccelerator('bruteforce', BruteForceAccel.Create);

    Plugin.registerCamera('environment', EnvironmentCamera.Create);
    Plugin.registerCamera('orthographic', OrthographicCamera.Create);
    Plugin.registerCamera('perspective', PerspectiveCamera.Create);

    Plugin.registerFilm('image', ImageFilm.Create);

    Plugin.registerFilter('box', BoxFilter.Create);
    Plugin.registerFilter('gaussian', GaussianFilter.Create);
    Plugin.registerFilter('sinc', LanczosSincFilter.Create);
    Plugin.registerFilter('mitchell', MitchellFilter.Create);
    Plugin.registerFilter('triangle', TriangleFilter.Create);

    Plugin.registerSurfaceIntegrator('ambientocclusion',
        AmbientOcclusionIntegrator.Create);
    Plugin.registerSurfaceIntegrator('diffuseprt', DiffusePRTIntegrator.Create);
    Plugin.registerSurfaceIntegrator('directlighting',
        DirectLightingIntegrator.Create);
    Plugin.registerSurfaceIntegrator('glossyprt', GlossyPRTIntegrator.Create);
    Plugin.registerSurfaceIntegrator('igi', IGIIntegrator.Create);
    Plugin.registerSurfaceIntegrator('irradiancecache',
        IrradianceCacheIntegrator.Create);
    Plugin.registerSurfaceIntegrator('path', PathIntegrator.Create);
    Plugin.registerSurfaceIntegrator('photonmap', PhotonMapIntegrator.Create);
    Plugin.registerSurfaceIntegrator('exphotonmap', PhotonMapIntegrator.Create);
    Plugin.registerSurfaceIntegrator('whitted', WhittedIntegrator.Create);
    Plugin.registerSurfaceIntegrator('useprobes', UseProbesIntegrator.Create);
    Plugin.registerSurfaceIntegrator('dipolesubsurface',
        DipoleSubsurfaceIntegrator.Create);

    Plugin.registerLight('distant', DistantLight.Create);
    Plugin.registerLight('point', PointLight.Create);
    Plugin.registerLight('spot', SpotLight.Create);
    Plugin.registerLight('infinite', InfiniteAreaLight.Create);
    Plugin.registerLight('goniometric', GoniometricLight.Create);
    Plugin.registerLight('projection', ProjectionLight.Create);

    Plugin.registerAreaLight('diffuse', DiffuseAreaLight.Create);
    Plugin.registerAreaLight('area', DiffuseAreaLight.Create);

    Plugin.registerMaterial('glass', GlassMaterial.Create);
    Plugin.registerMaterial('kdsubsurface', KdSubsurfaceMaterial.Create);
    Plugin.registerMaterial('matte', MatteMaterial.Create);
    Plugin.registerMaterial('measured', MeasuredMaterial.Create);
    Plugin.registerMaterial('metal', MetalMaterial.Create);
    Plugin.registerMaterial('mirror', MirrorMaterial.Create);
    Plugin.registerMaterial('plastic', PlasticMaterial.Create);
    Plugin.registerMaterial('shinymetal', ShinyMetalMaterial.Create);
    Plugin.registerMaterial('substrate', SubstrateMaterial.Create);
    Plugin.registerMaterial('subsurface', SubsurfaceMaterial.Create);
    Plugin.registerMaterial('translucent', TranslucentMaterial.Create);
    Plugin.registerMaterial('uber', UberMaterial.Create);

    Plugin.registerPixelSampler('linear', LinearPixelSampler.Create);
    Plugin.registerPixelSampler('random', RandomPixelSampler.Create);
    Plugin.registerPixelSampler('tile', TilePixelSampler.Create);

    Plugin.registerSampler('adaptive', AdaptiveSampler.Create);
    Plugin.registerSampler('bestcandidate', BestCandidateSampler.Create);
    Plugin.registerSampler('halton', HaltonSampler.Create);
    Plugin.registerSampler('lowdiscrepancy', LowDiscrepancySampler.Create);
    Plugin.registerSampler('random', RandomSampler.Create);
    Plugin.registerSampler('stratified', StratifiedSampler.Create);

    Plugin.registerShape('cone', Cone.Create);
    Plugin.registerShape('cylinder', Cylinder.Create);
    Plugin.registerShape('disk', Disk.Create);
    Plugin.registerShape('heightfield', Heightfield.Create);
    Plugin.registerShape('hyperboloid', Hyperboloid.Create);
    Plugin.registerShape('loopsubdiv', LoopSubdivision.Create);
    Plugin.registerShape('nurbs', Nurbs.Create);
    Plugin.registerShape('paraboloid', Paraboloid.Create);
    Plugin.registerShape('sphere', Sphere.Create);
    Plugin.registerShape('trianglemesh', TriangleMesh.Create);

    Plugin.registerFloatTexture('bilerp', BilerpTexture.CreateFloat);
    Plugin.registerSpectrumTexture('bilerp', BilerpTexture.CreateSpectrum);
    Plugin.registerFloatTexture('checkerboard',
        CheckerboardTexture.CreateFloat);
    Plugin.registerSpectrumTexture('checkerboard',
        CheckerboardTexture.CreateSpectrum);
    Plugin.registerFloatTexture('constant', ConstantTexture.CreateFloat);
    Plugin.registerSpectrumTexture('constant', ConstantTexture.CreateSpectrum);
    Plugin.registerFloatTexture('dots', DotsTexture.CreateFloat);
    Plugin.registerSpectrumTexture('dots', DotsTexture.CreateSpectrum);
    Plugin.registerFloatTexture('fbm', FBmTexture.CreateFloat);
    Plugin.registerSpectrumTexture('fbm', FBmTexture.CreateSpectrum);
    Plugin.registerFloatTexture('imagemap', ImageTexture.CreateFloat);
    Plugin.registerSpectrumTexture('imagemap', ImageTexture.CreateSpectrum);
    Plugin.registerFloatTexture('marble', MarbleTexture.CreateFloat);
    Plugin.registerSpectrumTexture('marble', MarbleTexture.CreateSpectrum);
    Plugin.registerFloatTexture('mix', MixTexture.CreateFloat);
    Plugin.registerSpectrumTexture('mix', MixTexture.CreateSpectrum);
    Plugin.registerFloatTexture('scale', ScaleTexture.CreateFloat);
    Plugin.registerSpectrumTexture('scale', ScaleTexture.CreateSpectrum);
    Plugin.registerFloatTexture('uv', UVTexture.CreateFloat);
    Plugin.registerSpectrumTexture('uv', UVTexture.CreateSpectrum);
    Plugin.registerFloatTexture('windy', WindyTexture.CreateFloat);
    Plugin.registerSpectrumTexture('windy', WindyTexture.CreateSpectrum);
    Plugin.registerFloatTexture('wrinkled', WrinkledTexture.CreateFloat);
    Plugin.registerSpectrumTexture('wrinkled', WrinkledTexture.CreateSpectrum);

    Plugin.registerVolumeIntegrator('emission', EmissionIntegrator.Create);
    Plugin.registerVolumeIntegrator('single',
        SingleScatteringIntegrator.Create);

    Plugin.registerVolumeRegion('exponential', ExponentialDensityRegion.Create);
    Plugin.registerVolumeRegion('homogeneous', HomogeneousVolumeRegion.Create);
    Plugin.registerVolumeRegion('volumegrid', VolumeGridDensity.Create);
  }
}

