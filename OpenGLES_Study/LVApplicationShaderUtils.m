//
//  LVApplicationShaderUtils.m
//  OpenGLES_Study
//
//  Created by LV on 16/1/1.
//  Copyright © 2016年 Wieye. All rights reserved.
//


#import "LVApplicationShaderUtils.h"
#import <OpenGLES/ES2/glext.h>
@implementation LVApplicationShaderUtils

+ (GLuint)compileShader:(NSString *)shaderFileName withType:(GLenum)shaderType
{
    NSString * shaderName = [[shaderFileName lastPathComponent] stringByDeletingPathExtension];
    NSString * shaderFileType = [shaderFileName pathExtension];
    //NSLog(@"文件名称：%@ 文件类型：%@",shaderName,shaderFileType);
    
    //!> 1
    NSString * shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:shaderFileType];
    //NSLog(@"文件路径：%@",shaderPath);
    
    NSError * error = nil;
    NSString * shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderPath)
    {
        NSLog(@"错误加载shader(%@):%@",shaderFileName,error.localizedDescription);
        return 0;
    }
    
    //!> 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    //!> 3
    const char * shaderStringUTF8 = [shaderString UTF8String];
    GLint shaderStringLength = (GLint)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    //!> 4
    glCompileShader(shaderHandle);
    
    //!> 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE)
    {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString * messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"错误编译shader(%@)：%@",shaderFileName,messageString);
        return 0;
    }
    
    return shaderHandle;
}


+ (int)createProgramWithVertexShaderFileName:(NSString *)vertexShaderFileName
                            fragmentShaderFileName:(NSString *)fragmentShaderFileName
{
    //!> 1
    GLuint vertexShader   = [self compileShader:vertexShaderFileName withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:fragmentShaderFileName withType:GL_FRAGMENT_SHADER];
    if ((vertexShader == 0)||(fragmentShader == 0))
    {
        NSLog(@"错误：错误编译Shaders,vertexShader:%d fragmentShader:%d",vertexShader,fragmentShader);
        return compileProgramErrorShaders;
    }
    
    //!> 2
    GLuint programHandle = glCreateProgram();
    if (programHandle == 0)
    {
        NSLog(@"错误：不能创建Program object");
        return compileProgramErrorProgram;
    }
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    //!>3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE)
    {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString * messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"Error link Shaders:%@",messageString);
        return compileProgramErrorLink;
    }
    return programHandle;
}

@end
