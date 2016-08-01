FROM fedora:23

RUN dnf -y install git make findutils tree
RUN git clone https://github.com/emender/emender.git && cd emender && make install && make clean
RUN git clone https://github.com/emender/emender-lib.git && cd emender-lib && make install && make clean
RUN dnf clean all
