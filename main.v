import sdl
import os

#preinclude <GL/glew.h>
#include <GL/gl.h>

#flag -lGLEW -lGL -lGLU

// Binding for OpenGL functions
fn C.glVertexAttribPointer(index u32, size int, type_ u32, normalized u8, stride int, pointer voidptr)
fn C.glGenVertexArrays(n int, arrays voidptr)
fn C.glGenBuffers(n int, buffers voidptr)
fn C.glBindVertexArray(array u32)
fn C.glBindBuffer(target u32, buffer u32)
fn C.glBufferData(target u32, size int, data voidptr, usage u32)
fn C.glEnableVertexAttribArray(index u32)
fn C.glUseProgram(program u32)
fn C.glClear(mask u32)
fn C.glClearColor(red f32, green f32, blue f32, alpha f32)
fn C.glViewport(x int, y int, width int, height int)
fn C.glDrawArrays(mode u32, first int, count int)
fn C.glDeleteVertexArrays(n int, arrays voidptr)
fn C.glDeleteBuffers(n int, buffers voidptr)
fn C.glDeleteProgram(program u32)
fn C.glCreateShader(typ_ u32) u32
fn C.glShaderSource(shader u32, count int, string &char, length &int)
fn C.glCompileShader(shader u32)
fn C.glGetShaderiv(shader u32, pname u32, params &int)
fn C.glGetShaderInfoLog(shader u32, buf_size int, length &int, info_log &char)
fn C.glCreateProgram() u32
fn C.glAttachShader(program u32, shader u32)
fn C.glLinkProgram(program u32)
fn C.glGetProgramiv(program u32, pname u32, params &int)
fn C.glGetProgramInfoLog(program u32, buf_size int, length &int, info_log &char)
fn C.glewInit() int
fn C.glDeleteShader(u32)

fn compile_shader(shader_source voidptr, shader_type u32) u32 {
	unsafe {
		shader := C.glCreateShader(shader_type)
		C.glShaderSource(shader, 1, &shader_source, C.NULL)
		C.glCompileShader(shader)

		// Check for compile errors
		success := 0
		C.glGetShaderiv(shader, C.GL_COMPILE_STATUS, &success)
		if success != 0 {
			log_length := 0
			C.glGetShaderiv(shader, C.GL_INFO_LOG_LENGTH, &log_length)
			info_log := malloc(log_length)
			C.glGetShaderInfoLog(shader, log_length, C.NULL, info_log)
			println('ERROR: Shader compilation failed: ${info_log}')
			free(info_log)
			C.glDeleteShader(shader)
			return 0
		}
		return shader
	}
}

fn link_program(vertex_shader u32, fragment_shader u32) u32 {
	program := C.glCreateProgram()
	C.glAttachShader(program, vertex_shader)
	C.glAttachShader(program, fragment_shader)
	C.glLinkProgram(program)

	mut success := 0
	C.glGetProgramiv(program, 0x8B82, &success) // GL_LINK_STATUS
	if success == 0 {
		mut log_length := 0
		C.glGetProgramiv(program, 0x8B84, &log_length) // GL_INFO_LOG_LENGTH
		mut info_log := ' '.repeat(log_length)
		C.glGetProgramInfoLog(program, log_length, &log_length, info_log.str)
		println('ERROR: Program linking failed: ${info_log}')
		return 0
	}
	return program
}

fn main() {
	// Initialize SDL2
	if sdl.init(sdl.init_everything) < 0 {
		println('SDL_Init failed: ${sdl.get_error()}')
		return
	}

	// Create SDL window
	window := sdl.create_window('OpenGL Window'.str, 0, 0, 800, 600, u32(sdl.WindowFlags.opengl))
	if window == 0 {
		println('SDL_CreateWindow failed: ${sdl.get_error()}')
		sdl.quit()
		return
	}

	// Create OpenGL context
	gl_context := sdl.gl_create_context(window)
	if gl_context == 0 {
		println('SDL_GL_CreateContext failed: ${sdl.get_error()}')
		sdl.destroy_window(window)
		sdl.quit()
		return
	}

	// Initialize GLEW
	if C.glewInit() != 0 {
		println('GLEW initialization failed')
		sdl.gl_delete_context(gl_context)
		sdl.destroy_window(window)
		sdl.quit()
		return
	}

	// Vertex data
	vertices := [
		f32(0.0),
		0.5,
		0.0,
		1.0,
		0.0,
		0.0, // Vertex 1 (Red)
		-0.5,
		-0.5,
		0.0,
		0.0,
		1.0,
		0.0, // Vertex 2 (Green)
		0.5,
		-0.5,
		0.0,
		0.0,
		0.0,
		1.0, // Vertex 3 (Blue)
	]

	// Compile shaders
	vert_code := os.read_file('shader.vert') or { panic(err) }
	frag_code := os.read_file('shader.frag') or { panic(err) }

	vertex_shader := compile_shader(voidptr(vert_code.str), 0x8B31) // GL_VERTEX_SHADER
	fragment_shader := compile_shader(voidptr(frag_code.str), 0x8B30) // GL_FRAGMENT_SHADER
	shader_program := link_program(vertex_shader, fragment_shader)

	if shader_program == 0 {
		println('Failed to create shader program')
		sdl.gl_delete_context(gl_context)
		sdl.destroy_window(window)
		sdl.quit()
		return
	}

	// Set up buffers and array objects
	mut vao := u32(0)
	mut vbo := u32(0)
	C.glGenVertexArrays(1, &vao)
	C.glGenBuffers(1, &vbo)

	C.glBindVertexArray(vao)
	C.glBindBuffer(0x8892, vbo) // GL_ARRAY_BUFFER
	C.glBufferData(0x8892, vertices.len * int(sizeof(f32)), &vertices[0], 0x88E4) // GL_STATIC_DRAW

	C.glVertexAttribPointer(0, 3, 0x1406, 0, 6 * sizeof(f32), unsafe { nil }) // GL_FLOAT
	C.glEnableVertexAttribArray(0)

	C.glVertexAttribPointer(1, 3, 0x1406, 0, 6 * sizeof(f32), voidptr(3 * sizeof(f32))) // GL_FLOAT
	C.glEnableVertexAttribArray(1)

	C.glBindBuffer(0x8892, 0)
	C.glBindVertexArray(0)

	// OpenGL settings
	C.glClearColor(0.0, 0.0, 0.0, 1.0) // Black background

	// Main render loop
	mut running := true
	for running {
		mut event := C.SDL_Event{}
		for C.SDL_PollEvent(&event) != 0 {
			if unsafe { event.type == sdl.EventType.quit } {
				running = false
			}
		}

		mut width := 0
		mut height := 0
		C.SDL_GetWindowSize(window, &width, &height)

		if width == 0 || height == 0 {
			println('Invalid window size.')
			break
		}

		C.glViewport(0, 0, width, height)
		C.glClear(0x00004000) // GL_COLOR_BUFFER_BIT

		C.glUseProgram(shader_program)
		C.glBindVertexArray(vao)
		C.glDrawArrays(0x0004, 0, 3) // GL_TRIANGLES
		C.glBindVertexArray(0)

		sdl.gl_swap_window(window)
	}

	// Clean up
	C.glDeleteVertexArrays(1, &vao)
	C.glDeleteBuffers(1, &vbo)
	C.glDeleteProgram(shader_program)

	sdl.gl_delete_context(gl_context)
	sdl.destroy_window(window)
	sdl.quit()
}
