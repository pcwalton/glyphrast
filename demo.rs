// glyphrast/demo.rs
//
// Copyright (c) 2016 Mozilla Foundation

extern crate freetype;
#[macro_use]
extern crate glium;
extern crate glyphrast;

use freetype::Library;
use freetype::face::NO_SCALE;
use glium::glutin::{Api, Event, GlRequest, WindowBuilder};
use glium::index::{NoIndices, PrimitiveType};
use glium::program::ProgramCreationInput;
use glium::{DisplayBuild, Program, Surface};
use glyphrast::{FRAGMENT_SHADER, GlyphOutline, TESSELLATION_CONTROL_SHADER};
use glyphrast::{TESSELLATION_EVALUATION_SHADER, VERTEX_SHADER};
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
    let program = Program::new(&display, ProgramCreationInput::SourceCode {
        vertex_shader: VERTEX_SHADER,
        tessellation_control_shader: Some(TESSELLATION_CONTROL_SHADER),
        tessellation_evaluation_shader: Some(TESSELLATION_EVALUATION_SHADER),
        fragment_shader: FRAGMENT_SHADER,
        geometry_shader: None,
        transform_feedback_varyings: None,
        outputs_srgb: false,
        uses_point_size: false,
    }).unwrap();

    let glyph_outline = GlyphOutline::build(&display, face);

    let mut target = display.draw();
    target.clear_color(0.0, 0.0, 1.0, 1.0);
    target.draw(&glyph_outline.vbo,
                &NoIndices(PrimitiveType::Patches {
                    vertices_per_patch: 1,
                }),
                &program,
                &uniform!(uWidth: glyph_outline.width),
                &Default::default()).unwrap();

    target.finish().unwrap();

    println!("{:?}", glyph_outline.patches);

    loop {
        for event in display.wait_events() {
            if let Event::Closed = event {
                return
            }
        }
    }
}

