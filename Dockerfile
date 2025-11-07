## 1. build된 jar파일이 있는 경우
#FROM eclipse-temurin:17-jre-alpine
#WORKDIR /app
#COPY build/libs/*.jar ./
#RUN mv $(ls *.jar | grep -v plain) app.jar
#ENTRYPOINT ["java", "-jar", "app.jar"]

## 2. 자동 build 후 jar 파일로 실행되게 수정(멀티 스테이징)
FROM gradle:8.5-jdk17-alpine AS build
WORKDIR /app
COPY . .

## daemon 스레드를 쓰지 않음으로써 불필요한 리소스 낭비를 줄인다.
## - gradle 이미지는 기본적으로 백그라운드에서 프로세스(데몬)을 실행
## - 메모리에 JVM이나 빌드 정보를 캐싱
## 다음 빌드 시 속도가 향상됨
RUN gradle clean build --no-daemon -x test

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/build/libs/*.jar ./
RUN mv $(ls *.jar | grep -v plain) app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]