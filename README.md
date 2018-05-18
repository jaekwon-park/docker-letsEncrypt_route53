# docker-letsEncrypt_route53
## Let's Encrypt 를 AWS 내에 인스턴스가 아닌 외부에서 사용하기 위한 Docker Image

certbot/dns-route53 이미지를 베이스로 Docker 환경변수에 AWS ACCESS KEY, AWS Secret KEY, Let's Encrypt 발급시 사용할 EMAIl, 그리고 발급받을 도메인 주소를 사용하여 SSL 을 발급 받아주는 DOcker Image

별도로 SSL 발급시 default 라는 폴더에 SSL 파일을 copy 해둠
  - NGINX 혹은 Apache 등 다른 web server의 certification file 경로를 고정적으로 잡기 위한 기능
