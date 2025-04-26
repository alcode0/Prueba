# Etapa base: imagen del runtime de .NET
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Etapa de construcción: imagen del SDK de .NET
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copiar el archivo .csproj y restaurar las dependencias
COPY ["Prueba.csproj", "./"]
RUN dotnet restore "Prueba.csproj"

# Copiar el resto del código
COPY . .
WORKDIR "/src/"
RUN dotnet build "Prueba.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Etapa de publicación: construir el proyecto para la publicación
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Prueba.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Etapa final: imagen con solo el runtime de .NET y la publicación del proyecto
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Prueba.dll"]
