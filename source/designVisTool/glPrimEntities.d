module designVisTool.glPrimEntities;

import glamour.gl;
import glamour.vao: VAO;
import glamour.shader: Shader;
import glamour.vbo: Buffer, ElementBuffer;

import gl3n.linalg;
import gl3n.math;

class glBoxEntity{

    static immutable string example_program_src_ = `
        #version 120
        vertex:
        uniform mat4 MVP;
        attribute vec2 position;
        void main(void)
        {
           gl_Position = MVP * vec4(position, 0, 1);
        }
        fragment:
        void main(void)
        {
            gl_FragColor = vec4(0.3, 0.3, 0.3, 0.5);
        }
        `;

    float[] vertices;
    ushort[] indices;
    GLint position_;

    VAO vao_;
    Shader program_;
    Buffer vbo_;
    ElementBuffer ibo_;

    this()
    {
        vertices = [ -1.0, -1.0,  1.0, -1.0,  -1.0, 1.0,  1.0, 1.0];
        indices = [0, 1, 2, 3];

        // allocate 
        program_ = new Shader("example_program", example_program_src_);
        ibo_ = new ElementBuffer(indices);
        vbo_ = new Buffer(vertices);
        vao_ = new VAO();

        // this saves the attrib array
        vao_.bind();
          vbo_.bind();
          {
            auto loc = program_.get_attrib_location("position");
            glEnableVertexAttribArray(loc);
            glVertexAttribPointer(loc, 2, GL_FLOAT, GL_FALSE, 0, null);
            //glDisableVertexAttribArray(loc); // no
          }
          vbo_.unbind();
        vao_.unbind();
    }


    void draw(mat4 mvp)
    {
        //writeln("ent1 draw");
        program_.bind();
          // update mvp 
          program_.uniform("MVP", mvp);

          vao_.bind();
            vbo_.bind();
              ibo_.bind();

              glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, null);
           
              ibo_.unbind();
            vbo_.unbind();
          vao_.unbind();
        program_.unbind();
    }

    void close()
    {
        // free resources
        ibo_.remove();
        vbo_.remove();
        vao_.remove();
        program_.remove();
    }

}
