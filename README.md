Ruby Client For Apache Phoenix
====

## 设置Host
```
10.101.85.146 v101085146.sqa.zmf
10.101.87.249 v101087249.sqa.zmf
10.101.88.76 v101088076.sqa.zmf
10.101.88.166 v101088166.sqa.zmf
10.101.89.103 v101089103.sqa.zmf 
```

## 添加 Phoenix JDBC Client 4.x 版本
```
phoenix-4.0.0-incubating-client.jar 文件 此处下载
http://repo1.maven.org/maven2/org/apache/phoenix/phoenix/4.0.0-incubating/
Mac 下把jar文件复制到系统的 Java 库中, 即 /Library/Java/Extensions 下.
```

## 设置 Java CLASSPATH
```
javac -d $HOME/java_class -sourcepath phoenix lib/phoenix/Connect.java
vi /etc/profile, vi ~/.zshrc
  export CLASSPATH=$CLASSPATH:$HOME/java_class
```
