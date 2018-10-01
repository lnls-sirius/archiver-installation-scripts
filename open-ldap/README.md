# OpenLDAP
OpenLDAP Server<br>
The Lightweight Directory Access Protocol, or LDAP, is a protocol for querying and modifying a X.500-based directory service running over TCP/IP. The current LDAP version is LDAPv3, as defined in RFC4510, and the implementation in Ubuntu is OpenLDAP."<br>
Based on <href>https://github.com/lnls-sirius/docker-openldap.git</href>.<br>

## If possible use the Docker based installation



The default paths are (docker):

```
mkdir -p /storage/network-services/openldap/ 

cd docker-openldap
make install 
```