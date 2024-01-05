## 创建密码文件
```bash
sudo apt install apache2-utils
htpasswd -c .htpasswd user
```
## 构建docker镜像
```bash
docker-compose build --build-arg http_proxy=http://10.12.17.80:8118 --build-arg https_proxy=http://10.12.17.80:8118 mynginx
```
## 启动docker镜像
```bash
docker-compose up -d
```
### 将fancyindex复制出来
```bash
docker cp -a e2d413be7615:/www/html/fancyindex ./
cp fancyindex.js fancyindex/
docker-compose down
docker-compose up -d
```
## data目录权限改为777

因为要上传文件到这里

参考：
- https://kotomiko.com/articles/4
- [ngx-data](https://github.com/765362546/ngx-data)
