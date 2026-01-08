---
title: 将 Mac或Linux计算机加入到 Synology LDAP 目录服务
date: 2022-12-12
tags: 
  - LDAP
  - macOS
  - Linux
  - 群晖
categories: 
  - 开发
  - 转载

description: 

toc: false
draft: false
showFullContent: false
readingTime: true
hideComments: false
---



> 原文地址 [www.cdaten.com](https://www.cdaten.com/news/html/2700.html)

1. 将 Mac/Linux 客户端计算机加入到 Synology 的 LDAP Server（以前称为 Directory Server）。  
2. 为 LDAP 用户配置主目录文件夹的位置。  使用 autofs 可执行文件映射将主目录文件夹自动装载到 NFS 服务器（例如 Synology NAS）。  

# 使用 LDAP 用户凭据登录 macOS  
  
## 1. 开始之前的准备  
从 DSM 套件中心下载并安装 LDAP Server 套件。  
Mac：Mac OS X 10.6 或更高版本。  
Linux：提供各种开源 LDAP 解决方案，用于将 Linux 计算机绑定到 LDAP Server。  


## 2. 将 Mac 客户端绑定到 LDAP Server  

打开目录实用工具。

![|400](http://www.cdaten.com/news/pics/20210926/202109261632644872373.png)

选择 LDAPv3，然后单击左下角的铅笔图标以编辑设置。

![](http://www.cdaten.com/news/pics/20210926/202109261632644898928.png)

单击铅笔图标后，会弹出一个对话框。按顺序执行以下操作：  
单击新建。  
在服务器名称或 IP 地址栏中，输入托管 LDAP Server 的 Synology NAS 的名称或 IP 地址。然后在 LDAP 映射下拉菜单中选择打开目录。如果弹出消息提示您输入搜索 DN 后缀，请单击确定。  
单击确定。

![](http://www.cdaten.com/news/pics/20210926/202109261632644922663.png)

==返回到 “目录实用工具” 窗口后，单击搜索策略，在搜索路径下拉菜单中选择自定义路径，然后单击 +。==

![](http://www.cdaten.com/news/pics/20210926/202109261632644942080.png)

单击添加，然后在新对话框中添加帐户系统 “/LDAPv3/Synology NAS 的 IP 地址或域名”，以从 LDAP 数据库中搜索并检索 LDAP 用户和群组的信息。

![](http://www.cdaten.com/news/pics/20210926/202109261632644961999.png)

在 “目录实用工具” 窗口中单击应用以应用设置。  
返回到用户和组偏好设置窗格中的登录选项。按顺序执行以下操作：  
检查网络帐户服务器旁边是否显示绿灯。绿灯表示 Mac 已成功绑定到 LDAP Server。如果 Mac 已加入多个网络帐户服务器，请单击编辑并检查指示灯是否保持为绿色。  
在登录窗口显示为部分中选择名称和密码。  
**选中允许网络用户在登录窗口中登录。**

![|400](http://www.cdaten.com/news/pics/20210926/202109261632644974858.png)

现在您已成功将 Mac 绑定到 LDAP Server。 

## 3. 为 LDAP 用户创建 Mac/Linux 客户端的主目录文件夹  
使用 autofs 可执行文件映射，可将所有 LDAP 用户的主目录文件夹自动装载到 NFS 服务器。此外，您无需手动创建用户的主目录文件夹，用户名已更改时也无需重命名主目录文件夹。

### 3.1 使用 autofs 可执行文件映射

Autofs 可执行文件映射用于在 LDAP 用户登录时自动装载主目录文件夹。您可以在附录中找到它。请修改以下设置以使其与 LDAP 服务器匹配。

![](http://www.cdaten.com/news/pics/20210926/202109261632645030354.png)

如果要将 TLS 或 SSL 用于 LDAP 连接，请先从 LDAP 服务器导出证书并将其添加到客户端计算机。有关详细信息，请参阅使用 TLS 或 SSL。

### 3.2 对于 Linux 客户端

我们以 Ubuntu 12.04 为例。实际步骤可能因操作系统版本和 Linux 发行版而略有不同：

通过以下命令安装 autofs：  
apt-get install autofs5  
将包含所修改的 autofs 可执行文件映射的文件重命名为 auto.syno，然后将其放入 /etc 文件夹。  
在 /etc/auto.master 的 auto.master 文件中添加以下代码行：  
/home program:/etc/auto.syno  
添加代码行后，执行 restart autofs 命令。  
现在，您可以作为 LDAP 用户登录到 Ubuntu，并让主目录文件夹通过 NFS 自动装载到 /home 下。  
### 3.3 对于 Mac 客户端

此处我们以 macOS 10.15 Catalina 为例。实际步骤可能因操作系统版本而略有不同。

将包含所修改的 autofs 可执行文件映射的文件重命名为 auto_syno，然后将其放入 /etc 文件夹。  
在 /etc/auto_master 的 auto_master 文件中添加以下代码行：  
/home auto_syno -nobrowse,hidefromfinder  
从 auto_master 中删除以 “+” 开头的代码行（目录的规则）。  
执行 automount -vc 命令。  
现在，您可以作为 LDAP 用户登录到 Mac，并让主目录文件夹通过 NFS 自动装载到 /home 下。  
### 3.4 使用 TLS 或 SSL

若要将 TLS 或 SSL 用于 LDAP 连接 (ldaps://...)，您必须找到客户端计算机的证书，该证书在 Ubuntu 的 /etc/ldap/ldap.conf 或 Mac 的 /etc/openldap/ldap.conf 中指定。ldap.conf 文件可能包含以下代码行：

tls_cacert /etc/ssl/certs/ca-certificates.crt  
此代码行表示您必须将 Synology NAS 的证书存储到 /etc/ssl/certs/ca-certificates.crt。

### 3.5 附录：autofs 可执行文件映射

您可以使用以下 autofs 可执行文件映射，并按照说明根据需求调整其内容。

![](http://www.cdaten.com/news/pics/20210926/202109261632645310083.png)  

-------
注：

如果您将 Synology NAS 用作随 LDAP 主目录文件夹一起装载的 NFS 服务器，请注意以下条件：  
- 如果 Synology NAS 加入另一个 LDAP 目录，则主目录文件夹之间可能会出现冲突。  
- 如果 Synology NAS 加入同一个 LDAP 目录，则 LDAP 用户登录时会导致创建或重命名主目录文件夹。  
- LDAP Server 不支持 Windows Active Directory (AD) 域，因此，如果您的 Windows PC 已经是 LDAP 客户端，则无法加入方位 AD 域。

