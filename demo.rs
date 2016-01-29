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
use glium::uniforms::UniformBuffer;
use glium::vertex::EmptyInstanceAttributes;
use glium::{Blend, BlendingFunction, DisplayBuild, DrawParameters, LinearBlendingFactor, Program};
use glium::{Surface, VertexBuffer};
use glyphrast::{GLYPH_FRAGMENT_SHADER, GLYPH_TESSELLATION_CONTROL_SHADER};
use glyphrast::{GLYPH_TESSELLATION_EVALUATION_SHADER, GLYPH_VERTEX_SHADER, GlyphOutlines};
use glyphrast::{GlyphMetadata, GlyphParameters};
use std::env;

//static STRING: &'static str = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
static STRING: &'static str = "ABBDEFFHIJKLMNOPQQQTTVVXYZZbbdeeehijklllopqrrrrvvxyz";
//static STRING: &'static str = "B";

const RASTER_HEIGHT: f32 = 24.0;

pub fn main() {
    let ref mut args = env::args();

    if args.len() < 2 {
        let exe = args.next().unwrap();
        println!("Usage: {} font", exe);
        return
    }

    let ref font = args.nth(1).unwrap();
    let library = Library::init().unwrap();

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

    let mut parameters = vec![];
    for (i, ch) in STRING.chars().enumerate() {
        let face = library.new_face(font, 0).unwrap();
        face.set_char_size(40 * 64, 0, 50, 0).unwrap();
        face.load_char(ch as usize, NO_SCALE).unwrap();
        parameters.push(GlyphParameters {
            face: face,
            raster_height: RASTER_HEIGHT,
            raster_origin: [(i * 24) as f32, 0.0],
        })
    }

    let glyph_outlines = GlyphOutlines::build(&display, &parameters);
    for _ in 0..5 {
        let mut target = display.draw();
        target.clear_color(0.0, 0.0, 0.0, 1.0);

        let glyph_raster_height = RASTER_HEIGHT as usize;

        /*
        let mut glyph_heights = Box::new([0.0; 256]);
        let mut raster_origins = Box::new([0.0; 256]);
        let mut raster_heights = Box::new([0.0; 256]);
        let mut curve_counts = Box::new([0; 256]);
        for i in 0..52 {
            glyph_heights[i] = glyph_outlines.dimensions[0].1 as f32;
            raster_origins[i] = (i as f32) * (glyph_raster_height as f32);
            raster_heights[i] = glyph_raster_height as f32;
            curve_counts[i] = 32;
        }

        let glyph_heights = UniformBuffer::new(&display, *glyph_heights).unwrap();
        let raster_origins = UniformBuffer::new(&display, *raster_origins).unwrap();
        let raster_heights = UniformBuffer::new(&display, *raster_heights).unwrap();
        let curve_counts = UniformBuffer::new(&display, *curve_counts).unwrap();*/

        let elapsed = TimeElapsedQuery::new(&display).unwrap();
        target.draw((&glyph_outlines.outlines_vbo,
                     &glyph_outlines.metadata_vbo,
                     EmptyInstanceAttributes {
                         len: glyph_raster_height,
                     }),
                    &NoIndices(PrimitiveType::Patches {
                        vertices_per_patch: 32,
                    }),
                    &program,
                    &uniform! {
                        uWindowDimensions: (window_size.0 as f32, window_size.1 as f32),
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

