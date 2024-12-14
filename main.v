module main

import sdl
import os
import gl
import gl.glew

fn compile_shader(shader_source voidptr, shader_type u32) u32 {
	unsafe {
		shader := C.glCreateShader(shader_type)
		C.glShaderSource(shader, 1, &&char(malloc(sizeof(shader_source))), C.NULL)
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
	unsafe {
		program := C.glCreateProgram()
		C.glAttachShader(program, vertex_shader)
		C.glAttachShader(program, fragment_shader)
		C.glLinkProgram(program)

		succes := 0
		C.glGetProgramiv(program, C.GL_LINK_STATUS, &succes)
		if succes != 0 {
			log_length := 0
			C.glGetProgramiv(program, C.GL_INFO_LOG_LENGTH, &log_length)
			info_log := malloc(log_length)
			C.glGetShaderInfoLog(program, log_length, C.NULL, info_log)
			println('ERROR: Program linking failed: ${info_log}')
			free(info_log)
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
	if C.glewInit() != glew.ok {
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

	C.glVertexAttribPointer(0, 3, gl.gl_float, 0, 6 * sizeof(f32), unsafe { nil }) // GL_FLOAT
	C.glEnableVertexAttribArray(0)

	C.glVertexAttribPointer(1, 3, gl.gl_float, 0, 6 * sizeof(f32), voidptr(3 * sizeof(f32))) // GL_FLOAT
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