FROM ubuntu:16.04

MAINTAINER Russell Murray & Maxime Lasserre

RUN apt-get update && apt-get install -y tmux vim git rubygems vim-nox openssh-server

RUN mkdir /var/run/sshd
RUN echo 'root:hi' | chpasswd
RUN gem install tmuxinator

RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Create user pair and switch to it to do the next installs
RUN mkdir -p /home/pair && \
    echo "pair:x:1000:1000:Pair,,,:/home/pair:/bin/bash" >> /etc/passwd &&\
    echo "pair:x:1000:" >> /etc/group && \
    chown pair:pair -R /home/pair

RUN chmod 777 /etc/ssh
RUN echo 'pair:reduce' | chpasswd 

USER pair
ENV HOME /home/pair
WORKDIR /home/pair

RUN cd $HOME && git clone https://github.com/spf13/spf13-vim.git && \
    ./spf13-vim/bootstrap.sh

RUN cd $HOME && git clone https://github.com/mousezero/PairZero.git .pairConfig &&\
    ./.pairConfig/install.sh

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

USER root

RUN mkdir ~/.tmuxinator && \
    cp ~/.pairConfig/tmuxConfig/Bable.yml ~/.tmuxinator/Bable.yml && \
    apt-get -y install python-pip && \
    mkdir ~/.cache/pip && \
    pip install powerline-status && \
    vim +PluginInstall +qall
RUN chown pair:pair -R ~/

USER pair

