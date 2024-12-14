#include <SDL2/SDL.h>
#include <GL/glew.h>
#include <stdio.h>
#include <stdlib.h>

// Shader sources
const char *vertexShaderSource = "#version 330 core\n"
                                 "layout(location = 0) in vec3 aPos;\n"
                                 "layout(location = 1) in vec3 aColor;\n" // Color input
                                 "out vec3 fragColor;\n"                  // Color output to fragment shader
                                 "void main() {\n"
                                 "    gl_Position = vec4(aPos, 1.0);\n"
                                 "    fragColor = aColor;\n" // Pass color to fragment shader
                                 "}";

const char *fragmentShaderSource = "#version 330 core\n"
                                   "in vec3 fragColor;\n" // Color input from vertex shader
                                   "out vec4 FragColor;\n"
                                   "void main() {\n"
                                   "    FragColor = vec4(fragColor, 1.0);\n" // Output the color
                                   "}";

// Function to compile shaders and check for errors
GLuint compileShader(const char *shaderSource, GLenum shaderType)
{
    GLuint shader = glCreateShader(shaderType);
    glShaderSource(shader, 1, &shaderSource, NULL);
    glCompileShader(shader);

    // Check for compile errors
    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success)
    {
        GLint logLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
        char *infoLog = (char *)malloc(logLength);
        glGetShaderInfoLog(shader, logLength, NULL, infoLog);
        printf("ERROR: Shader compilation failed: %s\n", infoLog);
        free(infoLog);
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

// Function to link shaders into a program and check for errors
GLuint linkProgram(GLuint vertexShader, GLuint fragmentShader)
{
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);

    // Check for link errors
    GLint success;
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success)
    {
        GLint logLength;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
        char *infoLog = (char *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, NULL, infoLog);
        printf("ERROR: Program linking failed: %s\n", infoLog);
        free(infoLog);
        return 0;
    }
    return program;
}

int main(int argc, char *argv[])
{
    // Initialize SDL2
    if (SDL_Init(SDL_INIT_VIDEO) < 0)
    {
        printf("SDL_Init failed: %s\n", SDL_GetError());
        return -1;
    }

    // Create an SDL window
    SDL_Window *window = SDL_CreateWindow("OpenGL Window", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 600, SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
    if (!window)
    {
        printf("SDL_CreateWindow failed: %s\n", SDL_GetError());
        SDL_Quit();
        return -1;
    }

    // Create an OpenGL context
    SDL_GLContext glContext = SDL_GL_CreateContext(window);
    if (!glContext)
    {
        printf("SDL_GL_CreateContext failed: %s\n", SDL_GetError());
        SDL_DestroyWindow(window);
        SDL_Quit();
        return -1;
    }

    // Initialize GLEW
    if (glewInit() != GLEW_OK)
    {
        printf("GLEW initialization failed\n");
        SDL_GL_DeleteContext(glContext);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return -1;
    }

    // Vertex data for a triangle with colors
    float vertices[] = {
        // Positions        // Colors
        0.0f, 0.5f, 0.0f, 1.0f, 0.0f, 0.0f,   // Vertex 1 (Red)
        -0.5f, -0.5f, 0.0f, 0.0f, 1.0f, 0.0f, // Vertex 2 (Green)
        0.5f, -0.5f, 0.0f, 0.0f, 0.0f, 1.0f   // Vertex 3 (Blue)
    };

    // Compile shaders
    GLuint vertexShader = compileShader(vertexShaderSource, GL_VERTEX_SHADER);
    GLuint fragmentShader = compileShader(fragmentShaderSource, GL_FRAGMENT_SHADER);
    GLuint shaderProgram = linkProgram(vertexShader, fragmentShader);

    if (shaderProgram == 0)
    {
        printf("Failed to create shader program\n");
        SDL_GL_DeleteContext(glContext);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return -1;
    }

    // Set up vertex buffers and array objects
    GLuint VBO, VAO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void *)0); // Position
    glEnableVertexAttribArray(0);

    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void *)(3 * sizeof(float))); // Color
    glEnableVertexAttribArray(1);

    // Unbind buffers
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    // OpenGL settings
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f); // Black background

    // Main render loop
    int running = 1;
    while (running)
    {
        // Poll events
        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
            if (event.type == SDL_QUIT)
            {
                running = 0;
            }
        }

        int x, y;
        SDL_GetWindowSize(window, &x, &y);

        // Set the OpenGL viewport to match the window size
        glViewport(0, 0, x, y);

        // Clear the screen
        glClear(GL_COLOR_BUFFER_BIT);

        // Use the shader program and draw the triangle
        glUseProgram(shaderProgram);
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3); // Draw 3 vertices (triangle)
        glBindVertexArray(0);

        // Swap buffers
        SDL_GL_SwapWindow(window);
    }

    // Clean up
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteProgram(shaderProgram);

    // Destroy SDL resources
    SDL_GL_DeleteContext(glContext);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
