#上游仓库缓存地址
public.ecr.aws

访问方式：
```bash
docker pull 553336566444.dkr.ecr.us-east-2.amazonaws.com/ecr-public/upstream-repository-name
```

例如：
实际上游地址是： https://gallery.ecr.aws/nginx/nginx
拉取：
```bash
docker pull 553336566444.dkr.ecr.us-east-2.amazonaws.com/ecr-public/nginx/nginx
```

#/etc/docker/daemon.json
```json
{
  "registry-mirrors": [
    "https://public.ecr.aws",
    "https://553336566444.dkr.ecr.us-east-2.amazonaws.com",
    "http://10.12.21.251:5000",
    "https://qdvhyc3o.mirror.aliyuncs.com"
  ],
  "insecure-registries": [
          "10.12.21.251:5000"
  ],
  "debug": true,
  "live-restore": true
}
```
