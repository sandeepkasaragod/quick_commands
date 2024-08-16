# Ubuntu 
Content from https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-20-04
```shell
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql.service
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
exit
```
# Mac
