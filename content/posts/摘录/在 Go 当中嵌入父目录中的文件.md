---
date: 2022-01-06
tags: 
  - Golang
categories: 
  - 开发
  - 转载
  
toc: false
draft: false
showFullContent: false
readingTime: true
hideComments: true
---

>原文地址 [www.ixiqin.com](https://www.ixiqin.com/2022/10/02/in-the-embedded-in-the-parent-directory-of-the-file/)

自 Go 1.16 版本开始，Go 提供了将二进制文件打包进入到 Binary 文件当中的机制:`//go:embed`。

不过，我看到的示例大多数都是嵌入当前文件夹下的子文件夹的示例。并没有嵌入父一级文件夹的示例。于是，我便开始研究起来。

在 template 目录下创建了一个 `embed.go` 文件，并添加了如下代码。

```
package template

import "embed"

//go:embed *
var TemplateFs embed.FS

```

**并在另外一个文件当中使用`template.TemplateFs.ReadFile("index.tmpl")` 来完成模板文件的引用。**
