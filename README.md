# Apache_mysql_auth
A mod_python script to handle authentication through a mysql database to control who can access what on your Apache webserv. Short and simple, but it was easier making this than getting the dbd mods working the way I wanted them.

##Features
- Allows user and group specific access control
- Only one line needs to be added in apache config per restricted directory
- Simple to add new users and groups
- Include and exclude users and groups for fine grained control
- All the rules and complex stuff is in the database allowing you to manage it how you want (I'm currently working on a webscript to allow me to manage it all)
- Works across multiple vhosts to allow simple control across multiple domains and directories

##Install
For this some basic sql knowledge and command line knowledge is useful.

####1. Clone
First clone the database, enter it, and move the authentication script to the /var/www directory (Works in debian, may need changing for other distros)<br>
```Bash
git clone https://github.com/CSmither/Apache_mysql_auth
cd Apache_mysql_auth
cp auth.py /var/www/
sudo chmod ug+rx /var/www/auth.py
sudo chown www-data:www-data /var/www/auth.py
```

####2. Set the password in the scripts
In `/var/www/auth.py` on line 12 there is the database connection information, here that password is currently set to *passwd*, but you will want to change it to something else. This is the password your apache process will use to access the auth database.
<br>You will then also need to change `passwd` after `IDENTIFIED BY`on line 3 of the DatabaseCreate.sql file to the same password as is now in auth.py.

####3. Create Database
Next, create the database. do by doing...<br>
```Bash
mysql -u root -p < DatabaseCreate.sql
```
It will ask for the mysql root user's password, just type it in and the sql script <i>should</i> create the database, tables, and triggers.

####4 Install mod_python
Most linux distributions have the mod_python package in their repos, in debian based systems it is called [libapache2-mod-python](https://packages.debian.org/search?keywords=libapache2-mod-python), in arch systems it is in aur and called [mod_python](https://wiki.archlinux.org/index.php/mod_python).<br>
Now just install it with</br>
```Bash
sudo apt-get install libapache2-mod-python
```
or whatever your distro requires...

####5 Configure apache
In your site's config file in the apache2 directory (`/etc/apache2/sites-enabled`) you need to insert the following lines (Assuming the Web Server files are based in /var/www/). The following will include any vhosts you have set up allowing your one system to work over all the sites you have.
```
<Directory /var/www/>
    AuthType Basic
    AuthBasicAuthoritative off
    PythonAuthenHandler auth
    PythonDebug On
    AuthName "Restricted Area"
</Directory>
```
This means that apache will pass authentication onto the modules it has loaded, registers mod_python as an authentication handler and names your restricted area as 'Restricted Area', but you can change the name if you want.
<br>
If you want to use python in pages on your site then take a look at the config options for mod_python on their site [HERE](http://modpython.org/live/current/doc-html/tutorial.html)

####6 set restricted directories
The directory tags above cover all sites and vhosts on the system. To actually set a directory as restricted you need to add the following tag for the directory you want to protect
```
<Directory /var/www/restrictedDir/>
    require valid-user
</Directory>
```
Change the path in the opening tag to match the directory you want to restrict access to. This will restrict access to that directory and any paths within that directory.

####7 Populate the database
This is easier in a gui sql tool such as mysql-workbench but can be done on command line as well. I am currently working on a web based system to allow the logins and location to be controlled interactively but I haven't finished it atm.
You will need to create a new entry in the Users table making sure to use mysql's md5() function to encrypt the password, all fields must be entered.

You will need to create a group if you want to use groups.

Next you can assign users to groups.

Next you can create a location. You should have at least a location for each directory you have specified in the site config, though you can specify sub directories allowing fine grained control.

Finally you can either allow or deny users or groups access to certain directories. The User/Group and Location **must** exist to do this or else you will get foreign key errors.
<br>Also **do not** specify the `priority` field, this is calculated by the sql trigger and allows the database to order the rules allowing the database to decide on access rights faster when people are using your sites.
<br>The `allowed` field should either be a ***1*** for access is allowed, or a ***0*** for access is denied.

#####8 Reload Apache2 service
Reload/Restart your apache service to apply the new configs. This can usually be done through init.d files, systemctl, or service.
```
sudo systemctl reload apache2
```

<br><br>
If I have missed anything out then feel free to message me or leave a comment on the README file and I'll see what I can do to help. Also you have any improvements that can be made then please please please suggest them.
