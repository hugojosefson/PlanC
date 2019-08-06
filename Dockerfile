FROM debian:10 as builder
RUN apt-get update
RUN apt-get install -y build-essential make cmake git
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Cache dependencies / git submodules
COPY boost boost
COPY cryptopp cryptopp
COPY leveldb leveldb
COPY snappy snappy
COPY zlib zlib
COPY zstr zstr
COPY .git .git
COPY Makefile .
RUN echo "\n\ndeps :$(cat Makefile  | awk -F ' ' '/^plan-c/{$1=$2=$3=""; print $0}')" >> Makefile
RUN make deps

# Copy and make plan-c, using enabled STATIC_OPTIONS
RUN sed -E 's/^(STATIC_OPTIONS *= *)\#+ */\1/' -i Makefile
COPY *.cpp *.h ./
RUN make

# Minimal runtime image
FROM alpine
COPY --from=builder /app/plan-c /usr/local/bin/

VOLUME adb
VOLUME archive
VOLUME dest

CMD sh
