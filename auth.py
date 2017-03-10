#!/usr/bin/python
# -*- coding: UTF-8 -*-

from mod_python import apache
import mysql.connector


def authenhandler(req):
    pw = req.get_basic_auth_pw()
    user = req.user
    path = req.hostname+req.uri
    conn = mysql.connector.connect(database='webAuth', user='<USERNAME>', password='<PASSWORD>', charset='utf8mb4')
    db=conn.cursor()
    query = """
    SELECT allowed FROM (
        SELECT path,allowed FROM UserAccess where user=%s AND %s LIKE CONCAT( path, '%' )
        UNION ALL
        SELECT path,allowed FROM UserGroup, GroupAccess where user=%s AND UserGroup.group=GroupAccess.group AND %s LIKE CONCAT( path, '%' )
    ) as Access ORDER BY LENGTH(Access.path) DESC limit 1;
    """
    db.execute(query,(user,path,user,path))
    access=db.fetchone()
    if access==None:
        return apache.HTTP_UNAUTHORIZED
    db.close()
    conn.close()
    if access[0]==1:
       return apache.OK
    else:
       return apache.HTTP_UNAUTHORIZED
