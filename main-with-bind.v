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
fn C.glShaderSource(shader u32, count int, string &&char, length &int)
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

fn compile_shader(shader_source string, shader_type u32) u32 {
	unsafe {
		shader := C.glCreateShader(shader_type)
		C.glShaderSource(shader, 1, &&char(&shader_source.str), C.NULL)
		C.glCompileShader(shader)

		// Check for compile errors
		success := 0
		C.glGetShaderiv(shader, C.GL_COMPILE_STATUS, &success)
		if success == 0 {
			mut log_length := 0
			C.glGetShaderiv(shader, C.GL_INFO_LOG_LENGTH, &log_length)
			info_log := malloc(log_length + 1) // +1 for null terminator
			info_log[log_length] = 0 // Ensure null-termination
			C.glGetShaderInfoLog(shader, log_length, C.NULL, info_log)
			println('ERROR: Shader compilation failed for type: ${shader_type}')
			println('Shader error log: ' + tos_clone(info_log))
			free(info_log)
			C.glDeleteShader(shader)
			return 0
		}
		return shader
	}
}

fn link_program(vertex_shader u32, fragment_shader u32) u32 {
	unsafe {
		program := C.glCreateProgram()
		C.glAttachShader(program, vertex_shader)
		C.glAttachShader(program, fragment_shader)
		C.glLinkProgram(program)

		success := 0
		C.glGetProgramiv(program, C.GL_LINK_STATUS, &success)
		if success == 0 {
			mut log_length := 0
			C.glGetProgramiv(program, C.GL_INFO_LOG_LENGTH, &log_length)
			info_log := malloc(log_length + 1) // +1 for null terminator
			info_log[log_length] = 0 // Ensure null-termination
			C.glGetProgramInfoLog(program, log_length, C.NULL, info_log)
			println('ERROR: Program linking failed')
			println('Program error log: ' + tos_clone(info_log))
			free(info_log)
			C.glDeleteProgram(program)
			return 0
		}
		return program
	}
}

fn main() {
	// Initialize SDL2
	if sdl.init(sdl.init_everything) < 0 {
		println('SDL_Init failed: ${sdl.get_error()}')
		return
	}

	// Create SDL window
	window := sdl.create_window('OpenGL 3.3 Window'.str, 0, 0, 800, 600, u32(sdl.WindowFlags.opengl) | u32(sdl.WindowFlags.resizable))
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
	if C.glewInit() != C.GLEW_OK {
		println('GLEW initialization failed')
		sdl.gl_delete_context(gl_context)
		sdl.destroy_window(window)
		sdl.quit()
		return
	}

	// Vertex data
	vertices := [
		f32(0.0), // I dont even know
		0.5,
		0.0,
		// Vertex 1
		1.0,
		0.0,
		0.0, // Color (Red)
		-0.5,
		-0.5, // Position
		// Vertex 2
		0.0,
		0.0, // Position
		1.0,
		0.0,
		0.5, // Color (Green)
		// Vertex 3
		-0.5,
		0.0, // Position
		0.0,
		0.0,
		1.0, // Color (Blue)
	]

	// Compile shaders
	vert_code := os.read_file('shaders/shader.vert') or { panic(err) }
	frag_code := os.read_file('shaders/shader.frag') or { panic(err) }

	vertex_shader := compile_shader(vert_code, u32(C.GL_VERTEX_SHADER))
	fragment_shader := compile_shader(frag_code, u32(C.GL_FRAGMENT_SHADER))
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
	C.glBindBuffer(C.GL_ARRAY_BUFFER, vbo)
	C.glBufferData(C.GL_ARRAY_BUFFER, vertices.len * int(sizeof(f32)), &vertices[0], C.GL_STATIC_DRAW)

	C.glVertexAttribPointer(0, 3, C.GL_FLOAT, 0, 6 * sizeof(f32), unsafe { nil })
	C.glEnableVertexAttribArray(0)

	C.glVertexAttribPointer(1, 3, C.GL_FLOAT, 0, 6 * sizeof(f32), voidptr(3 * sizeof(f32)))
	C.glEnableVertexAttribArray(1)

	C.glBindBuffer(C.GL_ARRAY_BUFFER, 0)
	C.glBindVertexArray(0)

	C.glClearColor(0.1, 0.3, 0.6, 1.0) // Light Blue Color

	// Main render loop
	mut running := true
	for running {
		mut event := sdl.Event{}
		for sdl.poll_event(&event) != 0 {
			if unsafe { event.type == sdl.EventType.quit } {
				running = false
			}
		}

		mut width := 0
		mut height := 0
		C.SDL_GetWindowSize(window, &width, &height)

		C.glViewport(0, 0, width, height)
		C.glClear(C.GL_COLOR_BUFFER_BIT)

		C.glUseProgram(shader_program)
		C.glBindVertexArray(vao)
		C.glDrawArrays(C.GL_TRIANGLES, 0, 3)
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
