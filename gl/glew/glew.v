module glew

pub const ok = u32(C.GLEW_OK)

fn C.glewInit() int

// Initialize GLEW and return whether it was successful
pub fn init_glew() int {
	return C.glewInit()
}
