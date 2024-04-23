## 使用普通用户启动docker
```bash
sudo usermod -aG docker $USER
sudo systemctl restart docker
```

## 获取普通用户的UID
```bash
id -u $USER
```
## 获取docker用户组的组id
```bash
cat /etc/group|grep docker|awk -F ":" '{print $3}'
```
## 修改Dockerfile
普通用户的UID和docker的GID
## 修改docker-compose.yml
- 普通用户的UID和docker的GID
- 需要挂载的目录
- 需要映射的端口
## 构建
```bash
docker compose build
```
## 先创建欲挂载的目录，并设定好用户权限
如果不创建目录，直接启动，则对应目录将会使用root创建，造成权限问题。
```bash
mkdir jenkins_home /var/tmp/workdir
sudo chown -R $USER:$USER jenkins_home
sudo chown -R $USER:$USER /var/tmp/workdir
```
## 启动
```bash
docker compose up -d
```


