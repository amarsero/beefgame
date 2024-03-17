/*using System;
using System.Collections.Generic;
using System.IO;
using OpenGL;
using SDL2;

namespace SDL2_3D_Renderer
{
    class Program
    {
        const int WINDOW_WIDTH = 800;
        const int WINDOW_HEIGHT = 600;

        static IntPtr window;
        static IntPtr glContext;
        static uint vao, vbo;

        static void Main(string[] args)
        {
            InitSDL();
            CreateWindow();
            CreateGLContext();

            List<Vec3> vertices = LoadOBJMesh("path/to/your/mesh.obj");
            SetupMeshBuffers(vertices);

            RenderLoop();

            CleanUp();
            SDL.SDL_Quit();
        }

        static void InitSDL()
        {
            SDL.SDL_Init(SDL.SDL_INIT_VIDEO);
        }

        static void CreateWindow()
        {
            SDL.SDL_GL_SetAttribute(SDL.SDL_GLattr.SDL_GL_CONTEXT_MAJOR_VERSION, 3);
            SDL.SDL_GL_SetAttribute(SDL.SDL_GLattr.SDL_GL_CONTEXT_MINOR_VERSION, 3);
            SDL.SDL_GL_SetAttribute(SDL.SDL_GLattr.SDL_GL_CONTEXT_PROFILE_MASK, (int)SDL.SDL_GLprofile.SDL_GL_CONTEXT_PROFILE_CORE);

            window = SDL.SDL_CreateWindow("SDL2 3D Renderer", SDL.SDL_WINDOWPOS_CENTERED, SDL.SDL_WINDOWPOS_CENTERED,
				WINDOW_WIDTH, WINDOW_HEIGHT, SDL.SDL_WindowFlags.SDL_WINDOW_OPENGL);
        }

        static void CreateGLContext()
        {
            glContext = SDL.SDL_GL_CreateContext(window);
        }

        static void RenderLoop()
        {
            bool quit = false;

            while (!quit)
            {
                SDL.SDL_Event e;
                while (SDL.SDL_PollEvent(out e) != 0)
                {
                    if (e.type == SDL.SDL_EventType.SDL_QUIT)
                    {
                        quit = true;
                    }
                }

                GL.glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
                GL.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);

                GL.glBindVertexArray(vao);
                GL.glDrawArrays(GL.GL_TRIANGLES, 0, vertexCount);

                SDL.SDL_GL_SwapWindow(window);
            }
        }

        static void SetupMeshBuffers(List<Vec3> vertices)
        {
            vertexCount = vertices.Count;

            GL.glGenVertexArrays(1, out vao);
            GL.glGenBuffers(1, out vbo);

            GL.glglBindVertexArray(vao);
            GL.glglBindBuffer(GL.GL_ARRAY_BUFFER, vbo);
            GL.glBufferData(GL.GL_ARRAY_BUFFER, vertices.Count * sizeof(float) * 3, vertices.ToArray(), GL.GL_STATIC_DRAW);

            GL.glVertexAttribPointer(0, 3, GL.GL_FLOAT, GL.GL_FALSE, 3 * sizeof(float), IntPtr.Zero);
            GL.glEnableVertexAttribArray(0);
        }

        static void CleanUp()
        {
            GL.glDeleteVertexArrays(1, ref vao);
            GL.glDeleteBuffers(1, ref vbo);
            SDL.SDL_GL_DeleteContext(glContext);
            SDL.SDL_DestroyWindow(window);
        }

        static List<Vec3> LoadOBJMesh(string filePath)
        {
            // Same as previous implementation
        }

        struct Vec3
        {
            public float x, y, z;

            public Vec3(float x, float y, float z)
            {
                this.x = x;
                this.y = y;
                this.z = z;
            }
        }
    }
}*/