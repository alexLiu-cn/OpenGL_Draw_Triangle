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
    "    gl_Position = vec4(position.x,position.y,position.z,1.0);\n"
    "}";
     GLuint vertexShader = compileShader(vertexShaderContent, GL_VERTEX_SHADER);
    
    char * fragmentShaderContent =
    "#version 300 es \n"
    "precision highp float; "
    "out vec4 fragColor; "
    "void main() { "
    "    fragColor = vec4(1.0, 0.5, 1.0, 1.0);"
    "}";
    
    GLuint fragmentShader = compileShader(fragmentShaderContent, GL_FRAGMENT_SHADER);
    
    //创建程序对象连接并执行
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);
    
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    //打印log
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
    
    GLfloat vertices[] = {
        -0.5f, -0.5f, 0.0f, // Left
        0.5f, -0.5f, 0.0f, // Right
        0.0f,  0.5f, 0.0f  // Top
    };
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
    
    //glBindBuffer(GL_ARRAY_BUFFER, 0); // Note that this is allowed, the call to glVertexAttribPointer registered VBO as the currently bound vertex buffer object so afterwards we can safely unbind
    
    glBindVertexArray(0); // Unbind VAO (it's always a good thing to unbind any buffer/array to prevent strange bugs)
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Draw our first triangle
    glUseProgram(program);
    glBindVertexArray(VAO);
    glDrawArrays(GL_TRIANGLES, 0, 3);
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
- (void)test{
    //必须调用
//    [super layoutSubviews];
    
    
    GLfloat vertices[] = {
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f,  0.5f, 0.0f
    };
    
    
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
    
    //NSLog(@"%d===%d",renderBufferWidth,renderBufferHeight);
    
    //配置帧缓冲区
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
    
    
    //创建VBO
    GLuint VBO;
    glGenBuffers(1, &VBO);
    //绑定到GL_ARRAY_BUFFER
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    //创建编译shader
    char  * vertexShaderContent =
    "#version 300 es \n"
    "layout(location = 0) in vec4 position; "
    "layout(location = 1) in float point_size; "
    "void main() { "
    "    gl_Position = position; "
    "    gl_PointSize = point_size;"
    "}";
    GLuint vertexShader = compileShader(vertexShaderContent, GL_VERTEX_SHADER);
    
    char * fragmentShaderContent =
    "#version 300 es \n"
    "precision highp float; "
    "out vec4 fragColor; "
    "void main() { "
    "    if (length(gl_PointCoord - vec2(0.5, 0.5)) > 0.5) { discard; }"
    "    fragColor = vec4(1.0, 0.5, 1.0, 1.0);"
    "}";
    
    GLuint fragmentShader = compileShader(fragmentShaderContent, GL_FRAGMENT_SHADER);
    //创建程序容器连接并执行
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);
    
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    //打印log
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
    
    //使用后记得删除，我们不在需要了
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    glEnable(GL_BLEND);//启用色彩混合
    //像素可以通过函数操作后被绘出，该函数的功能是将引入的值与颜色缓冲中已有的值混合。使用glEnable方法与glDisable方法以GL_BLEND为参数，决定是否开启混合功能，该功能初始为关闭的。
    //指定source颜色像素和dest目标颜色像素
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //前一个函数设置好清除颜色，后者利用前一个函数设置好的当前清除颜色设置窗口颜色
    glClearColor(1, 1, 0.2, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, renderBufferWidth, renderBufferHeight);
    
    
    GLfloat vertex[2];
    GLfloat size[] = {50.f};
    for(GLfloat i = -0.9;i<=1.0;i += 0.25f,size[0] += 20){
        
        vertex[0] = i;
        vertex[1] = 0.f;
        
        //真正的渲染出去==发起OpenGL调用来请求渲染你的对象
        //一个新建的VAO的所有属性访问都是disable的。而开启一个属性是通过下面的函数
        glEnableVertexAttribArray(0);
        //绑定下标  参数1：0表示 location定义的点
        glVertexAttribPointer(0, 3/*左标分量个数 */, GL_FLOAT, GL_FALSE, 3*sizeof(0), vertex);
        
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 1, GL_FLOAT, GL_FALSE, 0, size);
        
        glDrawArrays(GL_POINTS, 0, 1);
        //第二个参数指定了顶点数组的起始索引   参数3指定我们打算绘制多少个顶点，这里是1
    }
    [context presentRenderbuffer:GL_RENDERBUFFER];
}


@end
