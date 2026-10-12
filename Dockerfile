# ============================================================
# Murach CD Store - Dockerfile (Multi-stage Build)
# Stage 1: Build WAR voi Maven + JDK 17
# Stage 2: Deploy len Tomcat 10.1 + JDK 17
# ============================================================

# ── Stage 1: Build
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml truoc de cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B --no-transfer-progress

# Copy source code va build WAR
COPY src ./src
RUN mvn clean package -DskipTests -B --no-transfer-progress

# ── Stage 2: Deploy
FROM tomcat:10.1-jdk17-temurin

LABEL maintainer="Le Trung Dong"
LABEL description="Murach CD Store with VNPay Payment"
LABEL version="1.0"

# Xoa ung dung mac dinh cua Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR tu stage build - deploy tai root context "/"
COPY --from=build /app/target/cdstore.war /usr/local/tomcat/webapps/ROOT.war

# VNPay Configuration - override qua docker-compose env
# Thay the bang thong tin that khi production
ENV VNP_TMN_CODE=DEMO2024
ENV VNP_HASH_SECRET=ABCDEFGHIJKLMNOPQRSTUVWXYZ123456

# Tomcat default port 8080
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Khoi dong Tomcat
CMD ["catalina.sh", "run"]
