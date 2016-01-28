// glyphrast/demo.rs
//
// Copyright (c) 2016 Mozilla Foundation

extern crate freetype;
#[macro_use]
extern crate glium;
extern crate glyphrast;

use freetype::Library;
use freetype::face::NO_SCALE;
use glium::draw_parameters::TimeElapsedQuery;
use glium::glutin::{Api, Event, GlRequest, WindowBuilder};
use glium::index::{NoIndices, PrimitiveType};
use glium::program::ProgramCreationInput;
use glium::vertex::EmptyInstanceAttributes;
use glium::{Blend, BlendingFunction, DisplayBuild, DrawParameters, LinearBlendingFactor, Program};
use glium::{Surface};
use glyphrast::{GLYPH_FRAGMENT_SHADER, GLYPH_TESSELLATION_CONTROL_SHADER};
use glyphrast::{GLYPH_TESSELLATION_EVALUATION_SHADER, GLYPH_VERTEX_SHADER, GlyphOutline};
use std::env;

pub fn main() {
    let ref mut args = env::args();

    if args.len() != 3 {
        let exe = args.next().unwrap();
        println!("Usage: {} font character", exe);
        return
    }

    let ref font = args.nth(1).unwrap();
    let character = args.next().and_then(|s| s.chars().next()).unwrap() as usize;
    let library = Library::init().unwrap();
    let face = library.new_face(font, 0).unwrap();
    face.set_char_size(40 * 64, 0, 50, 0).unwrap();
    face.load_char(character, NO_SCALE).unwrap();

    let display = WindowBuilder::new().with_gl(GlRequest::Specific(Api::OpenGl, (4, 1)))
                                      .build_glium()
                                      .unwrap();
    let window_size = display.get_window().as_ref().unwrap().get_inner_size_pixels().unwrap();

    let program = Program::new(&display, ProgramCreationInput::SourceCode {
        vertex_shader: GLYPH_VERTEX_SHADER,
        tessellation_control_shader: Some(GLYPH_TESSELLATION_CONTROL_SHADER),
        tessellation_evaluation_shader: Some(GLYPH_TESSELLATION_EVALUATION_SHADER),
        fragment_shader: GLYPH_FRAGMENT_SHADER,
        geometry_shader: None,
        transform_feedback_varyings: None,
        outputs_srgb: false,
        uses_point_size: false,
    }).unwrap();

    let glyph_outline = GlyphOutline::build(&display, face);
    println!("dimensions=({:?},{:?})", glyph_outline.width, glyph_outline.height);

    for _ in 0..5 {
        let mut target = display.draw();
        target.clear_color(0.0, 0.0, 0.0, 1.0);

        let elapsed = TimeElapsedQuery::new(&display).unwrap();
        target.draw((&glyph_outline.vbo, EmptyInstanceAttributes {
                        len: glyph_outline.width as usize,
                    }),
                    &NoIndices(PrimitiveType::Patches {
                        vertices_per_patch: glyph_outline.vbo.len() as u16,
                    }),
                    &program,
                    &uniform! {
                        uDimensions: (window_size.0 as f32, window_size.1 as f32),
                        uCurveCount: glyph_outline.vbo.len() as i32,
                    },
                    &DrawParameters {
                        time_elapsed_query: Some(&elapsed),
                        ..Default::default()
                    }).unwrap();

        target.finish().unwrap();

        let elapsed = elapsed.get();
        println!("time: {}ms", (elapsed as f64) / 1_000_000.0);
    }

    //println!("{:?}", glyph_outline.patches);

    loop {
        for event in display.wait_events() {
            if let Event::Closed = event {
                return
            }
        }
    }
}

