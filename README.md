# Python-on-iOS

本Demo完成了将python解释器放到ios上运行,Demo运行方式：

直接打开Python-on-iOS\Demo\TestPythonVM 里的xcodeproj文件，里面有2个.a文件需要自行生成，生成方式如下：

1.打开目录Python-on-iOS\python-apple-support。

2.在该目录下命令行运行make -iOS 即可生成2个.a文件，把路径添加到Demo里就可以了。





## 参考文献：

交叉编译参考项目：https://github.com/beeware/Python-Apple-support
cpython仓库：https://github.com/python/cpython
cpython源码指南：https://realpython.com/cpython-source-code-guide/#whats-in-the-source-code
Makefile简明教程：https://fanzheng.org/archives/43
Python 模块索引：https://docs.python.org/zh-cn/3.9/py-modindex.html
