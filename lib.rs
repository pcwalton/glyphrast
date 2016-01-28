// glyphrast/lib.rs
//
// Copyright (c) 2016 Mozilla Foundation

extern crate freetype;
extern crate freetype_sys;
#[macro_use]
extern crate glium;

use freetype::Face;
use freetype::outline::Curve;
use freetype_sys::FT_Vector;
use glium::{Display, VertexBuffer};

pub static FRAGMENT_SHADER: &'static str = include_str!("glyph.fs.glsl");
pub static TESSELLATION_CONTROL_SHADER: &'static str = include_str!("glyph.tcs.glsl");
pub static TESSELLATION_EVALUATION_SHADER: &'static str = include_str!("glyph.tes.glsl");
pub static VERTEX_SHADER: &'static str = include_str!("glyph.vs.glsl");

pub struct GlyphOutline {
    pub patches: Vec<Patch>,
    pub vbo: VertexBuffer<Patch>,
    pub width: i32,
}

fn add_curve(patches: &mut Vec<Patch>, last_point: &mut FT_Vector, curve: &Curve) {
    match *curve {
        Curve::Line(ref p1) => {
            patches.push(Patch::line(last_point, p1));
            *last_point = *p1
        }
        Curve::Bezier2(ref p1, ref p2) => {
            patches.push(Patch::quadratic(last_point, p1, p2));
            *last_point = *p2
        }
        Curve::Bezier3(ref p1, ref p2, ref p3) => {
            patches.push(Patch::cubic(last_point, p1, p2, p3));
            *last_point = *p3
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
        }
    }
}

#[derive(Copy, Clone, Debug)]
pub struct Patch {
    pub p0: (i32, i32),
    pub p1: (i32, i32),
    pub p2: (i32, i32),
    pub p3: (i32, i32),
}

implement_vertex!(Patch, p0, p1, p2, p3);

impl Patch {
    fn line(p0: &FT_Vector, p1: &FT_Vector) -> Patch {
        Patch {
            p0: p0.to_tuple(),
            p1: p1.to_tuple(),
            p2: p1.to_tuple(),
            p3: p1.to_tuple(),
        }
    }

    fn quadratic(p0: &FT_Vector, p1: &FT_Vector, p2: &FT_Vector) -> Patch {
        Patch {
            p0: p0.to_tuple(),
            p1: p1.to_tuple(),
            p2: p2.to_tuple(),
            p3: p2.to_tuple(),
        }
    }

    fn cubic(p0: &FT_Vector, p1: &FT_Vector, p2: &FT_Vector, p3: &FT_Vector) -> Patch {
        Patch {
            p0: p0.to_tuple(),
            p1: p1.to_tuple(),
            p2: p2.to_tuple(),
            p3: p3.to_tuple(),
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
