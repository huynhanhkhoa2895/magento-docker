FROM debian
ENV TZ=Asia/Ho_Chi_Minh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get upgrade
RUN apt-get update && apt-get -y install sudo curl apache2 vim wget unzip
RUN sudo apt install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list && \
    wget -qO - https://packages.sury.org/php/apt.gpg | sudo apt-key add - && \
    apt-get update
    
RUN sudo apt install -y php7.4 ufw redis-server
RUN sudo apt-get update
RUN sudo apt install -y php7.4-curl \
                        php7.4-dom \
                        php7.4-gd \
                        php7.4-mbstring \
                        php7.4-simplexml \
                        php7.4-xml \
                        php7.4-xmlreader \
                        php7.4-xmlwriter \
                        php7.4-zip \
                        php7.4-pgsql \
                        php7.4-mysqli \
                        php7.4-intl \
                        php7.4-mcrypt \
                        # php7.4-mhash \
                        # php7.4-openssl \
                        php7.4-soap \
                        php7.4-xsl \
                        php7.4-bcmath \
                        # php7.4-json \
                        php7.4-iconv 
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer 
RUN sudo rm /var/www/html/index.html
RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
RUN sudo apt -y install nodejs
RUN npm i -g yarn
COPY ./docker-conf/magento.conf /etc/apache2/sites-available/magento.conf
COPY docker-conf/khoadev.local.conf /etc/apache2/sites-available/khoadev.local.conf

COPY docker-conf/apache2.conf /etc/apache2/apache2.conf
COPY docker-conf/redis.conf /etc/redis/redis.conf
COPY docker-conf/server.pem /etc/apache2/server.pem
COPY docker-conf/server-key.pem /etc/apache2/server-key.pem
# COPY docker-conf/khoadev.local.conf /etc/apache2/sites-available/khoadev.local.conf

RUN mkdir -p /var/www/magento

RUN sudo chown -R $USER:$USER /var/www/magento

RUN sudo chmod -R 755 /var/www

COPY ./magento /var/www/magento
# COPY docker-conf/server.pem /etc/apache2/server.pem
# COPY docker-conf/server-key.pem /etc/apache2/server-key.pem
RUN sudo a2ensite khoadev.local.conf
RUN cd /etc/apache2/mods-enabled/ && sudo a2enmod rewrite && sudo a2enmod ssl
RUN sudo a2dissite 000-default.conf && \
    sudo a2ensite magento.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && sudo service apache2 restart



WORKDIR /var/www/html/
EXPOSE 80 
CMD ["apache2ctl", "-D", "FOREGROUND"]