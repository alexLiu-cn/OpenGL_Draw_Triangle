//
//  MyGLView.m
//  FirstOpenGLDemo
//
//  Created by apple on 2/26/17.
//  Copyright © 2017 bingo. All rights reserved.
//

#import "MyGLView.h"
#import <OpenGLES/ES3/gl.h>

@interface MyGLView ()

@property (nonatomic, strong) EAGLContext *context;

@end

@implementation MyGLView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    
    if ([super initWithFrame:frame]) {
        
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        [EAGLContext setCurrentContext:self.context];
        
        printf("厂家 = %s\n",glGetString(GL_VENDOR));
        printf("渲染器 = %s\n", glGetString(GL_RENDERER));
        printf("ES版本 = %s\n", glGetString(GL_VERSION));
        printf("拓展功能 =>\n%s\n", glGetString(GL_EXTENSIONS));
        //渲染缓冲区
        GLuint renderBuffer;
        glGenRenderbuffers(1, &renderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
        
        [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        //帧缓冲区(由多个render Buffer组成,再次事例只绑定以个帧缓存)
        //将渲染缓冲区配置成帧缓冲区的颜色附着（Attachment）
        GLuint frameBuffer;
        glGenFramebuffers(1, &frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBuffer);
        //设置缓冲区清除颜色
        glClearColor(1.0, 0, 0.5, 1.0);
        //设置屏幕颜色（清除渲染缓冲区）
        //让OpenGL ES系统使用前面glClearColor指定的颜色刷一遍指定的缓冲区，这里是颜色缓冲区。
        glClear(GL_COLOR_BUFFER_BIT);
        //交换前后端缓冲区
        [self.context presentRenderbuffer:GL_RENDERBUFFER];
        
    }
    return self;
}

- (void)dealloc{
    //在结束OpenGL ES操作后，应该在dealloc或适当的地方做清理操作，即结束当前上下文的使用，具体表现为：
    if (self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
}


+ (Class)layerClass{
    
    return [CAEAGLLayer class];
}



@end
