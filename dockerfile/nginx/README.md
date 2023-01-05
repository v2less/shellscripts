## 创建密码文件
```bash
sudo apt install apache2-utils
htpasswd -c .htpasswd user
```
## 构建docker镜像
```bash
docker-compose build --build-arg http_proxy=http://10.12.17.80:8118 --build-arg https_proxy=http://10.12.17.80:8118 mynginx-alpine
```
## 启动docker镜像
```bash
docker-compose up -d mynginx-alpine
```
## data目录权限改为777

因为要上传文件到这里

参考：
- https://kotomiko.com/articles/4
- [ngx-data](https://github.com/765362546/ngx-data)
