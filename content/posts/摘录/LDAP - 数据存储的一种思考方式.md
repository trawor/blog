---
title: LDAP - 数据存储的一种思考方式
date: 2022-09-11
tags: 
  - LDAP
  - 开发
  - 转载
  
toc: false
draft: false
showFullContent: false
readingTime: true
hideComments: true
---

> 原文地址 [blog.csdn.net](https://blog.csdn.net/lucifer821031/article/details/1920814)

### (1) 什么是 LDAP

LDAP, Lightweight Directory Access Protocol, 轻量级目录访问协议，是 X.500 协议的简化版本。LDAP 的开源实现是 OpenLDAP。

### (2) LDAP 协议

客户端发起一个请求消息，请求 LDAP 服务器的某条目录信息，该请求包含唯一的消息 ID，如下图。

服务器收到该请求后，返回客户需要的信息，然后在一条独立的消息中返回结果代码。客户端也可以在一条消息中请求多条目录信息，服务器依次返回这些目录条目，并在最后一条消息中返回结果代码，如下图。

客户端还可以同时发出多条请求消息，服务器响应这些请求，响应中包含请求消息 ID，如下图。

LDAP 协议的操作分为三大类：

查询操作：search, compare  
更新操作：add, delete, modify, modify DN(rename)  
认证和访问控制：bind, unbind, abandon

**下图是一个典型的 LDAP 协议操作过程。**

I. 客户端向 LDAP 服务器打开 TCP 连接，提交一个 bind 操作，该操作包含客户用来炎症的目录条目，以及验证凭据（通常为口令或者证书）；  
II. 服务器验证成功后返回成功结果给客户；  
III. 客户端发起 search 请求；  
IV - V. 服务器处理请求，返回两条结果；  
VI. 服务器发送结果代码；  
VII. 客户端发起一个 unbind 请求  
VIII. 服务器关闭连接

BER，Basic Encoding Rules，与系统无关的紧凑性数据编码规则，用于编码整数、字符串等数据类型，SNMP 采用了这种数据编码规则。LBER，Lightweight BER，LDAP 使用的一种简化的 BER 编码规则。可见，LDAP 在网络上传输的数据是非文本的，这和 HTTP 协议及 SMTP 协议有所不同。

### (3) LDAP 命名模型

LDAP 有两种命名方式：传统的命名方式和基于 Internet 的命令方式，下图展示了这两种方式。

在命令模型中，有两个重要的概念：

DN，Distinguished name，节点引用的唯一名称，比如 uid=babs,ou=People,dc=example,dc=com。  
RDN，Relative Distinguished Name ，相对的节点名称，比如 uid=babs。

### (4) LDAP 信息模型

LDAP 存储信息的基本单位是 Entry，一个节点为一个 Entry；  
每个 Entry 有一套 Attributes；  
每个 Attribute 有 Type 和一个或者多个 Values；  
Type 有语法规则 (哪些值才能赋给这种类型的属性) 和匹配规则；  
匹配规则由比较规则和排序规则组成，比如 caseIgnoreMatch 和 integerMatch；  
Entry 的属性是由 Schema 来定义的。

### (5) LDAP 功能模型

这里只介绍搜索，其他部分参考后文。在 LDAP 的搜索中，共有 8 个选项：

Base Object，搜索的起始根路径；  
Search Scope，分三类：base，只检索 Base Object; onelevel，检索 Base Object 下面的第一层目录；sub，检索从 Base Object 开始的所有下层目录；  
Dereferencing 选项，是否解除别名节点的引用；  
Size Limit，返回的 Entries 的数目，0 为不限制；  
Time Limit，0 为不限制；  
Attribute Only 参数，true 指示只返回属性类型，否则类型和值都返回；  
Search Filter，搜索过滤条件；  
要求搜索返回的属性列表，默认为都返回。

### (6) LDAP 安全模型

Bind 操作把 DN 和用户口令传给 LDAP 服务器进行认证，LDAP 服务器检查 DN 对应的 userPassword 属性是否和用户提供的口令一致， 这种认证可用 TLS(LDAPv3) 保护，也可选用 SASL 认证。Unbind 操作断开和 LDAP 服务的连接。Abandon 操作把 Message ID 发给 LDAP 服务器，丢弃已经初始化的 LDAP 操作。

### (7) LDIF 文件格式

LDIF 按作用可分为两大类：添加数据类和更新数据类。以下为一个典型的添加数据类的格式：

```
dn: dc=example,dc=com
objectclass: dcObject
objectclass: organization
o: example
dc: example

dn: cn=Manager,dc=example,dc=com
objectclass: organizationalRole
cn: Manager

dn: ou=People,dc=example,dc=com
objectclass: top
objectclass: organizationalUnit
ou: People

dn: uid=yingyuan,ou=People,dc=example,dc=com
objectClass: Top
objectClass: Person
objectClass: OrganizationalPerson
objectClass: InetOrgPerson
uid: yingyuan
cn: Yingyuan Cheng
sn: Cheng
userPassword: yingyuan 
mail: yingyuan@staff.example.com.cn
description: A little little boy living in the big big 
 world.
jpegPhoto:: /9j/4AAQSkZJRgABAAAAAQABAAD/2wBDABALDA4MChAODQ4
 SERATGCgaGBYWGDEjJR0oOjM9PDkzODdASFxOQERXRTc4UG1RV19iZ2hnP
```

需要注意的地方是, 续行的时候第一个字符必须为空格，如果属性值是 Base64 编码的，必须要有两个冒号。

数据更新有好几种情况，仅仅为数据添加的方式比如：

```
dn: uid=bjensen, ou=people, dc=example, dc=com
changetype: add
objectclass: top
objectclass: person
```

数据删除比如：

```
dn: uid=bjensen, ou=people, dc=example, dc=com
changetype: delete
```

数据修改比如：

```
dn: uid=bjensen, ou=people, dc=example, dc=com
changetype: modify
add: telephoneNumber
telephoneNumber: +1 216 555 1212
```

```
dn: uid=bjensen, ou=people, dc=example, dc=com
changetype: modify
delete: telephoneNumber
telephoneNumber: +1 216 555 1212
```

```
dn: uid=bjensen, ou=people, dc=example, dc=com
changetype: modify
replace: telephoneNumber
telephoneNumber: +1 216 555 1212
telephoneNumber: +1 405 555 1212
```

```
dn: uid=bjensen, ou=people, dc=example, dc=com
changetype: modify
add: mail
mail: bjensen@example.com
-
delete: telephoneNumber
telephoneNumber: +1 216 555 1212
-
delete: description
-
```

后一个例子把集中更新操作放在一个文件里。

此外更新操作还有目录的移动和重命名，比如：

```
dn: uid=bjensen, ou=People, dc=example, dc=com
changetype: moddn
newsuperior: ou=Terminated Employees, dc=example, dc=com
```

```
dn: uid=bjensen, ou=People, dc=example, dc=com
changetype: moddn
newrdn: uid=babsj
deleteoldrdn: 0
```

### (8) LDAP 命令行实战

```
# 搜索主机ldap.example.com，范围为dc=example,dc=com以及其子目录，
# 过滤条件为cn=Barbara Jensen
$ ldapsearch -h ldap.example.com -s sub -b "dc=example,dc=com" "(cn=Barbara Jensen)“

# 仅搜索基目录，过滤条件为所有类
$ ldapsearch -h ldap.example.com -s base -b /
"uid=bjensen,ou=people,dc=example,dc=com" "(objectclass=*)"

# 搜索用户为uid=bjensen,ou=people,dc=exampe,dc=com
# 口令为hifalutin
$ ldapsearch -h localhost -D "uid=bjensen,ou=people,dc=example,dc=com" /
-w hifalutin -s sub -b "dc=example,dc=com" "(cn=Barbara Jensen)“

# 仅返回mail, roomNumber属性 
$ ldapsearch -h localhost -s sub -b "dc=example,dc=com" "(cn=Barbara Jensen)" /
mail roomNumber

# 返回所有属性和操作属性
$ ldapsearch -h localhost -s sub -b "dc=example,dc=com" "(cn=Barbara Jensen)" /
"*" modifiersName modifyTimeStamp

# 过滤条件为或连接
$ ldapsearch -h localhost -s sub -b "dc=example,dc=com" "(|(L=cupertino)(L=sunnyvale))"

# 过滤条件为复合条件
$ ldapsearch -h localhost -s sub -b "dc=example,dc=com" /
"(&(|(L=cupertino)(L=sunnyvale))(objectclass=person))"

# 从ldif文件中更新数据（updates.ldif含changetype）
$ ldapmodify –h ldap.example.com –D "cn=directory manager" –w secret < updates.ldif

# 从ldif文件中添加数据(不含changetype)
$ ldapmodify –h ldap.example.com –D "cn=directory manager" –w secret –a < updates.ldif

# 更新数据的过程中如果遇到错误则继续(-c)
# 并把错误写入rejects.ldif文件(-e rejects.ldif)
$ ldapmodify –h ldap.example.com –D "cn=directory manager" –w secret /
–c –e rejects.ldif < updates.ldif
```
