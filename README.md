# Apache_mysql_auth
A mod_python script to handle authentication through a mysql database to control who can access what on your Apache webserv. Short and simple, but it was easier making this than getting the dbd mods working the way I wanted them.

##Features
- Allows user and group specific access control
- Only one line needs to be added in apache config per restricted directory
- Simple to add new users and groups
- Include and exclude users and groups for fine grained control
- All the rules and complex stuff is in the database allowing you to manage it how you want (I'm currently working on a webscript to allow me to manage it all)

##Install
I'm going to write this later. It is late and I'm tired and I'll make a mistake now. But it'll cover setting up the database, installing mod_python, and the changes needed in the apache configs
