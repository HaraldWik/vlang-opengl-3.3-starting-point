module gl

#preinclude <GL/glew.h>
#include <GL/gl.h>

#flag -lGLEW -lGL -lGLU

pub const gl_false = u32(C.GL_FALSE)
pub const gl_true = u32(C.GL_TRUE)
pub const gl_float = u32(C.GL_FLOAT)
pub const gl_unsigned_short = u32(C.GL_UNSIGNED_SHORT)
pub const gl_byte = u32(C.GL_BYTE)
pub const gl_unsigned_byte = u32(C.GL_UNSIGNED_BYTE)
pub const gl_short = u32(C.GL_SHORT)
pub const gl_unsigned_int = u32(C.GL_UNSIGNED_INT)
pub const gl_int = u32(C.GL_INT)
pub const double = u32(C.GL_DOUBLE)

// Other
pub const color_buffer_bit = u32(C.GL_COLOR_BUFFER_BIT)

// Error Codes
pub const no_error = u32(C.GL_NO_ERROR)
pub const invalid_enum = u32(C.GL_INVALID_ENUM)
pub const invalid_value = u32(C.GL_INVALID_VALUE)
pub const invalid_operation = u32(C.GL_INVALID_OPERATION)
pub const invalid_framebuffer_operation = u32(C.GL_INVALID_FRAMEBUFFER_OPERATION)
pub const out_of_memory = u32(C.GL_OUT_OF_MEMORY)

// Shader Types
pub const vertex_shader = u32(C.GL_VERTEX_SHADER)
pub const fragment_shader = u32(C.GL_FRAGMENT_SHADER)
pub const geometry_shader = u32(C.GL_GEOMETRY_SHADER)

// Shader Compile Status
pub const compile_status = u32(C.GL_COMPILE_STATUS)

// Shader Info Log Parameters
pub const info_log_length = u32(C.GL_INFO_LOG_LENGTH)
pub const shader_source_length = u32(C.GL_SHADER_SOURCE_LENGTH)

// Program Link Status
pub const link_status = u32(C.GL_LINK_STATUS)

// Program Info Log Parameters
pub const program_info_log_length = u32(C.GL_INFO_LOG_LENGTH)
pub const program_binary_length = u32(C.GL_PROGRAM_BINARY_LENGTH)
pub const attached_shaders = u32(C.GL_ATTACHED_SHADERS)
pub const active_attributes = u32(C.GL_ACTIVE_ATTRIBUTES)
pub const active_uniforms = u32(C.GL_ACTIVE_UNIFORMS)

// Buffer Types
pub const array_buffer = u32(C.GL_ARRAY_BUFFER)
pub const element_array_buffer = u32(C.GL_ELEMENT_ARRAY_BUFFER)
pub const uniform_buffer = u32(C.GL_UNIFORM_BUFFER)

// Buffer Usage Hints
pub const static_draw = u32(C.GL_STATIC_DRAW)
pub const dynamic_draw = u32(C.GL_DYNAMIC_DRAW)
pub const stream_draw = u32(C.GL_STREAM_DRAW)

// Texture Types
pub const texture_2d = u32(C.GL_TEXTURE_2D)
pub const texture_3d = u32(C.GL_TEXTURE_3D)
pub const texture_cube_map = u32(C.GL_TEXTURE_CUBE_MAP)

// Texture Parameters
pub const texture_min_filter = u32(C.GL_TEXTURE_MIN_FILTER)
pub const texture_mag_filter = u32(C.GL_TEXTURE_MAG_FILTER)
pub const texture_wrap_s = u32(C.GL_TEXTURE_WRAP_S)
pub const texture_wrap_t = u32(C.GL_TEXTURE_WRAP_T)

// Texture Filters
pub const nearest = u32(C.GL_NEAREST)
pub const linear = u32(C.GL_LINEAR)
pub const nearest_mipmap_nearest = u32(C.GL_NEAREST_MIPMAP_NEAREST)
pub const linear_mipmap_nearest = u32(C.GL_LINEAR_MIPMAP_NEAREST)
pub const nearest_mipmap_linear = u32(C.GL_NEAREST_MIPMAP_LINEAR)
pub const linear_mipmap_linear = u32(C.GL_LINEAR_MIPMAP_LINEAR)

// Framebuffer Targets
pub const framebuffer = u32(C.GL_FRAMEBUFFER)

// Framebuffer Attachments
pub const color_attachment0 = u32(C.GL_COLOR_ATTACHMENT0)
pub const depth_attachment = u32(C.GL_DEPTH_ATTACHMENT)
pub const stencil_attachment = u32(C.GL_STENCIL_ATTACHMENT)
pub const depth_stencil_attachment = u32(C.GL_DEPTH_STENCIL_ATTACHMENT)

// Draw Modes
pub const points = u32(C.GL_POINTS)
pub const line_strip = u32(C.GL_LINE_STRIP)
pub const line_loop = u32(C.GL_LINE_LOOP)
pub const lines = u32(C.GL_LINES)
pub const triangle_strip = u32(C.GL_TRIANGLE_STRIP)
pub const triangle_fan = u32(C.GL_TRIANGLE_FAN)
pub const triangles = u32(C.GL_TRIANGLES)

// General
fn C.glViewport(x int, y int, width int, height int)
fn C.glClear(mask u32)
fn C.glClearColor(r f32, g f32, b f32, a f32)
fn C.glEnable(cap u32)

// Buffers
fn C.glGenBuffers(n u32, buffers &u32)
fn C.glBindBuffer(target u32, buffer u32)
fn C.glBufferData(target u32, size isize, data voidptr, usage u32)
fn C.glDeleteBuffers(n u32, buffers &u32)
fn C.glMapBuffer(target u32, access u32) voidptr
fn C.glUnmapBuffer(target u32) bool

// Vertex
fn C.glGenVertexArrays(n int, arrays &u32)
fn C.glBindVertexArray(vao u32)
fn C.glDeleteVertexArrays(n int, arrays &u32)

// Vertex Attributes
fn C.glEnableVertexAttribArray(index u32)
fn C.glDisableVertexAttribArray(index u32)
fn C.glVertexAttribPointer(index u32, size int, typ u32, normalized u8, stride int, pointer voidptr)
fn C.glVertexAttribDivisor(index u32, divisor u32)

// Drawing
fn C.glDrawArrays(mode u32, first int, count int)
fn C.glDrawElements(mode u32, count int, typ u32, indices voidptr)
fn C.glDrawArraysInstanced(mode u32, first int, count int, instancecount int)
fn C.glDrawElementsInstanced(mode u32, count int, typ u32, indices voidptr, instancecount int)

// Shaders
fn C.glCreateShader(shader_type u32) u32
fn C.glDeleteShader(shader u32)
fn C.glCompileShader(shader u32)
fn C.glAttachShader(program u32, shader u32)
fn C.glDetachShader(program u32, shader u32)
fn C.glCreateProgram() u32
fn C.glDeleteProgram(program u32)
fn C.glLinkProgram(program u32)
fn C.glUseProgram(program u32)
fn C.glShaderSource(shader u32, count int, strings &&char, lengths &&int)
fn C.glGetShaderInfoLog(shader u32, max_length int, length &int, info_log &char)
fn C.glGetShaderiv(shader u32, pname u32, params &int)
fn C.glGetProgramInfoLog(program u32, max_length int, length &int, info_log &char)
fn C.glGetProgramiv(program u32, pname u32, params &int)

// Framebuffers
fn C.glGenFramebuffers(n u32, framebuffers &u32)
fn C.glBindFramebuffer(target u32, framebuffer u32)
fn C.glDeleteFramebuffers(n u32, framebuffers &u32)
fn C.glFramebufferTexture2D(target u32, attachment u32, textarget u32, texture u32, level int)
fn C.glCheckFramebufferStatus(target u32) u32

// Textures
fn C.glGenTextures(n u32, textures &u32)
fn C.glBindTexture(target u32, texture u32)
fn C.glDeleteTextures(n u32, textures &u32)
fn C.glTexImage2D(target u32, level int, internalformat int, width int, height int, border int, format u32, typ u32, pixels voidptr)
fn C.glTexParameteri(target u32, pname u32, param int)

// Error Handling
fn C.glGetError() u32

/*
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
*/
