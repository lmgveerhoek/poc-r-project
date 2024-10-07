# Start from a base R image
FROM rocker/r-ver:4.4.1

# Install system dependencies for R packages
RUN apt-get update && apt-get install -y \
  libcurl4-openssl-dev \
  libssl-dev \
  libxml2-dev \
  libgit2-dev \  
  libuv1-dev \   
  libjson-c-dev \ 
  libyaml-dev \ 
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Set environment variables for renv paths
ENV RENV_PATHS_LIBRARY="/usr/local/lib/R/renv/library"

# Set the working directory
WORKDIR /usr/src/app

# Copy renv files before installing packages to leverage Docker caching
COPY renv.lock renv.lock
COPY renv/ renv/
COPY .Rprofile .Rprofile

# Install R packages using renv lockfile
RUN R -e "install.packages('renv'); renv::restore(lockfile = 'renv.lock')"

# Copy the rest of the application files
COPY . .

# Set the default command (adjust to your app's entry point)
CMD ["Rscript", "main.R"]
