# MVND Docker Images

[![Docker Hub Version](https://img.shields.io/docker/v/power4j/mvnd?label=Docker%20Hub)](https://hub.docker.com/r/power4j/mvnd)
[![GitHub Actions](https://img.shields.io/github/actions/workflow/status/power4j/maven-daemon-docker/platform-build.yml?branch=main)](https://github.com/power4j/maven-daemon-docker/actions)

[English](README.md) | [中文](README.zh-CN.md)

Docker images for Apache Maven Daemon (`mvnd`) with multi-JDK support, enabling fast Maven project builds in containerized environments.

## 🚀 Quick Start

### Pull Images

```bash
# Use JDK 17 (Recommended)
docker pull power4j/mvnd:1.0.2-temurin-17-jdk-jammy

# Use JDK 8
docker pull power4j/mvnd:1.0.2-temurin-8-jdk-jammy

# Use JDK 11
docker pull power4j/mvnd:1.0.2-temurin-11-jdk-jammy

# Use JDK 21
docker pull power4j/mvnd:1.0.2-temurin-21-jdk-jammy

# Use JDK 22
docker pull power4j/mvnd:1.0.2-temurin-22-jdk-jammy
```

### Basic Usage

```bash
# Run in Maven project directory
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install

# Or use alias to simplify commands
alias mvnd='docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd'
mvnd clean install
```

## 📦 Available Images

### Image Tag Format

```
power4j/mvnd:{mvnd-version}-{jdk-type}
```

### Supported JDK Versions

| JDK Version | Image Tag | Base Image | Recommended Use |
|-------------|-----------|------------|-----------------|
| JDK 8 | `temurin-8-jdk-jammy` | `eclipse-temurin:8-jdk-jammy` | Legacy project compatibility |
| JDK 11 | `temurin-11-jdk-jammy` | `eclipse-temurin:11-jdk-jammy` | LTS version |
| JDK 17 | `temurin-17-jdk-jammy` | `eclipse-temurin:17-jdk-jammy` | **Recommended** LTS version |
| JDK 21 | `temurin-21-jdk-jammy` | `eclipse-temurin:21-jdk-jammy` | Latest LTS version |
| JDK 22 | `temurin-22-jdk-jammy` | `eclipse-temurin:22-jdk-jammy` | Latest version |

### Supported mvnd Versions

- `1.0.2` (current default)
- Other versions available at [GitHub Releases](https://github.com/apache/maven-mvnd/releases)

## 💡 Usage Examples

### 1. Build Projects

```bash
# Clean and build
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install

# Skip tests
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install -DskipTests
```

### 2. Run Tests

```bash
# Run all tests
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd test

# Run specific test
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd test -Dtest=MyTestClass
```

### 3. Package Applications

```bash
# Package as JAR
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd package

# Package as WAR
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd package -Pwar
```

### 4. Deploy to Repository

```bash
# Deploy to local repository
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd deploy

# Deploy to remote repository
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd deploy -DaltDeploymentRepository=remote-repo::default::https://your-repo.com
```

## 🔧 Advanced Usage

### Custom Maven Settings

```bash
# Use custom settings.xml
docker run --rm \
  -v $(pwd):/workspace \
  -v ~/.m2/settings.xml:/root/.m2/settings.xml \
  -w /workspace \
  power4j/mvnd:1.0.2-temurin-17-jdk-jammy \
  mvnd clean install -s /root/.m2/settings.xml
```

### Maven Profiles

```bash
# Use specific profile
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install -Pproduction

# Use multiple profiles
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install -Pdev,test
```

### JVM Arguments

```bash
# Set memory limits
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install -Dmvnd.jvmargs="-Xmx2g -Xms1g"

# Set system properties
docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install -Dspring.profiles.active=prod
```

## 🐳 Docker Compose Integration

Create `docker-compose.yml`:

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

Run:

```bash
docker-compose up
```

## 🔍 Troubleshooting

### Common Issues

1. **Permission Issues**
   ```bash
   # Ensure current user has read/write permissions on project directory
   sudo chown -R $(id -u):$(id -g) .
   ```

2. **Maven Repository Cache**
   ```bash
   # Clean Maven local repository
   docker run --rm -v $(pwd):/workspace -w /workspace power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean
   ```

3. **Network Issues**
   ```bash
   # Use proxy settings
   docker run --rm -v $(pwd):/workspace -w /workspace \
     -e HTTP_PROXY=http://proxy:port \
     -e HTTPS_PROXY=http://proxy:port \
     power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd clean install
   ```

### Check Versions

```bash
# Check mvnd version
docker run --rm power4j/mvnd:1.0.2-temurin-17-jdk-jammy mvnd --version

# Check Java version
docker run --rm power4j/mvnd:1.0.2-temurin-17-jdk-jammy java --version
```

## 📚 Related Links

- [Apache Maven Daemon (mvnd) Documentation](https://maven.apache.org/mvnd/)
- [Eclipse Temurin](https://adoptium.net/)
- [Docker Hub Image Page](https://hub.docker.com/r/power4j/mvnd)

## 🤝 Contributing

Issues and Pull Requests are welcome!

## 📄 License

This project is licensed under the Apache License 2.0. 