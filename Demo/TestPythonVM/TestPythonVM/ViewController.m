//
//  ViewController.m
//  TestPythonVM
//
//  Created by zxl on 2021/8/27.
//

#import "ViewController.h"
#include "Python.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self SetPyHomePath];
    [self RunSimplePyString];
}

-(void)SetPyHomePath{
    NSString* path=[[NSBundle mainBundle] resourcePath];
    NSString* tmp=@"/python.framework";
    NSString* p_pythonFrameworkPath=[path stringByAppendingString:tmp];
    const char * frameworkPath = [[NSString stringWithFormat:@"%@/Resources",p_pythonFrameworkPath] UTF8String];
    wchar_t  *pythonHome = Py_DecodeLocale(frameworkPath, NULL);
    Py_SetPythonHome(pythonHome);
}

-(void) RunSimplePyString{
    Py_Initialize();
    PyRun_SimpleString("print('python run successfully')");
    Py_Finalize();
}

@end
