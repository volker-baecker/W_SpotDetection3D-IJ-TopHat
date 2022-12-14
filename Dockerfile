FROM python:3.6.9-stretch

RUN apt-get update && apt-get install libgeos-dev -y && apt-get clean

# ---------------------------------------------------------------------------------------------------------------------
# Install Java
RUN apt-get update && apt-get install openjdk-8-jdk -y && apt-get clean

# ---------------------------------------------------------------------------------------------------------------------
# Install Cytomine python client
RUN git clone https://github.com/cytomine-uliege/Cytomine-python-client.git && \
    cd /Cytomine-python-client && git checkout tags/v2.7.3 && pip install . && \
    rm -r /Cytomine-python-client

# ---------------------------------------------------------------------------------------------------------------------
# Fiji installation
# Install virtual X server
RUN apt-get update && apt-get install -y unzip xvfb libx11-dev libxtst-dev libxrender-dev

# Install Fiji.
RUN wget --no-check-certificate https://downloads.imagej.net/fiji/archive/20221013-0917/fiji-linux64.zip
RUN unzip fiji-linux64.zip
RUN mv Fiji.app/ fiji

# create a sym-link with the name jars/ij.jar that is pointing to the current version jars/ij-1.nm.jar
RUN cd /fiji/jars && ln -s $(ls ij-1.*.jar) ij.jar

# Add fiji to the PATH
ENV PATH $PATH:/fiji
RUN mkdir -p /fiji/data

# Clean up
RUN rm fiji-linux64.zip

# ---------------------------------------------------------------------------------------------------------------------
# Install Neubias-W5-Utilities (annotation exporter, compute metrics, helpers,...)
RUN apt-get update && apt-get install libgeos-dev -y && apt-get clean
RUN git clone https://github.com/Neubias-WG5/biaflows-utilities.git && \
    cd /biaflows-utilities/ && git checkout tags/v0.9.1 && pip install .

# install utilities binaries
RUN chmod +x /biaflows-utilities/bin/*
RUN cp /biaflows-utilities/bin/* /usr/bin/

# cleaning
RUN rm -r /biaflows-utilities
# ---------------------------------------------------------------------------------------------------------------------
# Install Fiji plugins
RUN cd /fiji/plugins && wget -O MorphoLibJ_-1.5.1.jar https://github.com/ijpb/MorphoLibJ/releases/download/v1.5.1/MorphoLibJ_-1.5.1.jar

# ---------------------------------------------------------------------------------------------------------------------
# Install Macro
ADD IJSpotDetection3D.ijm /fiji/macros/macro.ijm
ADD wrapper.py /app/wrapper.py

# for running the wrapper locally
ADD descriptor.json /app/descriptor.json

ENTRYPOINT ["python", "/app/wrapper.py"]


