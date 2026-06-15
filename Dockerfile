# Multi-stage build for .NET 10 Razor Pages app
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# copy csproj and restore as distinct layers
COPY ["ENGAGEMENT_INVITATION.csproj", "./"]
RUN dotnet restore "ENGAGEMENT_INVITATION.csproj"

# copy everything else and publish
COPY . .
RUN dotnet publish "ENGAGEMENT_INVITATION.csproj" -c Release -o /app/publish -r linux-x64 --self-contained false /p:PublishTrimmed=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# At runtime we let the container bind to the PORT env Railway provides. Default to 8080 if not set.
EXPOSE 8080
COPY --from=build /app/publish ./

# Use shell form to allow expanding PORT at runtime and provide a default
ENTRYPOINT ["sh", "-c", "dotnet ENGAGEMENT_INVITATION.dll --urls http://*:${PORT:-8080}"]
