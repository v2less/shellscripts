## install

```bash
sudo apt -y install influxdb influxdb-client 
```

创建数据库

使用命令行工具`influx`:

​	参考: [入门指南](https://jasper-zhang1.gitbooks.io/influxdb/content/Introduction/getting_start.html)

```sql
CREATE DATABASE jenkins
CREATE USER "jenkins" WITH PASSWORD 'root123' WITH ALL PRIVILEGES
```
删除数据库
```sql
DROP DATABASE <database_name>
```



## 使用curl访问infulxdb api

### 查询数据库是否存在

```bash
curl -i -XPOST http://10.20.15.132:8086/query --data-urlencode "q=SHOW DATABASES"
```

### 创建数据库

```bash
curl -i -XPOST http://10.20.15.132:8086/query --data-urlencode "q=CREATE DATABASE jenkins"
```

### 写入数据

```bash
sh '''#!/bin/sh \n
     curl -i -XPOST 'http://10.20.15.132:8086/write?db=jenkins' \
                --header 'Authorization: Token jenkins:root123' \
                --data-binary "jenkins_data,job_name=\"${JOB_BASE_NAME}\" build_start_time=\\"${build_start_time}\\",project_name=\\"${project_name}\\",project_branch=\\"${project_branch}\\",BUILD_URL=\\"${BUILD_URL}\\" \$(date +%s%N)"
 '''
```



## jenkins插件

- InfluxDB

- Post build task
