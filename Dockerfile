# Containerize the go application that we have created
# This is the Dockerfile that we will use to build the image
# and run the container

# Start with a base image
FROM golang:1.21 as base

# Set the working directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files to the working directory as go.mod file has all dependencies for go application like requirements.txt file in python
COPY go.mod ./

# Download all the dependencies for the app if any then the below command is handy like pip install -r requirements.txt file in python
RUN go mod download

# Copy the source code to the working directory
COPY . .

# Build the application
RUN go build -o main .

#######################################################
# Reduce the image size and security using multi-stage builds
# We will use a distroless image to run the application
FROM gcr.io/distroless/base

# Copy the binary from the previous stage copying the 'main' binary from '/app' directory of base stage and . is drfault directory i.e /app only
COPY --from=base /app/main .

# Copy the static files from the previous stage and ./static name is static as well to By using the same name (static), the application's runtime logic doesn't need to change between the build and runtime stages. For example, if the app expects static files in a directory called static, keeping the same name ensures seamless operation.
COPY --from=base /app/static ./static

# Expose the port on which the application will run
EXPOSE 8080

# Command to run the application
CMD ["./main"]
