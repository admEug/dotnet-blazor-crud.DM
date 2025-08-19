# This Dockerfile is for a Blazor WebAssembly app with a server project.
# It uses a multi-stage build to keep the final image small.

# Stage 1: Build the application
# Use the .NET SDK image to build and publish the app.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the solution file first to leverage Docker layer caching.
# This assumes the Dockerfile is in the same directory as the .sln file.
COPY Blazorcrud.sln .

# Copy the project files for the server, client, and shared projects.
COPY Blazorcrud.Server/*.csproj Blazorcrud.Server/
COPY Blazorcrud.Client/*.csproj Blazorcrud.Client/
COPY Blazorcrud.Shared/*.csproj Blazorcrud.Shared/

# Restore the dependencies for the server project only.
# This avoids issues with test projects not being in the build context.
RUN dotnet restore "Blazorcrud.Server/Blazorcrud.Server.csproj"

# Copy the rest of the application source code.
COPY . .

# Publish the server project.
WORKDIR "/src/Blazorcrud.Server"
RUN dotnet publish "Blazorcrud.Server.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Create the final runtime image
# Use the .NET ASP.NET runtime image for the final production image.
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copy the published output from the build stage.
COPY --from=build /app/publish .

# Set the entrypoint to run the Blazor server application.
ENTRYPOINT ["dotnet", "Blazorcrud.Server.dll"]
