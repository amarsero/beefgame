// SpaceGame is a Beef sample utilizing SDL2.
//
// Press F5 to compile and run.
//
// Beef supports "hot compilation", allowing code changes while a program is
// running. Try opening "Hero.bf" under "SpaceGame" in the Workspace panel on
// the left and modify one of the constants at the top of the file. Press
// F7 to compile and apply your changes while the game is running.
//
// Beef can detect memory leaks in real-time. Try commenting out the
// "delete entity" line at the bottom of "GameApp.bf".

using SDL2;
using System.Collections;
using SpaceGame.Math;
using System.IO;
using System;
using opengl_beef;

namespace SpaceGame
{
	class Program
	{
		const int width = 800;
		const int height = 600;
		static SDL.Window* window;
		static SDL.SDL_GLContext glContext;
		static List<Vec3> vertices;
		static uint32 vao = 0, vbo = 0;
		static uint shaderProgram = 0;
		public static void Main()
		{
			SDL.Init(SDL.InitFlag.Video);

			SDL.GL_SetAttribute(.GL_CONTEXT_MAJOR_VERSION, 3);
			SDL.GL_SetAttribute(.GL_CONTEXT_MAJOR_VERSION, 3);
			SDL.GL_SetAttribute(.GL_CONTEXT_PROFILE_MASK, SDL.SDL_GLProfile.GL_CONTEXT_PROFILE_CORE);
			window = SDL.CreateWindow("Title", .Centered, .Centered, width, height, SDL.WindowFlags.OpenGL);

			glContext = SDL.GL_CreateContext(window);
			SDL.SDL_GL_MakeCurrent(window, glContext);
			GL.Init( => SdlGetProcAddress);

			vertices = LoadOBJMesh("mustang.obj");
			for (Vec3 vec in vertices)
			{
				vec.x = vec.x * 0.01f;
				vec.y = vec.y * 0.01f;
				vec.z = vec.z * 0.01f;
			}
			SetupShaders();
			SetupMeshBuffers(vertices);

			Loop();

			CleanUp();
		}

		static void* SdlGetProcAddress(StringView string)
		{
			return SDL.SDL_GL_GetProcAddress(string.ToScopeCStr!());
		}

		struct Material
		{
			public String Name;
			public int Index;
			public Vec3 Diffuse;
			public Vec3 Ambient;
			public Vec3 Specular;
			public Vec3 Transmittance;
			public float IndexOfRefraction;
			public Vec3 Emission;
			public float Shininess;
			public uint8 IlluminationModel;
			public float Dissolve;
		}
		static Vec3 extractVec3(StringView line)
		{
			let firstSpaceIndex = line.IndexOf(" ");
			let parts = line.Substring(firstSpaceIndex).Split(' ');
			int index = 0;
			float[3] vals = .(0, 0, 0);
			for (let part in parts)
			{
				vals[index++] = float.Parse(part);
			}
			return Vec3(vals[0], vals[1], vals[2]);
		}
		struct Face
		{
			public float[4] ix = .(0, 0, 0, 0);
			public float[4] vt = .(0, 0, 0, 0);
			public float[4] vn = .(0, 0, 0, 0);
			public bool hasVertexTexture = false;
			public bool hasVertexNormal = false;
		}
		static List<Vec3> LoadOBJMesh(StringView filePath)
		{
			List<Vec3> vertices = scope List<Vec3>();
			List<Vec3> normals = scope List<Vec3>();
			List<Face> faces = scope List<Face>();
			List<Vec3> vertexTexture = scope List<Vec3>();
			List<Material> materials = scope List<Material>();
			Material* currentMaterial = null;

			let file = scope FileStream();
			if (file.Open(filePath) case .Err(let err))
			{
				String errBuf = scope String();
				err.ToString(errBuf);
				Console.WriteLine("ERROR: File not found {}\n{}", filePath, errBuf);
			}
			let reader = scope StreamReader(file);
			let line = scope System.String(1024);

			while (reader.ReadLine(line) case .Ok(let void))
			{
				if (line.StartsWith("v "))
				{
					vertices.Add(extractVec3(line));
				}
				else if (line.StartsWith("vn "))
				{
					normals.Add(extractVec3(line));
				}
				else if (line.StartsWith("vt "))
				{
					vertexTexture.Add(extractVec3(line));
				}
				else if (line.StartsWith("f "))
				{
					let parts = line.Substring(2).Split(' ');
					int index = 0;
					Face face = Face();

					for (let part in parts)
					{
						var subparts = part.Split("/");
						subparts.MoveNext();
						face.ix[index++] = int.Parse(subparts.Current);
						if (subparts.MoveNext())
						{
							if (subparts.Current.Length > 0)
							{
								face.hasVertexTexture = false;
								face.vt[index] = int.Parse(subparts.Current);
							}
							if (subparts.MoveNext())
							{
								if (subparts.Current.Length > 0)
								{
									face.hasVertexNormal = true;
									face.vn[index] = int.Parse(subparts.Current);
								}
							}
						}
					}
					faces.Add(face);
				}
				else if (line.StartsWith("mtllib "))
				{
					let matName = line.Substring(7);
				}
				else if (line.StartsWith("usemtl "))
				{
					// Uses the previous material on the current faces
					// Sets the new material
					let matName = line.Substring(7);
					let newMatIdx = materials.FindIndex(scope (x) => x.Name == matName);
					if (newMatIdx == -1)
					{
						let err = StackStringFormat!("ERROR: Material \"{}\" not found when parsing file {}\n", matName, filePath);
						Console.WriteLine(err);
						Runtime.FatalError(err);
					}
					Material* newMat = &materials[newMatIdx];
					if (newMat != currentMaterial)
					{
						FacesToShape();
					}
				}
				//Ends ifs from hellLLLLL
				line.Clear();
			}
			return vertices;
		}

		static void FacesToShape()
		{
			Runtime.FatalError("Pls implmeent dis");
		}

		static void LoadMtl(StringView filePath)
		{
			List<Material> materials = scope List<Material>();

			Material mat = Material();


			let file = scope FileStream();
			if (file.Open(filePath) case .Err(let err))
			{
				String errBuf = scope String();
				err.ToString(errBuf);
				Console.WriteLine("ERROR: File not found {}\n{}", filePath, errBuf);
			}
			let reader = scope StreamReader(file);
			let line = scope System.String(1024);

			while (reader.ReadLine(line) case .Ok(let void))
			{
				if (line.StartsWith("newmtl "))
				{
					// Flush previous material
					if (!mat.Name.IsEmpty)
					{
						mat.Index = materials.Count;
						materials.Add(mat);
					}
					line.Substring(7).ToString(mat.Name);
				}
				else if (line.StartsWith("Ka "))
				{
					mat.Ambient = extractVec3(line);
				}
				else if (line.StartsWith("Kd "))
				{
					mat.Diffuse = extractVec3(line);
				}
				else if (line.StartsWith("Ks "))
				{
					mat.Specular = extractVec3(line);
				}
				else if (line.StartsWith("Kt "))
				{
					mat.Transmittance = extractVec3(line);
				}
				else if (line.StartsWith("Ni "))
				{
					mat.IndexOfRefraction = float.Parse(line.Substring(3));
				}
				else if (line.StartsWith("Ke "))
				{
					mat.Emission = extractVec3(line);
				}
				else if (line.StartsWith("Ns "))
				{
					mat.Shininess = float.Parse(line.Substring(3));
				}
				else if (line.StartsWith("illum "))
				{
					mat.IlluminationModel = (uint8)UInt.Parse(line.Substring(6)).Value;
				}
				else if (line.StartsWith("d "))
				{
					mat.Dissolve  = float.Parse(line.Substring(2));
				}
				else if (line.StartsWith("Tr "))
				{
					mat.Dissolve  = 1 - float.Parse(line.Substring(3));
				}
				if (!mat.Name.IsEmpty)
				{
					mat.Index = materials.Count;
					materials.Add(mat);
				}
			}
		}
		static void SetupMeshBuffers(List<Vec3> vertex)
		{
			uint32 vao = 0, vbo = 0;
			GL.glGenVertexArrays(1, &vao);
			GL.glGenBuffers(1, &vbo);

			GL.glBindVertexArray(vao);
			GL.glBindBuffer(GL.GL_ARRAY_BUFFER, vbo);
			GL.glBufferData(GL.GL_ARRAY_BUFFER, vertices.Count * sizeof(float) * 3, vertices.Ptr, GL.GL_STATIC_DRAW);

			GL.glVertexAttribPointer(0, 3, GL.GL_FLOAT, GL.GL_FALSE, 3 * sizeof(float), null);
			GL.glEnableVertexAttribArray(0);


			GL.glUseProgram(shaderProgram);
			GL.glBindVertexArray(vao);

			GL.glVertexAttribPointer(0, 3, GL.GL_FLOAT, GL.GL_FALSE, 3 * sizeof(float), null);
			GL.glEnableVertexAttribArray(0);
		}
		static void SetupShaders()
		{
			let vertexShaderSource = @"""
#version 330 core

layout (location = 0) in vec3 aPosition;

void main()
{
gl_Position = vec4(aPosition, 1.0);
}
""";

			let fragmentShaderSource = @"""
#version 330 core

out vec4 FragColor;

void main()
{
FragColor = vec4(1.0, 0.5, 0.2, 1.0);
}
""";
			void ShaderSource(uint shaderId, String source)
			{
				GL.glShaderSource(shaderId, 1, &source.[Friend]mPtrOrBuffer, &source.[Friend]mLength);
			}
			uint vertexShader = GL.glCreateShader(GL.GL_VERTEX_SHADER);
			ShaderSource(vertexShader, vertexShaderSource);
			GL.glCompileShader(vertexShader);

			uint fragmentShader = GL.glCreateShader(GL.GL_FRAGMENT_SHADER);
			ShaderSource(fragmentShader, fragmentShaderSource);
			GL.glCompileShader(fragmentShader);

			shaderProgram = GL.glCreateProgram();
			GL.glAttachShader(shaderProgram, vertexShader);
			GL.glAttachShader(shaderProgram, fragmentShader);
			GL.glLinkProgram(shaderProgram);

			GL.glDetachShader(shaderProgram, vertexShader);
			GL.glDetachShader(shaderProgram, fragmentShader);
			GL.glDeleteShader(vertexShader);
			GL.glDeleteShader(fragmentShader);
			GL.glUseProgram(shaderProgram);
		}

		static void Loop()
		{
			bool quit = false;

			while (!quit)
			{
				SDL.Event e;
				while (SDL.PollEvent(out e) != 0)
				{
					if (e.type == SDL.EventType.Quit)
					{
						quit = true;
					}
				}

				GL.glViewport(0, 0, width, height);
				GL.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);

				GL.glDrawArrays(GL.GL_TRIANGLES, 0, vertices.Count);

				SDL.GL_SwapWindow(window);
			}
		}

		static void CleanUp()
		{
			GL.glDeleteVertexArrays(1, &vao);
			GL.glDeleteBuffers(1, &vbo);
			GL.glDeleteProgram(shaderProgram);
			SDL.GL_DeleteContext(glContext);
			SDL.DestroyWindow(window);
			delete vertices;
		}
		/*public static void Main()
		{
			let gameApp = scope GameApp();
			gameApp.PreInit();
			gameApp.Init();
			gameApp.Run();
		}*/
	}
}
