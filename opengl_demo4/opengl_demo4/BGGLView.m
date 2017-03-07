//
//  BGGLView.m
//  opengl_demo4
//
//  Created by apple on 3/7/17.
//  Copyright © 2017 bingo. All rights reserved.
//

#import "BGGLView.h"
#import <OpenGLES/ES3/gl.h>
@implementation BGGLView{
    
    EAGLContext * context;
    CAEAGLLayer * glLayer;
    
}
+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    glLayer = (CAEAGLLayer *)self.layer;
    //屏幕分辨率 @1x @2x @3x
    glLayer.contentsScale = [UIScreen mainScreen].scale;
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];
    
    
    GLuint renderBuffer;
    //参数1  表示生成1个renderBuffer
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:glLayer];
    
    GLint renderBufferWidth,renderBufferHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &renderBufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &renderBufferHeight);
    
    glViewport(0, 0, renderBufferWidth, renderBufferHeight);
    //配置帧缓冲区
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    
    
    //编写shader
    const GLchar*vertexShaderContent =
    "#version 300 es \n"
    "layout(location = 0) in vec3 position;\n"
    "void main() {"
    "    gl_Position = vec4(position.x,position.y,position.z,1.0);"
    "}";
    
    GLuint vertexShader = compileShader(vertexShaderContent, GL_VERTEX_SHADER);
    const GLchar* fragmentShader1Source = "#version 300 es \n"
    "precision highp float; "
    "out vec4 color;\n"
    "void main()\n"
    "{\n"
    "color = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
    "}\n\0";
    const GLchar* fragmentShader2Source = "#version 300 es\n"
    "precision highp float; "
    "out vec4 color;\n"
    "void main()\n"
    "{\n"
    "color = vec4(1.0f, 1.0f, 0.0f, 1.0f); // The color yellow \n"
    "}\n\0";
    
    
    //创建2个片段shader
    GLuint fragmentShaderOrange = compileShader(fragmentShader1Source, GL_FRAGMENT_SHADER);
    
    GLuint fragmentShaderYellow = compileShader(fragmentShader2Source, GL_FRAGMENT_SHADER);
    
    //创建2个program并链接
    GLuint shaderProgramOrange = glCreateProgram();
    glAttachShader(shaderProgramOrange, vertexShader);
    glAttachShader(shaderProgramOrange, fragmentShaderOrange);
    glLinkProgram(shaderProgramOrange);
    
    GLuint shaderProgramYellow = glCreateProgram();
    glAttachShader(shaderProgramYellow, vertexShader);
    glAttachShader(shaderProgramYellow, fragmentShaderYellow);
    glLinkProgram(shaderProgramYellow);
    
    
    //打印log
    GLint linkStatus;
    glGetProgramiv(shaderProgramOrange, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLint infoLength;
        glGetProgramiv(shaderProgramOrange, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength>0) {
            GLchar *infoLog = malloc(sizeof(GLchar)* infoLength);
            glGetProgramInfoLog(shaderProgramOrange, infoLength, NULL, infoLog);
            printf("%s\n",infoLog);
            free(infoLog);
        }
    }

    
    GLfloat firstTriangle[] = {
        -0.9f, -0.5f, 0.0f,  // Left
        -0.0f, -0.5f, 0.0f,  // Right
        -0.45f, 0.5f, 0.0f,  // Top
    };
    GLfloat secondTriangle[] = {
        0.0f, -0.5f, 0.0f,  // Left
        0.9f, -0.5f, 0.0f,  // Right
        0.45f, 0.5f, 0.0f   // Top
    };
    GLuint VBOs[2],VAOs[2];
    glGenVertexArrays(2, VAOs);
    glGenBuffers(2, VBOs);
    //设置第一个三角形
    glBindVertexArray(VAOs[0]);
    glBindBuffer(GL_ARRAY_BUFFER, VBOs[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(firstTriangle), firstTriangle, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), (GLvoid *)0);
    glEnableVertexAttribArray(0);
    glBindVertexArray(0);
    //第二个三角形
    glBindVertexArray(VAOs[1]);
    glBindBuffer(GL_ARRAY_BUFFER, VBOs[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(secondTriangle), secondTriangle, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), 0);
    glEnableVertexAttribArray(0);
    glBindVertexArray(0);
    
    
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    //使用第一个program
    glUseProgram(shaderProgramOrange);
    // Draw the first triangle using the data from our first VAO
    glBindVertexArray(VAOs[0]);
    glDrawArrays(GL_TRIANGLES, 0, 3);	// This call should output an orange triangle
    // Then we draw the second triangle using the data from the second VAO
    // When we draw the second triangle we want to use a different shader program so we switch to the shader program with our yellow fragment shader.
    //使用第二个program
    glUseProgram(shaderProgramYellow);
    glBindVertexArray(VAOs[1]);
    glDrawArrays(GL_TRIANGLES, 0, 3);	// This call should output a yellow triangle
    glBindVertexArray(0);
    
    //不是删除，该删除时会删除
    glDeleteVertexArrays(2, VAOs);
    glDeleteBuffers(2, VBOs);
    //交换帧
    [context presentRenderbuffer:GL_RENDERBUFFER];
    
}

GLuint compileShader(const GLchar*shaderContent, GLenum shaderType) {
    GLuint shader = glCreateShader(shaderType);
    glShaderSource(shader, 1, &shaderContent, NULL);
    glCompileShader(shader);
    //检查是否编译报错
    GLint compileStatus;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    if (compileStatus == GL_FALSE) {
        GLint infoLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength > 0) {
            GLchar *infoLog = malloc(sizeof(GLchar) * infoLength);
            glGetShaderInfoLog(shader, infoLength, NULL, infoLog);
            printf("%s -> %s\n", shaderType == GL_VERTEX_SHADER ? "vertex shader" : "fragment shader", infoLog);
            free(infoLog);
        }
    }
    return shader;
}
@end
