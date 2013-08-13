# Deploy script
# 
# @package none
# @author Jay Zhang <jay@easilydo.com>
# @file install.sh
# @copyright Copyright 2012 Easilydo Inc. 
# @version 1.0
# @since 2012-07-27

PROJECT_NAME="ranktool";
HOME_DIR=$HOME/$PROJECT_NAME;
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd);
HOME_DIR=$PWD;

if [ ! -d $HOME_DIR ]; then
    mkdir $HOME_DIR;
fi;
cd $HOME_DIR;
mkdir local install www var tmp;

cd $HOME_DIR/install;

PHP_NAME="php-5.4.17";
if [ ! -d $PHP_NAME ]; then
    wget "http://us.php.net/distributions/$PHP_NAME.tar.gz";
    tar xzf $PHP_NAME.tar.gz
fi

HTTPD_NAME="httpd-2.2.25";
if [ ! -d $HTTPD_NAME ]; then
    wget "http://mirror.symnds.com/software/Apache/httpd/$HTTPD_NAME.tar.gz";
    tar xzf $HTTPD_NAME.tar.gz
fi

ZLIB_NAME="zlib-1.2.8";
if [ ! -d $ZLIB_NAME ]; then
    wget "http://zlib.net/$ZLIB_NAME.tar.gz";
    tar xzf $ZLIB_NAME.tar.gz
fi

SSL_NAME="openssl-0.9.8x";
if [ ! -d $SSL_NAME ]; then
    wget "http://www.openssl.org/source/$SSL_NAME.tar.gz";
    tar xzf $SSL_NAME.tar.gz
fi

CURL_NAME="curl-7.32.0";
if [ ! -d $CURL_NAME ]; then
    wget "http://curl.haxx.se/download/$CURL_NAME.tar.gz";
    tar xzf $CURL_NAME.tar.gz
fi

LIBXML2_NAME="libxml2-2.7.8";
if [ ! -d $LIBXML2_NAME ]; then
    wget "ftp://xmlsoft.org/libxml2/$LIBXML2_NAME.tar.gz"
    tar xzf $LIBXML2_NAME.tar.gz
fi

AUTOCONF_NAME="autoconf-2.69";
if [ ! -d $AUTOCONF_NAME ]; then
    wget "http://ftp.gnu.org/gnu/autoconf/autoconf-2.68.tar.gz"
    tar xzvf $AUTOCONF_NAME.tar.gz
fi

cd $HOME_DIR/install;
cd $ZLIB_NAME
./configure \
--prefix=$HOME_DIR/local/$ZLIB_NAME
make && make install

cd $HOME_DIR/install;
cd $SSL_NAME
./config \
--prefix=$HOME_DIR/local/$SSL_NAME \
--shared
make && make install

cd $HOME_DIR/install;
cd $CURL_NAME
./configure \
--prefix=$HOME_DIR/local/$CURL_NAME \
--with-zlib=$HOME_DIR/local/$ZLIB_NAME \
--with-ssl=$HOME_DIR/local/$SSL_NAME \
--enable-shared \
CURL_LIBS="-lssl -lcrypto"
make
make install

cd $HOME_DIR/install;
cd $HTTPD_NAME
./configure \
--prefix=$HOME_DIR/local/$HTTPD_NAME \
--enable-modules=most
make && make install

rm -rf $HOME_DIR/local/$HTTPD_NAME/htdocs
ln -s $HOME_DIR/www $HOME_DIR/local/$HTTPD_NAME/htdocs

cd $HOME_DIR/install;
cd $LIBXML2_NAME
./configure \
--prefix=$HOME_DIR/local/$LIBXML2_NAME
make && make install

cd $HOME_DIR/install;
cd $PHP_NAME
./configure \
--prefix=$HOME_DIR/local/$PHP_NAME \
--with-apxs2=$HOME_DIR/local/$HTTPD_NAME/bin/apxs \
--with-zlib-dir=$HOME_DIR/local/$ZLIB_NAME \
"--with-openssl=$HOME_DIR/local/$SSL_NAME" \
"--with-curl=$HOME_DIR/local/$CURL_NAME" \
"--with-curlwrappers" \
--with-libxml-dir=$HOME_DIR/local/$LIBXML2_NAME \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--enable-ftp \
--enable-sockets \
--with-iconv \
--enable-mbstring \
--disable-dom \
--without-sqlite
#--with-mhash=$LIB_DIR/mhash-0.9.7.1 \
#--with-gd=$LIB_DIR/gd-2.0.33 \
#--with-png-dir=$LIB_DIR/libpng-1.2.12 \
#--with-jpeg-dir=$LIB_DIR/jpeg-6b \
#--with-mcrypt=$LIB_DIR/libmcrypt-2.5.7 \
#--enable-track-vars \
#--enable-iconv \
make
make install

cd $HOME_DIR/install;
cd $AUTOCONF_NAME
./configure \
--prefix=$HOME_DIR/local/$AUTOCONF_NAME
make && make install

cd $HOME_DIR/install;
wget "http://pecl.php.net/get/yaf-2.1.18.tgz"
tar xzf yaf-2.1.18.tgz
cd yaf-2.1.18
PHP_AUTOCONF="$HOME_DIR/local/$AUTOCONF_NAME/bin/autoconf" \
PHP_AUTOHEADER="$HOME_DIR/local/$AUTOCONF_NAME/bin/autoheader" \
$HOME_DIR/local/$PHP_NAME/bin/phpize
./configure --with-php-config=$HOME_DIR/local/$PHP_NAME/bin/php-config
make
make install

cp $SCRIPT_DIR/php.ini $HOME_DIR/local/$PHP_NAME/lib
cp $SCRIPT_DIR/httpd.conf $HOME_DIR/local/$HTTPD_NAME/conf

SED_REP="s/%HOME_DIR%/"$(echo $HOME_DIR | sed 's/\//\\x2f/g')"/g";
sed -i $SED_REP $HOME_DIR/local/$PHP_NAME/lib/php.ini
sed -i $SED_REP $HOME_DIR/local/$HTTPD_NAME/conf/httpd.conf

echo "========================================";
echo "Deploy finished";
