# MVND Docker 镜像

[![Docker Hub Version](https://img.shields.io/docker/v/power4j/mvnd?label=Docker%20Hub)](https://hub.docker.com/r/power4j/mvnd)
[![GitHub Actions](https://img.shields.io/github/actions/workflow/status/power4j/maven-daemon-docker/platform-build.yml?branch=main)](https://github.com/power4j/maven-daemon-docker/actions)

[English](README.md) | [中文](README.zh-CN.md)

Apache Maven Daemon (`mvnd`) 的 Docker 镜像，提供多版本 JDK 支持，让您可以在容器化环境中快速使用 mvnd 进行 Maven 项目构建。

## 🚀 快速开始

### 拉取镜像

```bash
# 使用 JDK 17 (推荐)
docker pull power4j/mvnd:1.0.2-temurin-17-jdk-jammy

# 使用 JDK 8
docker pull power4j/mvnd:1.0.2-temurin-8-jdk-jammy

# 使用 JDK 11
docker pull power4j/mvnd:1.0.2-temurin-11-jdk-jammy

# 使用 JDK 21
docker pull power4j/mvnd:1.0.2-temurin-21-jdk-jammy

# 使用 JDK 22
docker pull power4j/mvnd:1.0.2-temurin-22-jdk-jammy
```

### 基本使用

```bash
# 在 Maven 项目目录中运行
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install

# 或者使用别名简化命令
alias mvnd='docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd'
mvnd clean install
```

## 📦 可用镜像

### 镜像标签格式

```
power4j/mvnd:{mvnd-version}-{jdk-type}
```

### 支持的 JDK 版本

| JDK 版本 | 镜像标签 | 基础镜像 | 推荐用途 |
|---------|---------|---------|---------|
| JDK 8 | `temurin-8-jdk-jammy` | `eclipse-temurin:8-jdk-jammy` | 传统项目兼容 |
| JDK 11 | `temurin-11-jdk-jammy` | `eclipse-temurin:11-jdk-jammy` | LTS 版本 |
| JDK 17 | `temurin-17-jdk-jammy` | `eclipse-temurin:17-jdk-jammy` | **推荐** LTS 版本 |
| JDK 21 | `temurin-21-jdk-jammy` | `eclipse-temurin:21-jdk-jammy` | 最新 LTS 版本 |
| JDK 22 | `temurin-22-jdk-jammy` | `eclipse-temurin:22-jdk-jammy` | 最新版本 |

### 支持的 mvnd 版本

- `1.0.2` (当前默认)
- 其他版本请查看 [GitHub Releases](https://github.com/apache/maven-mvnd/releases)

## 💡 使用示例

### 1. 构建项目

```bash
# 清理并构建
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install

# 跳过测试构建
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install -DskipTests
```

### 2. 运行测试

```bash
# 运行所有测试
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd test

# 运行特定测试
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd test -Dtest=MyTestClass
```

### 3. 打包应用

```bash
# 打包为 JAR
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd package

# 打包为 WAR
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd package -Pwar
```

### 4. 部署到仓库

```bash
# 部署到本地仓库
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd deploy

# 部署到远程仓库
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd deploy -DaltDeploymentRepository=remote-repo::default::https://your-repo.com
```

## 🔧 高级用法

### 使用自定义 Maven 设置

```bash
# 使用自定义 settings.xml
docker run --rm \
  -v $(pwd):/workspace \
  -v ~/.m2/settings.xml:/root/.m2/settings.xml \
  -w /workspace \
  power4j/mvnd:1.0.2-temurin-17-jdk-jammy \
  mvnd clean install -s /root/.m2/settings.xml
```

### 使用 Maven 配置文件

```bash
# 使用特定 profile
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install -Pproduction

# 使用多个 profile
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install -Pdev,test
```

### 设置 JVM 参数

```bash
# 设置内存限制
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install -Dmvnd.jvmargs="-Xmx2g -Xms1g"

# 设置系统属性
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install -Dspring.profiles.active=prod
```

## 🐳 Docker Compose 集成

创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'
services:
  mvnd:
    image: power4j/mvnd:1.0.2-temurin-17-jdk-jammy
    volumes:
      - .:/workspace
      - ~/.m2:/root/.m2
    working_dir: /workspace
    command: mvnd clean install
```

运行：

```bash
docker-compose up
```

## 🔍 故障排除

### 常见问题

1. **权限问题**
   ```bash
   # 确保当前用户有项目目录的读写权限
   sudo chown -R $(id -u):$(id -g) .
   ```

2. **Maven 仓库缓存**
   ```bash
   # 清理 Maven 本地仓库
   docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean
   ```

3. **网络问题**
   ```bash
   # 使用代理设置
   docker run --rm -v $(pwd):/workspace -w /workspace \
     -e HTTP_PROXY=http://proxy:port \
     -e HTTPS_PROXY=http://proxy:port \
     power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install
   ```

### 查看版本信息

```bash
# 查看 mvnd 版本
docker run --rm power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd --version

# 查看 Java 版本
docker run --rm power4j/mvnd:1.0.2-temurin-17-jdk-jammy java --version
```

## 📚 相关链接

- [Apache Maven Daemon (mvnd) 官方文档](https://maven.apache.org/mvnd/)
- [Eclipse Temurin](https://adoptium.net/)
- [Docker Hub 镜像页面](https://hub.docker.com/r/power4j/mvnd)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目采用 Apache License 2.0 许可证。 