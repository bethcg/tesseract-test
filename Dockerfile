# Debian 12 aka Bookworm
FROM debian:12

ARG TESSERACT_VERSION="main"
ARG TESSERACT_URL="https://api.github.com/repos/tesseract-ocr/tesseract/tarball/$TESSERACT_VERSION"

# install basic tools
RUN apt-get update && apt-get install --no-install-recommends --yes \
    apt-transport-https \
    asciidoc \
    automake \
    bash \
    ca-certificates \
    curl \
    docbook-xsl \
    g++ \
    git \
    libleptonica-dev \
    libtool \
    libicu-dev \
    libpango1.0-dev \
    libcairo2-dev \
    make \
    pkg-config \
    wget \
    xsltproc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN wget -qO tesseract.tar.gz $TESSERACT_URL && \
    tar -xzf tesseract.tar.gz && \
    rm tesseract.tar.gz && \
    mv tesseract-* tesseract

WORKDIR /src/tesseract

RUN ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    ldconfig

# go to default traineddata directory
WORKDIR /usr/local/share/tessdata/

# copy language script and list to image
COPY get-languages.sh .
COPY languages.txt .

# make script executable
RUN chmod +x ./get-languages.sh
# download traineddata languages
RUN ./get-languages.sh

# go to user input/output folder
WORKDIR /tmp/

# CMD ["tesseract", "--version"]
CMD ["tesseract", "--list-langs"]
