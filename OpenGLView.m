// https://developer.apple.com/library/ios/documentation/OpenGLES/Reference/EAGLContext_ClassRef/index.html
//  OpenGLView.m
//  OpenGLES_Study
//
//  Created by LV on 15/12/31.
//  Copyright © 2015年 Wieye. All rights reserved.
//

#import "OpenGLView.h"
#import "Cocos3DMathLib/CC3GLMatrix.h"
#import "LVApplicationShaderUtils.h"

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {1, 0, 0, 1}},
    {{-1, 1, 0}, {0, 1, 0, 1}},
    {{-1, -1, 0}, {0, 1, 0, 1}},
    {{1, -1, -1}, {1, 0, 0, 1}},
    {{1, 1, -1}, {1, 0, 0, 1}},
    {{-1, 1, -1}, {0, 1, 0, 1}},
    {{-1, -1, -1}, {0, 1, 0, 1}}
};

const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 7, 6,
    // Left
    2, 7, 3,
    7, 6, 2,
    // Right
    0, 4, 1,
    4, 1, 5,
    // Top
    6, 2, 1,
    1, 6, 5,
    // Bottom
    0, 3, 7,
    0, 7, 4    
};

@interface OpenGLView ()
{
    float _currentRotation;
    CADisplayLink * displayLink;
}
@end

@implementation OpenGLView

//!> 1.设置layer class 为 CAEAGLayer
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//!> 2.设置layer为Opaque
- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
}

//!> 3.创建OpenGL context
- (void)setupContext
{
    //!> 渲染上下文提供的 OpenGL ES 的版本
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context)
    {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    if (![EAGLContext setCurrentContext:_context])
    {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

//!> 4.创建render buffer(渲染缓冲区)
- (void)setupRenderBuffer
{
    // generate renderbuffer object names
    glGenRenderbuffers(1, &_colorRenderBuffer);
    // bind a renderbuffer to a renderbuffer target
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

//!> 5.创建一个frame buffer(帧缓冲区)
- (void)setupFrameBuffer
{
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

//!> 6.渲染屏幕
- (void)render
{
//    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);//ClearBufferMask
    glEnable(GL_DEPTH_TEST);
    
    //!> 后面添加的
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 4.f * self.frame.size.height / self.frame.size.width;
    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:4 andFar:10];
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake(sin(CACurrentMediaTime()), 0, -7)];
    _currentRotation += displayLink.duration * 90;
    [modelView rotateBy:CC3VectorMake(_currentRotation, _currentRotation, 0)];
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);

    // 1
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    // 2
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) *3));
    // 3
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

//!> 创建Shaders
- (void)initShaders
{
    shaderProgramID = [LVApplicationShaderUtils createProgramWithVertexShaderFileName:@"Simple.vertsh" fragmentShaderFileName:@"Simple.fragsh"];
    if (shaderProgramID > 0)
    {
        glUseProgram(shaderProgramID);
        
        _positionSlot = glGetAttribLocation(shaderProgramID, "Position");
        _colorSlot = glGetAttribLocation(shaderProgramID, "SourceColor");
        
        _projectionUniform = glGetUniformLocation(shaderProgramID, "Projection");
        _modelViewUniform = glGetUniformLocation(shaderProgramID, "Modelview");
        
        glEnableVertexAttribArray(_positionSlot);
        glEnableVertexAttribArray(_colorSlot);
    }
}

//!>  定义一个setupVBOs：
- (void)createVertexBuffers
{
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
}

- (void)setupDepthBuffer
{
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}

- (void)setupDisplayLink
{
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

//!> 实际操作
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupLayer];
        [self setupContext];
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self initShaders];
        [self createVertexBuffers];
        [self setupDisplayLink];
    }
    return self;
}

- (void)dealloc
{
    _context = nil;
    
}

@end
