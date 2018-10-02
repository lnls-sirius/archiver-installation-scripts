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
## GUI
Apache Directory Studio™<br>
Apache Directory Studio is a complete directory tooling platform intended to be used with any LDAP server however it is particularly designed for use with ApacheDS. It is an Eclipse RCP application, composed of several Eclipse (OSGi) plugins, that can be easily upgraded with additional ones. These plugins can even run within Eclipse itself.<br>
<href>https://directory.apache.org/studio/</href>