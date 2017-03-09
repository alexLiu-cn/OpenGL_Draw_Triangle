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
    "layout(location = 1) in vec3 color;"
    "layout(location = 2) in vec2 texCoord;"
    
    "out vec3 ourColor;"
    "out vec2 TexCoord;"
    
    "void main() { \n"
    "    gl_Position = vec4(position,1.0);\n"
    "    ourColor = color;"
    "    TexCoord = vec2(texCoord.x,(1.0f - texCoord.y));"
    "}";
     GLuint vertexShader = compileShader(vertexShaderContent, GL_VERTEX_SHADER);
    
    char * fragmentShaderContent =
    "#version 300 es \n"
    "precision highp float; "
    "in vec3 ourColor;"
    "in vec2 TexCoord;"
    "out vec4 fragColor; "
    "uniform sampler2D ourTexture;"
    "uniform sampler2D ourTexture2;"
    "void main() { "
    "    fragColor = mix(texture(ourTexture,TexCoord),texture(ourTexture2,TexCoord),0.2);"
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
    
//    GLfloat vertices[] = {
//        0.5f, 0.5f, 0.0f,   // 右上角
//        0.5f, -0.5f, 0.0f,  // 右下角
//        -0.5f, -0.5f, 0.0f, // 左下角
//        -0.5f, 0.5f, 0.0f   // 左上角
//    };
    GLfloat vertices[] = {
        // Positions          // Colors           // Texture Coords
        0.5f,  0.5f, 0.0f,   0.5f, 0.3f, 0.0f,   2.0f, 2.0f, // Top Right
        0.5f, -0.5f, 0.0f,   0.4f, 1.0f, 0.0f,   2.0f, 0.0f, // Bottom Right
        -0.5f, -0.5f, 0.0f,   0.4f, 0.0f, 1.0f,   0.0f, 0.0f, // Bottom Left
        -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 2.0f  // Top Left
    };
    
    GLuint indices[] = { // 注意索引从0开始!
        0, 1, 3, // 第一个三角形
        1, 2, 3  // 第二个三角形
    };
    //申请内存
    GLuint EBO,VBO, VAO;
    glGenBuffers(1, &EBO);
    glGenBuffers(1, &VBO);
    glGenVertexArrays(1, &VAO);
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
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray(0);
    
    //颜色属性
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
    
    //纹理属性
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 *sizeof(GLfloat), (GLvoid*)(6 * sizeof(GLfloat)));
    glEnableVertexAttribArray(2);
    
    //4、解绑VAO
    glBindVertexArray(0); // Unbind VAO (it's always a good thing to unbind any buffer/array to prevent strange bugs)
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"container.jpg" ofType:nil];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    CGImageRef imageRef = [image CGImage];
    float width = CGImageGetWidth(imageRef);
    float height = CGImageGetHeight(imageRef);
    CGDataProviderRef  provider = CGImageGetDataProvider(imageRef);
    CFDataRef textureDataRef = CGDataProviderCopyData(provider);
    const unsigned char *pixels = CFDataGetBytePtr(textureDataRef);
    
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"awesomeface.png" ofType:nil];
    UIImage *image2 = [UIImage imageWithContentsOfFile:path2];
    CGImageRef imageRef2 = [image2 CGImage];
    float width2 = CGImageGetWidth(imageRef2);
    float height2 = CGImageGetHeight(imageRef2);
    CGDataProviderRef  provider2 = CGImageGetDataProvider(imageRef2);
    CFDataRef textureDataRef2 = CGDataProviderCopyData(provider2);
    const unsigned char *pixels2 = CFDataGetBytePtr(textureDataRef2);
    
    
    //对齐像素字节函数  4字节
//    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    //纹理1
    GLuint texture,texture2;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    //GL_REPEAT  GL_MIRRORED_REPEAT  GL_CLAMP_TO_EDGE  GL_CLAMP_TO_BORDER
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
    //放大附近（像素化）、缩小使用线性（平滑）
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    //注意使用GL_RGBA 否则是黑白图片
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    //多级渐远纹理
    glGenerateMipmap(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, 0);
    

    //纹理2
    glGenTextures(1, &texture2);
    glBindTexture(GL_TEXTURE_2D, texture2);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
    //放大附近（像素化）、缩小使用线性（平滑）
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width2, height2, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels2);
    glGenerateMipmap(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    // Draw our first triangle
    glUseProgram(program);
    
    //激活纹理
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(glGetUniformLocation(program, "ourTexture"),0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture2);
    glUniform1i(glGetUniformLocation(program, "ourTexture2"), 1);
    
    
    glBindVertexArray(VAO);
//    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    glBindVertexArray(0);
//    glBindTexture(GL_TEXTURE_2D, 0);
    
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
