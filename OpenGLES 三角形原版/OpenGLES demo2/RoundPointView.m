//
//  RoundPointView.m
//  OpenGLES demo2
//
//  Created by apple on 2/27/17.
//  Copyright © 2017 bingo. All rights reserved.
//

#import "RoundPointView.h"
#import <CoreImage/CoreImage.h>
@interface RoundPointView ()


@end


@implementation RoundPointView{
    CAEAGLLayer *glLayer;
    EAGLContext *context;
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews{
    //必须调用
    [super layoutSubviews];
    
    glLayer = (CAEAGLLayer *)self.layer;
    //屏幕分辨率 @1x @2x @3x
    glLayer.contentsScale = [UIScreen mainScreen].scale;
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:context];

    //配置渲染缓冲区
    GLuint renderBuffer;
    //生成一个对象的name,而name就是这个对象的引用
    glGenRenderbuffers(1, &renderBuffer);

    //绑定到context上
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:glLayer];
    
    GLint renderBufferWidth,renderBufferHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &renderBufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &renderBufferHeight);
    
    
    glViewport(0, 0, renderBufferWidth, renderBufferHeight);
    
    //NSLog(@"%d===%d",renderBufferWidth,renderBufferHeight);
    
    //配置帧缓冲区
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    

    //创建编译shader
    char  * vertexShaderContent =
    "#version 300 es \n"
    "layout(location = 0) in vec3 position;\n"
    "void main() { \n"
    "    gl_Position = vec4(position,1.0);\n"
    "}";
     GLuint vertexShader = compileShader(vertexShaderContent, GL_VERTEX_SHADER);
    
    char * fragmentShaderContent =
    "#version 300 es \n"
    "precision highp float; "
//    "uniform vec4 ourColor;"
    "out vec4 fragColor; "
    "void main() { "
    "    fragColor = vec4(0.5,0.4,0.2,1.0);"
    "}";
    
    GLuint fragmentShader = compileShader(fragmentShaderContent, GL_FRAGMENT_SHADER);
    
    //创建程序对象连接并执行
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);
    
    //打印log
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLint infoLength;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength>0) {
            GLchar *infoLog = malloc(sizeof(GLchar)* infoLength);
            glGetProgramInfoLog(program, infoLength, NULL, infoLog);
            printf("%s\n",infoLog);
            free(infoLog);
        }
    }
    glUseProgram(program);
    
    //不是删除，该删除时会删除
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
//    GLfloat vertices[] = {
//        -0.5f, -0.5f, 0.0f, // Left
//        0.5f, -0.5f, 0.0f, // Right
//        0.0f,  0.5f, 0.0f  // Top
//    };
    
    GLfloat vertices[] = {
        //// 位置
        0.0f, 0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
    };
    
    //申请内存
    GLuint VBO, VAO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    // Bind the Vertex Array Object first, then bind and set vertex buffer(s) and attribute pointer(s).
    //1、绑定VAO
    glBindVertexArray(VAO);
    //2、 把顶点数组复制到缓冲中供OpenGL使用
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    //3、设置顶点属性指针
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);

    //4、解绑VAO
    glBindVertexArray(0); // Unbind VAO (it's always a good thing to unbind any buffer/array to prevent strange bugs)

    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Draw our first triangle
    glUseProgram(program);
    
    //给uniform赋值
//    GLfloat timeValue = 30;
//    GLfloat greenValue = (sin(timeValue) / 2) + 0.5;
//    GLint vertexColorLocation = glGetUniformLocation(program, "ourColor");
//    glUniform4f(vertexColorLocation, 0.5f, greenValue, 0.0f, 1.0f);
    
    
    glBindVertexArray(VAO);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    //glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    glBindVertexArray(0);
    
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    [context presentRenderbuffer:GL_RENDERBUFFER];

    

}





GLuint compileShader(char *shaderContent, GLenum shaderType) {
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

- (void)dealloc{
    
    [EAGLContext setCurrentContext:nil];
    
}

@end
