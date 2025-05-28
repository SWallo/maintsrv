# maintsrv

A simple Go server that serves static files (e.g., a maintenance page) and always responds with HTTP 503 (Service Unavailable), making it ideal to use as a maintenance placeholder in containerized setups.

## Features
- Serves static files from any directory (by default, `/static`)
- Always responds with HTTP status 503, which is useful for signaling maintenance mode to web clients and load balancers
- Simple access logging of requests

## Usage

### Running locally
You can run the server using Go:

```sh
go run main.go
```

By default, it will serve files from a local `static` directory. The server listens on port 8080.

### Configuration: `STATIC_DIR` environment variable

You can configure the directory to serve static files using the `STATIC_DIR` environment variable. This allows you to change which folder's contents are served **without changing the code**.

- If `STATIC_DIR` is **not** set, the default value is `./static`.
- To serve a different directory, set the environment variable before starting the server:
  
  ```sh
  STATIC_DIR=/path/to/your/files go run main.go
  ```
- In Docker usage (see below), the default for `STATIC_DIR` is `/static` (as set by the Dockerfile), and the static folder is copied into the image.

### Building and running with Docker

Build the image:

```sh
docker build -t maintsrv:latest .
```

Run the container:

```sh
docker run -p 8080:8080 maintsrv:latest
```

You can also override the static files directory when running the container:

```sh
docker run -p 8080:8080 -e STATIC_DIR=/your/dir maintsrv:latest
```

---

#### Official Docker Image

A prebuilt image is available on GitHub Container Registry:

- **Image name:** `ghcr.io/swallo/maintsrv`
- **Example tags:** `latest`, `1.0.0`

**Pull the image:**

```sh
docker pull ghcr.io/swallo/maintsrv:latest
```

**Run the image:**

```sh
docker run -p 8080:8080 ghcr.io/swallo/maintsrv:latest
```

**Environment variables:**
- `STATIC_DIR` — Directory to serve static files from (default: `/static` in the container)

**Volumes:**
- You can mount a custom static directory:

  ```sh
  docker run -p 8080:8080 -v /your/static:/static ghcr.io/swallo/maintsrv:latest
  ```

### Example
If you visit [http://localhost:8080](http://localhost:8080) after starting the server you will see the maintenance page, and the server will always return HTTP 503.

## Project structure

- `main.go` — main application
- `static/` — default static files directory (e.g., index.html)
- `Dockerfile` — container build instructions
- `Makefile` — build automation
- `example/compose.yaml` — example Docker Compose setup

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
