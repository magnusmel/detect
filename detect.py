#!/usr/bin/python

import os, sys, re, warnings, MySQLdb, getopt

def sanity_check():
    try:
        if not re.match("home[1-9]?", os.getcwd().split('/')[1]):
	    sys.exit("\nThis must be run within /home*\n")
    except IndexError:
	sys.exit("\nThis must be run within /home*\n")

def from_apache(path):
    conf = '/usr/local/apache/conf/httpd.conf'
    if not os.path.exists(conf):
	sys.exit("Unable to locate httpd.conf. Had to exit for safety...\n")
    f = open(conf)
    lines = [x.strip("\n") for x in f.readlines()]
    f.close()
    out = ''
    p = path
    while out == '':
        #p = p.replace('/$', '')
        for line in lines:
	    if re.search("%s$" % p, line):
	        out = lines[lines.index(line)-2].split()[1]
		out = "http://%s%s" %  (out, path.split(p)[1])
	p = '/'.join(p.split('/')[:-1])
	if (p == '/'):
	    out = 'Unable to be determined'
    return out

def wordpress(wp):
    out = ''
    wp = wp.split('wp-admin')[0]
    inc = "%swp-includes/version.php" % wp
    cfg = "%swp-config.php" % wp
    alt = '/'.join(wp.split('/')[:-1]) + 'wp-config.php'
    if not os.path.exists(cfg) and os.path.exists(alt):
	cfg = alt
    if os.path.exists(inc) and os.path.exists(cfg):
	[ver,url,dom,path,host,name,user,pswd,pre] = ['','','','','','','','','']
	f = open(cfg)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?define\( ?['\"]?DB_NAME", line):
		name = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
	    if re.match("( +)?(\t)?define\( ?['\"]?DB_USER", line):
		user = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
	    if re.match("( +)?(\t)?define\( ?['\"]?DB_HOST", line):
		host = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
	    if re.match("( +)?(\t)?define\( ?['\"]?DB_PASS", line):
		pswd = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
	    if re.match("( +)?(\t)?\$table_prefix", line):
		pre = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	f = open(inc)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	   if re.match("( +)?(\t)?\$wp_version = ", line):
		ver = line.split()[2].replace("'",'').replace('"','').replace(';','')
	if ver == '':
	    ver = 'Unknown'
	if host != 'localhost' and host != '127.0.0.1':
	    url = from_apache(wp)
	elif name == '' or pswd == '' or user == '':
	    url = from_apache(wp)
	else:
	    warnings.filterwarnings('ignore', category = MySQLdb.Warning)
	    qry = "SELECT option_value FROM %soptions WHERE option_name='siteurl'" % pre
	    try:
	        con = MySQLdb.connect(db="%s" % name,
	                              user="%s" % user,
	                              passwd="%s" % pswd)
	        cur = con.cursor()
	        cur.execute(qry)
	        url = cur.fetchall()[0][0]
	    except MySQLdb.Error, e:
	        url = from_apache(wp)
	    if 'cur' in vars(): cur.close()
	    if 'con' in vars(): con.close()
	out = "    %-75s%-10s%s\n" % (wp, ver, url)
    return out

def joomla(jml):
    out = ''
    jml = jml.split("libraries/joomla")[0]
    cfg = "%sconfiguration.php" % jml
    inc = "%slibraries/cms/version/version.php" % jml
    if os.path.exists(cfg) and os.path.exists(inc) and os.path.exists("%sadministrator" % jml):
        [ver,url,dom,path,host,name,user,pswd,pre] = ['','','','','','','','','']
	f = open(inc)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?public \$RELEASE", line):
		ver = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	if ver == '':
	    ver ='Unknown'
	f = open(cfg)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?public \$live_site", line):
		url = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	if url == '':
	    url = from_apache(jml)
	out = "    %-75s%-10s%s\n" % (jml, ver, url)
    return out

def magento(mag):
    out = ''
    mag = mag.split('pkginfo/Mage_All.txt')[0]
    cfg = "%sapp/etc/local.xml" % mag
    inc = "%sapp/Mage.php" % mag
    if os.path.exists(cfg) and os.path.exists(inc):
	[ver,url,dom,path,host,name,user,pswd,pre] = ['','','','','','','','','']
	f = open(cfg)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?\<username\>", line):
		user = line.split('[')[2].split(']')[0]
	    if re.match("( +)?(\t)?\<password\>", line):
		pswd = line.split('[')[2].split(']')[0]
	    if re.match("( +)?(\t)?\<dbname\>", line):
		name = line.split('[')[2].split(']')[0]
	    if re.match("( +)?(\t)?\<host\>", line):
                host = line.split('[')[2].split(']')[0]
            if re.match("( +)?(\t)?\<table_prefix\>", line):
                pre = line.split('[')[2].split(']')[0]
	f = open(inc)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?[\"']?minor", line):
		ver = line.split('=>')[1].replace(' ','').split(',')[0][1:-1]
	if ver == '':
	    ver = 'Unknown'
	else:
	    ver = "1.%s" % ver
        if host != 'localhost' and host != '127.0.0.1':
            url = from_apache(mag)
        elif name == '' or pswd == '' or user == '':
            url = from_apache(mag)
        else:
            warnings.filterwarnings('ignore', category = MySQLdb.Warning)
            qry = "SELECT value FROM %score_config_data WHERE path='web/unsecure/base_url'" % pre
            try:
                con = MySQLdb.connect(db="%s" % name,
                                      user="%s" % user,
                                      passwd="%s" % pswd)
                cur = con.cursor()
                cur.execute(qry)
                url = cur.fetchall()[0][0]
            except MySQLdb.Error, e:
                url = from_apache(mag)
            if 'cur' in vars(): cur.close()
            if 'con' in vars(): con.close()
        out = "    %-75s%-10s%s\n" % (mag, ver, url)
    return out

def drupal(drp):
    out = ''
    drp = drp.split('misc/drupal.js')[0]
    [ver,url,dom,path,host,name,user,pswd,pre] = ['','','','','','','','','']
    if os.path.exists("%sincludes/bootstrap.inc" % drp):
	f = open("%sincludes/bootstrap.inc" % drp)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?define\(['\"] ?VERSION", line):
		ver = line.split(', ')[1].replace(' ','').split(';')[0][1:-2]
    if os.path.exists("%smodules/system/system.module" % drp) and ver == '':
	f = open("%smodules/system/system.module" % drp)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?define\(['\"] ?VERSION", line):
		ver = line.split(', ')[1].replace(' ','').split(';')[0][1:-2]
    if ver == '':
	ver = 'Unknown'
    if os.path.exists("%ssites/default/settings.php" % drp) and os.path.exists("%smisc" % drp):
	url = from_apache(drp)
	out = "    %-75s%-10s%s\n" % (drp, ver, url)
    return out

def opencart(oc):
    out = ''
    oc = oc.split('catalog/controller/amazonus')[0]
    cfg = "%sconfig.php" % oc
    inc = "%sindex.php" % oc
    if os.path.exists(cfg) and os.path.exists(inc) and os.path.exists("%scatalog" % oc):
	[url,ver] = ['','']
	f = open(cfg)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?define\( ?['\"]HTTP_SERVER", line):
		url = line.split(',')[1].replace(' ','').split(')')[0][1:-1]
	if url == '':
	    url = from_apache(oc)
	f = open(inc)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?define\( ?['\"]VERSION", line):
		ver = line.split(',')[1].replace(' ','').split(')')[0][1:-1]
	if ver == '':
	    ver = 'Unknown'
	out = "    %-75s%-10s%s\n" % (oc, ver, url)
    return out

def mambo(mam):
    out = ''
    mam = mam.split('administrator/templates/mambo_admin')[0]
    cfg = "%sconfiguration.php" % mam
    inc = "%sincludes/version.php" % mam
    if os.path.exists(cfg) and os.path.exists(inc):
	[ver,url,maj,min] = ['','','','']
	f = open(cfg)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?\mosConfig_live_site", line):
		url = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	if url == '':
	    url = from_apache(mam)
	f = open(inc)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?var \$RELEASE", line):
		maj = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	    if re.match("( +)?(\t)?var \$DEV_LEVEL", line):
		min = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	if maj == '' or min == '':
	    ver = 'Unknown'
	else:
	    ver = "%s.%s" % (maj, min)
	out = "    %-75s%-10s%s\n" % (mam, ver, url)
    return out

def mybb_i(mybb):
    out = ''
    mybb = mybb.split('inc/mybb_group.php')[0]
    cfg = "%sinc/settings.php" % mybb
    inc = "%sindex.php" % mybb
    if os.path.exists(cfg) and os.path.exists(inc) and os.path.exists("%sinc/datahandlers" % mybb):
	[ver,url,dom,path,host,name,user,pswd,pre] = ['','','','','','','','','']
	f = open(cfg)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?\$settings['bburl']", line):
		url = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	if url == '':
	    url = from_apache(mybb)
	f = open(inc)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?\* MyBB", line):
		ver = line.split()[2]
	if ver == '':
	    ver = 'Unknown'
	out = "    %-75s%-10s%s\n" % (mybb, ver, url)
    return out

def whmcs(whm):
    out = ''
    whm = whm.split('templates/default/js/whmcs.js')[0]
    cfg = "%sconfiguration.php" % whm
    if os.path.exists(cfg) and os.path.exists("%sclientarea.php" % whm):
	[ver,url,dom,path,host,name,user,pswd,pre] = ['','','','','','','','','']
	f = open(cfg)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match ("( +)?(\t)?\$db_password", line):
		pswd = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
            if re.match ("( +)?(\t)?\$db_username", line):
		user = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
            if re.match ("( +)?(\t)?\$db_name", line):
		name = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
            if re.match ("( +)?(\t)?\$db_host", line):
		host = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
        if host != 'localhost' and host != '127.0.0.1':
            url = from_apache(whm)
        elif name == '' or pswd == '' or user == '':
            url = from_apache(whm)
        else:
            warnings.filterwarnings('ignore', category = MySQLdb.Warning)
            qry = "SELECT value FROM tblconfiguration WHERE setting='SystemURL'"
	    qry2 = "SELECT value FROM tblconfiguration WHERE setting='Version'"
            try:
                con = MySQLdb.connect(db="%s" % name,
                                      user="%s" % user,
                                      passwd="%s" % pswd)
                cur = con.cursor()
                cur.execute(qry)
                url = cur.fetchall()[0][0]
		cur.execute(qry2)
		ver = cur.fetchall()[0][0]
            except MySQLdb.Error, e:
                url = from_apache(whm)
            if 'cur' in vars(): cur.close()
            if 'con' in vars(): con.close()
	    if ver == '':
		ver = 'Unknown'
	out = "    %-75s%-10s%s\n" % (whm, ver, url)
    return out

def zencart(zen):
    out = ''
    zen = zen.split('docs/0.about_zen_cart.html')[0]
    inc = "%sincludes/version.php" % zen
    cfg = "%sincludes/configure.php" % zen
    if os.path.exists(inc) and os.path.exists(cfg):
	[ver,maj,min,url] = ['','','','']
	url = from_apache(zen)
	f = open(inc)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?define\(['\"]PROJECT_VERSION_MAJOR", line):
		maj = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
            if re.match("( +)?(\t)?define\(['\"]PROJECT_VERSION_MINOR", line):
		min = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
	if maj == '' or min == '':
	    ver = 'Unknown'
	else:
	    ver = "%s.%s" % (maj, min)
	out = "    %-75s%-10s%s\n" % (zen, ver, url)
    return out

def moodle(moo):
    out = ''
    moo = moo.split('lib/moodlelib.php')[0]
    cfg = "%sconfig.php" % moo
    inc = "%sversion.php" % moo
    if os.path.exists(cfg) and os.path.exists(inc):
	f = open(cfg)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?\$CFG->wwwroot", line):
		url = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	if url == '':
	    url = from_apache(moo)
	f = open(inc)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?\$release", line):
		ver = line.split('=')[1].replace(' ','').split('+')[0][1:]
	if ver == '':
	    ver = 'Unknown'
	out = "    %-75s%-10s%s\n" % (moo, ver, url)
    return out

def prestashop(ps):
    out = ''
    ps = ps.split('modules/gamification/prestashop.pub')[0]
    cfg = "%sconfig/settings.inc.php" % ps
    if os.path.exists("%sconfig" % ps) and os.path.exists(cfg) and os.path.exists("%scontrollers" % ps):
	[ver,url,host,name,user,pswd,pre] = ['','','','','','','']
	f = open(cfg)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?define\( ?['\"]_DB_USER_", line):
		user = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
            if re.match("( +)?(\t)?define\( ?['\"]_DB_PASSWD_", line):
		pswd = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
            if re.match("( +)?(\t)?define\( ?['\"]_DB_NAME_", line):
		name = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
            if re.match("( +)?(\t)?define\( ?['\"]_DB_SERVER_", line):
		host = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
            if re.match("( +)?(\t)?define\( ?['\"]_DB_PREFIX_", line):
		pre = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
        if host != 'localhost' and host != '127.0.0.1':
            url = from_apache(ps)
        elif name == '' or pswd == '' or user == '':
            url = from_apache(ps)
        else:
            warnings.filterwarnings('ignore', category = MySQLdb.Warning)
            qry = "SELECT domain,physical_uri FROM %sshop_url WHERE main=1" % pre
            qry2 = "SELECT value FROM %sconfiguration WHERE name='PS_INSTALL_VERSION'" % pre
            try:
                con = MySQLdb.connect(db="%s" % name,
                                      user="%s" % user,
                                      passwd="%s" % pswd)
                cur = con.cursor()
                cur.execute(qry)
                url = "http://%s%s" % (cur.fetchall()[0])
                cur.execute(qry2)
                ver = cur.fetchall()[0][0]
            except MySQLdb.Error, e:
                url = from_apache(ps)
            if 'cur' in vars(): cur.close()
            if 'con' in vars(): con.close()
            if ver == '':
                ver = 'Unknown'
        out = "    %-75s%-10s%s\n" % (ps, ver, url)
    return out

def tomatocart(tc):
    out = ''
    tc = tc.split('admin/external/devAnalogClock')[0]
    cfg = "%sincludes/configure.php" % tc
    inc = "%sincludes/application_top.php" % tc
    if os.path.exists(cfg) and os.path.exists(inc) and os.path.exists("%sincludes/work" % tc):
	[url,dom,path,ver] = ['','','','']
	f = open(cfg)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?define\( ?['\"]HTTP_SERVER", line):
		dom = line.split(',')[1].replace(' ','').split(')')[0][1:-1]
	    if re.match("( +)?(\t)?define\( ?['\"]HTTP_COOKIE_PATH", line):
		path = line.split(',')[1].replace(' ','').split(')')[0][1:-1]
	if dom == '':
	    url = from_apache(tc)
	else:
	    url = "%s%s" % (dom, path)
	f = open(inc)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?define\( ?['\"]PROJECT_VERSION", line):
		ver = line.split(',')[1].replace(' ','').split(')')[0][-8:-1]
	if ver == '':
	    ver = 'Unknown'
	out = "    %-75s%-10s%s\n" % (tc, ver, url)
    return out

def vtiger(vt):
    out = ''
    vt = vt.split('pkg/bin/uninstallvtiger.sh')[0]
    cfg = "%sconfig.inc.php" % vt
    inc = "%svtigerversion.php" % vt
    if os.path.exists(cfg) and os.path.exists(inc) and os.path.exists("%svtigercron.php" % vt):
	[url,ver] = ['','']
	f = open(cfg)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?\$site_URL", line):
		url = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	if url == '':
	    url = from_apache(vt)
	f = open(inc)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?\$vtiger_current_version", line):
		ver = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	if ver == '':
	    ver = 'Unknown'
	out = "    %-75s%-10s%s\n" % (vt, ver, url)
    return out

def pligg(pl):
    out = ''
    pl = pl.split('libs/api/Pligg-API-Installation.txt')[0]
    cfg = "%slibs/dbconnect.php" % pl
    inc = "%ssettings.php" % pl
    if os.path.exists(cfg) and os.path.exists(inc) and os.path.exists("%slibs/karma.php" % pl):
	[ver,url,dom,path,host,name,user,pswd,pre] = ['','','','','','','','','']
	f = open(inc)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?\$my_base_url", line):
		dom = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	    if re.match("( +)?(\t)?\$my_pligg_base", line):
		path = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	    if re.match("( +)?(\t)?define\( ?['\"]?table_prefix", line):
		pre = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
	if dom == '':
	    url = from_apache(pl)
	else:
	    url = "%s%s" % (dom, path)
	f = open(cfg)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?define\( ?['\"]?EZSQL_DB_USER", line):
		user = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
            if re.match("( +)?(\t)?define\( ?['\"]?EZSQL_DB_PASS", line):
		pswd = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
            if re.match("( +)?(\t)?define\( ?['\"]?EZSQL_DB_NAME", line):
		name = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
            if re.match("( +)?(\t)?define\( ?['\"]?EZSQL_DB_HOST", line):
		host = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
        if host != 'localhost' and host != '127.0.0.1':
            ver = 'Unknown'
        elif name == '' or pswd == '' or user == '':
            ver = 'Unknown'
        else:
            warnings.filterwarnings('ignore', category = MySQLdb.Warning)
            qry = "SELECT data FROM %smisc_data WHERE name='pligg_version'" % pre
            try:
                con = MySQLdb.connect(db="%s" % name,
                                      user="%s" % user,
                                      passwd="%s" % pswd)
                cur = con.cursor()
                cur.execute(qry)
                ver = cur.fetchall()[0][0]
            except MySQLdb.Error, e:
                ver = 'Unknown'
            if 'cur' in vars(): cur.close()
            if 'con' in vars(): con.close()
        out = "    %-75s%-10s%s\n" % (pl, ver, url)
    return out

def phpbb(bb):
    out = ''
    bb = bb.split('includes/bbcode.php')[0]
    cfg = "%sconfig.php" % bb
    inc = "%sincludes/constants.php" % bb
    if os.path.exists(cfg) and os.path.exists(inc) and os.path.exists("%sincludes/constants.php" % bb):
	[ver,url,dom,path,host,name,user,pswd,pre] = ['','','','','','','','','']
	f = open(cfg)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?\$dbuser", line):
		user = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	    if re.match("( +)?(\t)?\$dbpass", line):
		pswd = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	    if re.match("( +)?(\t)?\$dbname", line):
		name = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	    if re.match("( +)?(\t)?\$dbhost", line):
		host = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	    if re.match("( +)?(\t)?\$table_prefix", line):
		pre = line.split('=')[1].replace(' ','').split(';')[0][1:-1]
	f = open(inc)
	lines = [x.strip("\n") for x in f.readlines()]
	f.close()
	for line in lines:
	    if re.match("( +)?(\t)?define\( ?['\"]?PHPBB_VERSION", line):
		ver = line.split(', ')[1].replace(' ','').split(')')[0][1:-1]
        if host != 'localhost' and host != '127.0.0.1':
            url = from_apache(bb)
        elif name == '' or pswd == '' or user == '':
            url = from_apache(bb)
        else:
            warnings.filterwarnings('ignore', category = MySQLdb.Warning)
            qry = "SELECT config_value FROM %sconfig WHERE config_name='server_name'" % pre
	    qry2 = "SELECT config_value FROM %sconfig WHERE config_name='script_path'" % pre
            try:
                con = MySQLdb.connect(db="%s" % name,
                                      user="%s" % user,
                                      passwd="%s" % pswd)
                cur = con.cursor()
                cur.execute(qry)
                dom = cur.fetchall()[0][0]
		cur.execute(qry2)
		path = cur.fetchall()[0][0]
		url = "http://%s%s" % (dom, path)
		if url == 'http://':
		    url = from_apache(bb)
            except MySQLdb.Error, e:
                url = from_apache(wp)
            if 'cur' in vars(): cur.close()
            if 'con' in vars(): con.close()
        out = "    %-75s%-10s%s\n" % (bb, ver, url)
    return out

def find_stuff(args):
    [wp,jml,oc,mam,mybb,mag,drp,whm,zen,moo,ps,tc,vt,pl,bb] = ['','','','','','','','','','','','','','','']
    if args == '':
	sys.exit("\nSeems silly to look for absolutely nothing. Exiting cause I value my time...\n")
    reg="((.*)easyapache|virtfs|mail|(.*)cpan|cache|ima?ge?s?|tmp)"
    for pwd, dirs, files in os.walk(os.getcwd()):
	dirs[:] = [d for d in dirs if not re.match(reg, d)]
	for d in dirs:
	    d = os.path.join(pwd, d)
	    if re.search("/wp-admin$", d):
		wp += wordpress(d)
	    if re.search("/libraries/joomla$", d):
		jml += joomla(d)
            if re.search("/catalog/controller/amazonus$", d):
                oc += opencart(d)
            if re.search("mambo_admin$", d):
                mam += mambo(d)
	for f in files:
	    f = os.path.join(pwd, f)
	    if re.search("mybb_group.php$", f):
		mybb += mybb_i(f)
	    if re.search("Mage_All.txt$", f):
		mag += magento(f)
            if re.search("drupal.js$", f):
                drp += drupal(f)
            if re.search("whmcs.js$", f):
                whm += whmcs(f)
            if re.search("0.about_zen_cart.html$", f):
                zen += zencart(f)
            if re.search("moodlelib.php$", f):
                moo += moodle(f)
            if re.search("prestashop.pub$", f):
                ps += prestashop(f)
            if re.search("tomatocart_clock.png$", f):
                tc += tomatocart(f)
            if re.search("uninstallvtiger.sh$", f):
                vt += vtiger(f)
            if re.search("/bbcode.php$", f):
                bb += phpbb(f)
            if re.search("Pligg-API-Installation.txt$", f):
                pl += pligg(f)
    print ''
    for arg in set(list(args)):
	if arg == 'w':
            if wp != '': print "=" * 20, '\nWordPress\n', '=' * 20, '\n', wp
        if arg == 'j':
            if jml != '': print "=" * 20, '\nJoomla\n', '=' * 20, '\n', jml
        if arg == 'o':
            if oc != '': print "=" * 20, '\nOpenCart\n', '=' * 20, '\n', oc
        if arg == 'a':
            if mam != '': print "=" * 20, '\nMambo\n', '=' * 20, '\n', mam
        if arg == 'b':
            if mybb != '': print "=" * 20, '\nMyBB\n', '=' * 20, '\n', mybb
        if arg == 'M':
            if mag != '': print "=" * 20, '\nMagento\n', '=' * 20, '\n', mag
        if arg == 'd':
            if drp != '': print "=" * 20, '\nDrupal\n', '=' * 20, '\n', drp
        if arg == 'W':
            if whm != '': print "=" * 20, '\nWHMCS\n', '=' * 20, '\n', whm
        if arg == 'z':
            if zen != '': print "=" * 20, '\nZenCart\n', '=' * 20, '\n', zen
        if arg == 'm':
            if moo != '': print "=" * 20, '\nMoodle\n', '=' * 20, '\n', moo
        if arg == 'p':
            if ps != '': print "=" * 20, '\nPrestaShop\n', '=' * 20, '\n', ps
        if arg == 't':
            if tc != '': print "=" * 20, '\nTomatoCart\n', '=' * 20, '\n', tc
        if arg == 'v':
            if vt != '': print "=" * 20, '\nvTiger\n', '=' * 20, '\n', vt
        if arg == 'g':
            if pl != '': print "=" * 20, '\nPligg\n', '=' * 20, '\n', pl
        if arg == 'B':
            if bb != '': print "=" * 20, '\nphpBB\n', '=' * 20, '\n', bb

def show_help():
    print "\n    Usage: detect [options]"
    print "\n    Command line options available are:"
    print "\t-A,--all            Show all CMS Locations/Info"
    print "\t-w,--wordpress      Show WordPress CMS Locations/Info"
    print "\t-j,--joomla         Show Joomla CMS Locations/Info"
    print "\t-M,--magento        Show Magento CMS Locations/Info"
    print "\t-d,--drupal         Show Drupal CMS Locations/Info"
    print "\t-W,--whmcs          Show WHMCS CMS Locations/Info"
    print "\t-z,--zencart        Show ZenCart CMS Locations/Info"
    print "\t-m,--moodle         Show Moodle CMS Locations/Info"
    print "\t-p,--prestashop     Show PrestaShop CMS Locations/Info"
    print "\t-a,--mambo          Show Mambo CMS Locations/Info"
    print "\t-o,--opencart       Show OpenCart CMS Locations/Info"
    print "\t-v,--vtiger         Show vTiger CMS Locations/Info"
    print "\t-B,--phpbb          Show phpBB CMS Locations/Info"
    print "\t-t,--tomatocart     Show TomatoCart CMS Locations/Info"
    print "\t-b,--mybb           Show MyBB CMS Locations/Info"
    print "\t-g,--pligg          Show Pligg CMS Locations/Info"
    print "\n    Notes:"
    print "\tFor the best looking output, maximize your screen"
    print "\tThis runs from the present working directory:"
    print "\t\t%s\n" % os.getcwd()
    sys.exit()

def main():
    try:
	sanity_check()
	options = ''
	short = "AwjMdWzmpaovBtbgh"
	long = ['all', 'wordpress', 'joomla', 'magento', 'drupal', 'whmcs', 'zencart',
		'moodle', 'prestashop', 'mambo', 'opencart', 'vtiger', 'phpbb',
		'tomatocart', 'mybb', 'pligg', 'help']
	try:
	    opts, args = getopt.getopt(sys.argv[1:], short, long)
	except getopt.GetoptError as e:
	    print("\n%s...maybe try detect --help or detect -h" % e)
	    show_help()
	for o,a in opts:
            if o in ('-h', '--help'):
                show_help()
	    if o in ('-A', '--all'):
		options = "wjMdWzmpaovBtbg"
		break
	    if o in ('-w', '--wordpress'):
		options += "w"
            if o in ('-j', '--joomla'):
                options += "j"
            if o in ('-M', '--magento'):
                options += "M"
            if o in ('-d', '--drupal'):
                options += "d"
            if o in ('-W', '--whmcs'):
                options += "W"
            if o in ('-z', '--zencart'):
                options += "z"
            if o in ('-m', '--moodle'):
                options += "m"
            if o in ('-p', '--prestashop'):
                options += "p"
            if o in ('-a', '--mambo'):
                options += "a"
            if o in ('-o', '--opencart'):
                options += "o"
            if o in ('-v', '--vtiger'):
                options += "v"
            if o in ('-B', '--phpbb'):
                options += "B"
            if o in ('-t', '--tomatocart'):
                options += "t"
            if o in ('-b', '--mybb'):
                options += "b"
            if o in ('-g', '--pligg'):
                options += "g"
	find_stuff(options)
    except KeyboardInterrupt:
	sys.exit("\n")

main()
