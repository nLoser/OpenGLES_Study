//
//  OpenGLView.h
//  OpenGLES_Study
//
//  Created by LV on 15/12/31.
//  Copyright © 2015年 Wieye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface OpenGLView : UIView
{
    /**
     *  基本准备OpenGL画布
     */
    CAEAGLLayer * _eaglLayer;
    EAGLContext * _context;
    GLuint _colorRenderBuffer;  //!> _context下的渲染缓冲
    GLuint _frameBuffer;        //!> _context下的帧缓冲
    
    
    /**
     *  Shaders着色器
     */
    GLuint _depthRenderBuffer;
    
    GLuint shaderProgramID;
    
    GLint _positionSlot;
    GLint _colorSlot;
    GLint _projectionUniform;
    GLint _modelViewUniform;
}

@end
