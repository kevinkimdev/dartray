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
part of materials;

/**
 * Material "substrate" <Parameters>
 * ----------------------------------------------------------------------------
 * | **Type**   |  **Name**       |   **Default**   |   **Description**
 * ----------------------------------------------------------------------------
 * | spectrum   |  Kd             |   0.5           |
 * | teture     |                 |                 |
 * ----------------------------------------------------------------------------
 * | spectrum   |  Ks             |   0.5           |
 * | teture     |                 |                 |
 * ----------------------------------------------------------------------------
 * | float      |  uroughness     |   0.1           |
 * | teture     |                 |                 |
 * ----------------------------------------------------------------------------
 * | float      |  vroughness     |   0.1           |
 * | teture     |                 |                 |
 * ----------------------------------------------------------------------------
 * | float      |  bumpmap        |   null          |
 * | teture     |                 |                 |
 * ----------------------------------------------------------------------------
 */
class SubstrateMaterial extends Material {
  SubstrateMaterial(this.Kd, this.Ks, this.nu, this.nv, this.bumpMap);

  BSDF getBSDF(DifferentialGeometry dgGeom, DifferentialGeometry dgShading) {
    // Allocate BSDF, possibly doing bump mapping with bumpMap
    DifferentialGeometry dgs;
    if (bumpMap != null) {
      dgs = new DifferentialGeometry();
      Material.Bump(bumpMap, dgGeom, dgShading, dgs);
    } else {
      dgs = dgShading;
    }

    BSDF bsdf = new BSDF(dgs, dgGeom.nn);

    Spectrum d = Kd.evaluate(dgs).clamp();
    Spectrum s = Ks.evaluate(dgs).clamp();
    double u = nu.evaluate(dgs);
    double v = nv.evaluate(dgs);

    if (!d.isBlack() || !s.isBlack()) {
      bsdf.add(new FresnelBlend(d, s, new Anisotropic(1.0 / u, 1.0 / v)));
    }

    return bsdf;
  }

  static SubstrateMaterial Create(Transform xform, TextureParams mp) {
    Texture Kd = mp.getSpectrumTexture('Kd', new Spectrum(0.5));
    Texture Ks = mp.getSpectrumTexture('Ks', new Spectrum(0.5));
    Texture uroughness = mp.getFloatTexture('uroughness', 0.1);
    Texture vroughness = mp.getFloatTexture('vroughness', 0.1);
    Texture bumpMap = mp.getFloatTextureOrNull('bumpmap');
    return new SubstrateMaterial(Kd, Ks, uroughness, vroughness, bumpMap);
  }

  Texture Kd;
  Texture Ks;
  Texture nu;
  Texture nv;
  Texture bumpMap;
}
