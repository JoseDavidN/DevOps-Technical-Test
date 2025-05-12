# ------------------------------------------
# Compilar la aplicación con Maven
# ------------------------------------------
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app

# Cache eficiente de dependencias
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN chmod +x mvnw

# Descarga dependencias antes de copiar el código
RUN ./mvnw dependency:go-offline

# copiamos el resto del código fuente
COPY src ./src

# Compila la app y empaqueta
RUN ./mvnw clean package -DskipTests

# ------------------------------------------
# Imagen liviana para producción
# ------------------------------------------
FROM eclipse-temurin:17-jre

WORKDIR /app

# Copia el fat JAR desde el build
COPY --from=build /app/target/*.jar app.jar

# Argumentos inyectados desde el pipeline
ARG APP_VERSION=Dev
ARG BUILD_DATE=unknown
ARG GIT_COMMIT=unknown

# Metadata de la imagen importante para trazabilidad e inspección
LABEL maintainer="Jose Gomez <gomezjosedavid997@gmail.com>" \
      org.opencontainers.image.title="Grafana App" \
      org.opencontainers.image.source="https://github.com/JoseDavidN/DevOps-Technical-Test" \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.revision="${GIT_COMMIT}" \
      org.opencontainers.image.created="${BUILD_DATE}"

# Exponer el puerto de la aplicación
EXPOSE 1222

# Comando de ejecución
ENTRYPOINT ["java", "-jar", "app.jar"]
