//
//  LVApplicationShaderUtils.h
//  OpenGLES_Study
//
//  Created by LV on 16/1/1.
//  Copyright © 2016年 Wieye. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,compileProgramError)
{
    compileProgramErrorShaders = -1101,  //!> Shader创建失败
    compileProgramErrorProgram = -1102,  //!> Program object 创建失败
    compileProgramErrorLink    = -1103   //!> link 失败
};

@interface LVApplicationShaderUtils : NSObject

+ (int)createProgramWithVertexShaderFileName:(NSString *)vertexShaderFileName
                            fragmentShaderFileName:(NSString *)fragmentShaderFileName;

@end
