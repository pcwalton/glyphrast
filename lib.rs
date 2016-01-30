// glyphrast/lib.rs
//
// Copyright (c) 2016 Mozilla Foundation

#![feature(step_by)]

extern crate freetype;
extern crate freetype_sys;
#[macro_use]
extern crate glium;

use freetype::Face;
use freetype::outline::Curve;
use freetype_sys::FT_Vector;
use glium::{Display, VertexBuffer};
use std::cmp;

pub static GLYPH_FRAGMENT_SHADER: &'static str = include_str!("glyph.fs.glsl");
pub static GLYPH_TESSELLATION_CONTROL_SHADER: &'static str = include_str!("glyph.tcs.glsl");
pub static GLYPH_TESSELLATION_EVALUATION_SHADER: &'static str = include_str!("glyph.tes.glsl");
pub static GLYPH_VERTEX_SHADER: &'static str = include_str!("glyph.vs.glsl");
pub static RESOLUTION_FRAGMENT_SHADER: &'static str = include_str!("resolve.fs.glsl");
pub static RESOLUTION_VERTEX_SHADER: &'static str = include_str!("resolve.vs.glsl");

const MAX_TEX_GEN_LEVEL: i32 = 32;

pub struct GlyphOutlines {
    pub patches: Vec<Patch>,
    pub outlines_vbo: VertexBuffer<PatchVertex>,
    pub metadata_vbo: VertexBuffer<GlyphMetadata>,
    pub dimensions: Vec<(i32, i32)>,
}

fn add_curve(patches: &mut Vec<Patch>, p0: &mut FT_Vector, curve: &Curve) {
    match *curve {
        Curve::Line(ref p1) => {
            let y_min = cmp::min(p0.y as i32, p1.y as i32);
            let y_max = cmp::max(p0.y as i32, p1.y as i32);
            println!("line {:?} {:?}", p0.to_tuple(), p1.to_tuple());
            patches.push(Patch::line(p0, p1));
            *p0 = *p1
        }
        Curve::Bezier2(ref p1, ref p2) => {
            let y_min = cmp::min(p0.y as i32, p2.y as i32);
            let y_max = cmp::max(p0.y as i32, p2.y as i32);
            println!("bezier2 {:?} {:?}", p0.to_tuple(), p2.to_tuple());
            patches.push(Patch::quadratic(p0, p1, p2));
            *p0 = *p2
        }
        Curve::Bezier3(ref p1, ref p2, ref p3) => {
            let y_min = cmp::min(p0.y as i32, p3.y as i32);
            let y_max = cmp::max(p0.y as i32, p3.y as i32);
            println!("bezier3 {:?} {:?}", p0.to_tuple(), p3.to_tuple());
            patches.push(Patch::cubic(p0, p1, p2, p3));
            *p0 = *p3
        }
    }
}

impl GlyphOutlines {
    pub fn build(display: &Display, parameters: &[GlyphParameters]) -> GlyphOutlines {
        let mut patches = vec![];
        let mut metadata = vec![];
        let mut dimensions = vec![];
        for parameters in parameters {
            let glyph = parameters.face.glyph();
            let metrics = glyph.metrics();
            let xmin = metrics.horiBearingX - 5;
            let width = metrics.width + 10;
            let ymin = -metrics.horiBearingY - 5;
            let height = metrics.height + 10;
            let outline = glyph.outline().unwrap();

            let patches_target_size = patches.len() + 64;
            let mut k = 0;
            for contour in outline.contours_iter() {
                let mut last_point = *contour.start();
                for curve in contour {
                    if patches.len() >= patches_target_size {
                        println!("--- broken!");
                        break
                    }
                    add_curve(&mut patches, &mut last_point, &curve);
                }
            }

            let mut counts = vec![];
            'outer: for contour in outline.contours_iter() {
                let mut count = 0;
                for curve in contour {
                    count += 1;
                }
                counts.push(count)
            }
            println!("counts={:?}", counts);

            while patches.len() < patches_target_size {
                patches.push(Patch::line(&FT_Vector { x: 0, y: 0 }, &FT_Vector { x: 0, y: 0 }));
            }
            for _ in 0..32 {
                metadata.push(GlyphMetadata {
                    aGlyphHeight: height as f32,
                    aRasterOrigin: parameters.raster_origin,
                    aRasterHeight: parameters.raster_height,
                    aCurveCount: 32,
                });
            }
            dimensions.push((width as i32, height as i32));
        }

        let mut patch_vertices = vec![];
        for i in 0..(patches.len() / 2) {
            patch_vertices.push(PatchVertex {
                aAP0: patches[i*2+0].aP0,
                aAP1: patches[i*2+0].aP1,
                aAP2: patches[i*2+0].aP2,
                aAP3: patches[i*2+0].aP3,
                aBP0: patches[i*2+1].aP0,
                aBP1: patches[i*2+1].aP1,
                aBP2: patches[i*2+1].aP2,
                aBP3: patches[i*2+1].aP3,
            })
        }
        println!("{} patches -> {} patch vertices", patches.len(), patch_vertices.len());

        let outlines_vbo = VertexBuffer::new(display, &patch_vertices).unwrap();
        let metadata_vbo = VertexBuffer::new(display, &metadata).unwrap();
        GlyphOutlines {
            patches: patches,
            outlines_vbo: outlines_vbo,
            metadata_vbo: metadata_vbo,
            dimensions: dimensions,
        }
    }
}

#[derive(Copy, Clone, Debug)]
pub struct PatchVertex {
    pub aAP0: (i32, i32),
    pub aAP1: (i32, i32),
    pub aAP2: (i32, i32),
    pub aAP3: (i32, i32),
    pub aBP0: (i32, i32),
    pub aBP1: (i32, i32),
    pub aBP2: (i32, i32),
    pub aBP3: (i32, i32),
}

implement_vertex!(PatchVertex, aAP0, aAP1, aAP2, aAP3, aBP0, aBP1, aBP2, aBP3);

#[derive(Copy, Clone, Debug)]
pub struct Patch {
    pub aP0: (i32, i32),
    pub aP1: (i32, i32),
    pub aP2: (i32, i32),
    pub aP3: (i32, i32),
}

impl Patch {
    fn line(p0: &FT_Vector, p1: &FT_Vector) -> Patch {
        Patch {
            aP0: p0.to_tuple(),
            aP1: p1.to_tuple(),
            aP2: p1.to_tuple(),
            aP3: p1.to_tuple(),
        }
    }

    fn quadratic(p0: &FT_Vector, p1: &FT_Vector, p2: &FT_Vector) -> Patch {
        Patch {
            aP0: p0.to_tuple(),
            aP1: p1.to_tuple(),
            aP2: p2.to_tuple(),
            aP3: p2.to_tuple(),
        }
    }

    fn cubic(p0: &FT_Vector, p1: &FT_Vector, p2: &FT_Vector, p3: &FT_Vector) -> Patch {
        Patch {
            aP0: p0.to_tuple(),
            aP1: p1.to_tuple(),
            aP2: p2.to_tuple(),
            aP3: p3.to_tuple(),
        }
    }
}

trait ToTuple {
    fn to_tuple(&self) -> (i32, i32);
}

impl ToTuple for FT_Vector {
    fn to_tuple(&self) -> (i32, i32) {
        (self.x as i32, self.y as i32)
    }
}

#[derive(Copy, Clone, Debug)]
pub struct GlyphMetadata {
    pub aGlyphHeight: f32,
    pub aRasterOrigin: [f32; 2],
    pub aRasterHeight: f32,
    pub aCurveCount: i32,
}

implement_vertex!(GlyphMetadata, aGlyphHeight, aRasterOrigin, aRasterHeight, aCurveCount);

pub struct GlyphParameters<'a> {
    pub face: Face<'a>,
    pub raster_height: f32,
    pub raster_origin: [f32; 2],
}

