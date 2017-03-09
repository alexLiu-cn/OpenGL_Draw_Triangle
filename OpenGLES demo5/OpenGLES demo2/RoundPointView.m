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

    //顶点属性上限
    GLint nrAttributes;
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
    NSLog(@"==%d",nrAttributes);
    
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
    //着色器之间的传值
    char  * vertexShaderContent =
    "#version 300 es \n"
    "layout(location = 0) in vec3 position;\n"
    "out vec4 vertexColor;"
    "void main() { \n"
    "    gl_Position = vec4(position.x,position.y,position.z,1.0);\n"
    "    vertexColor = vec4(0.5f, 0.0f, 0.0f, 1.0f); "
    "}";
     GLuint vertexShader = compileShader(vertexShaderContent, GL_VERTEX_SHADER);
    
    char * fragmentShaderContent =
    "#version 300 es \n"
    "precision highp float; "
    "uniform vec4 ourColor;"
    "out vec4 fragColor; "
    "void main() { "
    "    fragColor = ourColor;"
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
        0.5f, 0.5f, 0.0f,   // 右上角
        0.5f, -0.5f, 0.0f,  // 右下角
        -0.5f, -0.5f, 0.0f, // 左下角
        -0.5f, 0.5f, 0.0f   // 左上角
    };
    GLuint indices[] = { // 注意索引从0开始!
        0, 1, 3, // 第一个三角形
        1, 2, 3  // 第二个三角形
    };
    
    //申请内存
    GLuint EBO;
    glGenBuffers(1, &EBO);
    GLuint VBO, VAO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    // Bind the Vertex Array Object first, then bind and set vertex buffer(s) and attribute pointer(s).
    //1、绑定VAO
    glBindVertexArray(VAO);
    //2、 把顶点数组复制到缓冲中供OpenGL使用
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    //3、复制索引数组到一个索引缓存
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    //4、设置顶点属性指针
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);
    
    //glBindBuffer(GL_ARRAY_BUFFER, 0); // Note that this is allowed, the call to glVertexAttribPointer registered VBO as the currently bound vertex buffer object so afterwards we can safely unbind
    //4、解绑VAO
    glBindVertexArray(0); // Unbind VAO (it's always a good thing to unbind any buffer/array to prevent strange bugs)
    
    
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Draw our first triangle
    glUseProgram(program);
    
    
    //给uniform全局变量设置值
    GLint vertexUniformLocation = glGetUniformLocation(program, "ourColor");
    glUniform4f(vertexUniformLocation, 0.4, 0.5, 0.8, 1.0);
    
    
    glBindVertexArray(VAO);
//    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
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
