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

pub struct GlyphOutline {
    pub patches: Vec<Patch>,
    pub vbo: VertexBuffer<Patch>,
    pub width: i32,
    pub height: i32,
}

fn add_curve(patches: &mut Vec<Patch>, p0: &mut FT_Vector, curve: &Curve) {
    match *curve {
        Curve::Line(ref p1) => {
            let y_min = cmp::min(p0.y as i32, p1.y as i32);
            let y_max = cmp::max(p0.y as i32, p1.y as i32);
            //println!("line {:?} {:?}", p0.to_tuple(), p1.to_tuple());
            patches.push(Patch::line(p0, p1));
            *p0 = *p1
        }
        Curve::Bezier2(ref p1, ref p2) => {
            let y_min = cmp::min(p0.y as i32, p2.y as i32);
            let y_max = cmp::max(p0.y as i32, p2.y as i32);
            patches.push(Patch::quadratic(p0, p1, p2));
            *p0 = *p2
        }
        Curve::Bezier3(ref p1, ref p2, ref p3) => {
            let y_min = cmp::min(p0.y as i32, p3.y as i32);
            let y_max = cmp::max(p0.y as i32, p3.y as i32);
            patches.push(Patch::cubic(p0, p1, p2, p3));
            *p0 = *p3
        }
    }
}

impl GlyphOutline {
    pub fn build(display: &Display, face: Face) -> GlyphOutline {
        let glyph = face.glyph();
        let metrics = glyph.metrics();
        let xmin = metrics.horiBearingX - 5;
        let width = metrics.width + 10;
        let ymin = -metrics.horiBearingY - 5;
        let height = metrics.height + 10;
        let outline = glyph.outline().unwrap();

        let mut patches = vec![];
        for contour in outline.contours_iter() {
            let mut last_point = *contour.start();
            for curve in contour {
                add_curve(&mut patches, &mut last_point, &curve);
            }
        }
        let vbo = VertexBuffer::new(display, &patches).unwrap();
        GlyphOutline {
            patches: patches,
            vbo: vbo,
            width: width as i32,
            height: height as i32,
        }
    }
}

#[derive(Copy, Clone, Debug)]
pub struct Patch {
    pub aP0: (i32, i32),
    pub aP1: (i32, i32),
    pub aP2: (i32, i32),
    pub aP3: (i32, i32),
}

implement_vertex!(Patch, aP0, aP1, aP2, aP3);

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

