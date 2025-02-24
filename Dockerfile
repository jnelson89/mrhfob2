FROM mcr.microsoft.com/dotnet/aspnet:8.0-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/user/.local/bin:${PATH}"

# Install basic dependencies
RUN apt-get update -yq \
    && apt-get install -yq --no-install-recommends \
        apt-utils \
        curl \
        git \
        nano \
        wget \
        unzip \
        python3 \
        python3-pip \
        gnupg \
        lsb-release \
        software-properties-common

# Setup Node.js (LTS Version)
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -yq nodejs build-essential

# Add Mozilla Team PPA for the latest Firefox
RUN echo "deb http://ppa.launchpad.net/mozillateam/ppa/ubuntu focal main" | tee /etc/apt/sources.list.d/mozillateam-ppa.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A6DCF7707EBC211F \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9BDB3D89CE49EC21 \
    && apt-get update -yq

# Install the latest Firefox and Chromium
RUN apt-get install -yq --no-install-recommends \
        firefox \
        chromium

# Install WebDriverManager
RUN pip3 install webdrivermanager || true \
    && webdrivermanager firefox chrome --linkpath /usr/local/bin || true

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 user
USER user
WORKDIR /app

# Download and unpack the latest OpenBullet2.Web release
RUN wget https://github.com/openbullet/openbullet2/releases/latest/download/OpenBullet2.Web.zip \
    && unzip OpenBullet2.Web.zip \
    && rm OpenBullet2.Web.zip

COPY --chown=user:user . /app

EXPOSE 5000

CMD ["dotnet", "./OpenBullet2.Web.dll", "--urls=http://*:5000"]