# Start with an Ubuntu 22.04 base image
FROM ubuntu:22.04


### IMPORT THE USER'S FILES ###

# Give user the whole folder with their stuff in it on the container
COPY ./resources /app/resources
RUN mkdir -p /app/templates && \
    cp /app/resources/main.tf.example /app/templates/main.tf.example && \
    cp /app/resources/config.example /app/templates/config.example



### INSTALL OCI TOOL ###

# Set environment variables to prevent interactive prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    python3-pip \
    python3-distutils \
    python3-venv \
    vim \
    tree \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install OCI CLI
RUN curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh -o /tmp/oci-install.sh && \
    bash /tmp/oci-install.sh --accept-all-defaults && \
    rm -f /tmp/oci-install.sh

# Set OCI CLI installation directory to PATH
ENV PATH="/root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Test the OCI CLI installation
RUN  /root/bin/oci --version



### INSTALL UTILITY FOR RETRYING COMMANDS ###

# Install Go
RUN apt-get update && apt-get install -y wget
RUN wget https://go.dev/dl/go1.21.1.linux-amd64.tar.gz -O /tmp/go.tar.gz -q && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Set Go environment variables
ENV GOPATH="/go"
ENV PATH="/go/bin:/usr/local/go/bin:/root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Create a directory for the Go project
RUN mkdir -p /app/repeat-command

# Copy the Go source code from the local directory to the container
COPY ./repeat-command /app/repeat-command

# Build the Go project (assumes your Go code has a main.go file)
RUN go build -o /app/repeat-command/repeat-command /app/repeat-command/main.go



### INSTALL TERRAFORM ###

ARG TERRAFORM_VERSION=1.14.6

RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    apt install -y zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    terraform --version



### SHELL ###

COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]
