#!/bin/bash

tabs 8
line='===================='
reg='(.*)?/?((.*)easyapache|virtfs|mail|(.*)cpan|cache|ima?ge?s?|tmp)/?(.*)?'
or='-type f -name wp-config.php -o -type f -name mybb_group.php -o -type f -name'
or="${or} Mage_All.txt -o -type f -name drupal.js -o -type f -name whmcs.js -o"
or="${or} -type f -name 0.about_zen_cart.html -o -type f -name moodlelib.php"
or="${or} -o -type f -name prestashop.pub -o -type d -name mambo_admin -o"
or="${or} -type f -name tomatocart_clock.png  -o -type f -name"
or="${or} uninstallvtiger.sh -o -type f -name bbcode.php -o -type f -name"
or="${or} Pligg-API-Installation.txt"
http=$(ps -ef|awk '/apache/ && $0 !~ "awk" {print $8; exit}')
if [ -z "$http" ]; then
        echo "Apache does not appear to be running, exiting for safety..."
	exit
fi
home=$(pwd|cut -d/ -f2)
if [[ ! "${home}" =~ home[1-9]? ]]; then
    echo "This has to be run somewhere within /home*"
    exit 1
fi
apache=$($http -V|awk -F\" '/ROOT/ {print $2}')
conf=$($http -V|awk -F\" '/SERVER_CONFIG/ {print $2}')
conf="$apache/$conf"

function show_help {
    echo -e "\nUsage:\tdetect.sh [options]"
    echo -e "\nCommand line options available are:"
    printf "    %-20s%s\n" "-A,--all" "Show all CMS Locations/Info"
    printf "    %-20s%s\n" "-w,--wordpress" "Show WordPress CMS Locations/Info"
    printf "    %-20s%s\n" "-j,--joomla" "Show Joomla CMS Locations/Info"
    printf "    %-20s%s\n" "-M,--magento" "Show Magento CMS Locations/Info"
    printf "    %-20s%s\n" "-d,--drupal" "Show Drupal CMS Locations/Info"
    printf "    %-20s%s\n" "-W,--whmcs" "Show WHMCS CMS Locations/Info"
    printf "    %-20s%s\n" "-z,--zencart" "Show ZenCart CMS Locations/Info"
    printf "    %-20s%s\n" "-m,--moodle" "Show Moodle CMS Locations/Info"
    printf "    %-20s%s\n" "-p,--prestashop" "Show PrestaShop CMS Locations/Info"
    printf "    %-20s%s\n" "-a,--mambo" "Show Mambo CMS Locations/Info"
    printf "    %-20s%s\n" "-o,--opencart" "Show OpenCart CMS Locations/Info"
    printf "    %-20s%s\n" "-v,--vtiger" "Show vTiger CMS Locations/Info"
    printf "    %-20s%s\n" "-B,--phpbb" "Show phpBB CMS Locations/Info"
    printf "    %-20s%s\n" "-t,--tomatocart" "Show TomatoCart CMS Locations/Info"
    printf "    %-20s%s\n" "-b,--mybb" "Show MyBB CMS Locations/Info"
    printf "    %-20s%s\n" "-g,--pligg" "Show Pligg CMS Locations/Info"; 
    echo -e "Notes:\n\tEntering duplicate options shows them duplicate times"
    echo -e "\tFor the best looking output, maximize your screen"
    echo -e "\tThis runs from the present working directory:\n\t\t$PWD\n\n"; }

function from_apache {
    cms=$1
    name=''
    path=$(echo ${cms}|sed s~/$~~)
    while [ -z "${name}" ]; do
	name=$(awk -v d=" ${path}[^/]" '/<VirtualHost/{b="";f=1} f{b = b $0 ORS} /<\/VirtualHost/{ if (f && (b ~ d)) print b; f=0}' $conf|awk '/ServerName/ {print $2}')
	if [ -z "${name}" ]; then
	    path=$(echo ${path}|awk -F/ '{for (i=1;i<NF;i++) printf $i"/"}{print ""}'|sed s~/$~~)
	fi
	if [ -z "${path}" ]; then
	    url='Unable to be determined'
	    break
	fi
    done
    if [ "${url}" != 'Unable to be determined' -a -n "${name}" ]; then
	url="http://${name}$(echo ${cms}|awk -F"${path}" '{print $2}'|sed s~/$~~)"
    elif [ -z "${url}" ]; then
	url='Unable to be determined'
    fi
    echo "${url}"; }

function wordpress {
    wp=$1
    cfg="${wp}"
    wp=$(echo ${wp}|awk -F/ '{for (i=1;i<NF;i++) printf $i"/"}')
    inc="${wp}wp-includes/version.php"
    if [ -d "${wp}wp-admin" -a -f "${inc}" ]; then
	ver=$(awk -F\' '/^\$wp_v/ {print $2}' ${inc})
	if [ -z "${ver}" ]; then
	    ver="Unknown"
	fi
        user=$(awk -F\' '$1 !~ "^( )+?[#/]" && /DB_USER/ {print $4}' ${cfg})
        pass=$(awk -F\' '$1 !~ "^( )+?[#/]" && /DB_PASS/ {print $4}' ${cfg})
        db=$(awk -F\' '$1 !~ "^( )+?[#/]" && /DB_NAME/ {print $4}' ${cfg})
        host=$(awk -F\' '$1 !~ "^( )+?[#/]" && /DB_HOST/ {print $4}' ${cfg})
        pre=$(awk -F"'" '$1 !~ "^( )+?[#/]" && /_pre/ {print $2}' ${cfg})
        if [ "${host}" != 'localhost' -a "${host}" != '127.0.0.1' ]; then
	    url="$(from_apache ${wp})"
	elif [ -z "${user}" -o -z "${pass}" -o -z "${db}" -o -z "${host}" ]; then
            url="$(from_apache ${wp})"
	else
	    qry="SELECT option_value FROM ${pre}options WHERE option_name='siteurl'"
	    url=$(mysql -u ${user} -p${pass} ${db} -e "${qry}" -ss 2>/dev/null)
	    if [ -z "${url}" ]; then
		url="$(from_apache ${wp})"
	    fi
	fi
	printf "\n    %-75s%-10s%s\n" "${wp}" "${ver}" "${url}"
    fi; }

function joomla {
    jml=$1
    jml=$(echo ${jml}|awk -F/ '{for (i=1;i<NF-1;i++) printf $i"/"}')
    cfg="${jml}configuration.php"
    inc="${jml}libraries/cms/version/version.php"
    if [ -f "${inc}" -a -f "${cfg}" -a -d "${jml}administrator" ]; then
	ver=$(awk -F\' '/public \$RELEASE = / {print $2}' ${inc})
        if [ -z "${ver}" ]; then
            ver="Unknown"
        fi
        user=$(awk -F\' '$1 !~ "^( )+?[#/]" && /\$user/ {print $2}' ${cfg})
        pass=$(awk -F\' '$1 !~ "^( )+?[#/]" && /\$pass/ {print $2}' ${cfg})
        db=$(awk -F\' '$1 !~ "^( )+?[#/]" && /\$db\ / {print $2}' ${cfg})
        host=$(awk -F\' '$1 !~ "^( )+?[#/]" && /\$host/ {print $2}' ${cfg})
        pre=$(awk -F\' '$1 !~ "^( )+?[#/]" && /\$dbpre/ {print $2}' ${cfg})
        if [ "${host}" != 'localhost' -a "${host}" != '127.0.0.1' ]; then
            url="$(from_apache ${jml})"
        elif [ -z "${user}" -o -z "${pass}" -o -z "${db}" -o -z "${host}" ]; then
            url="$(from_apache ${jml})"
        else
            url=$(awk -F\' '$1 !~ "^[#/]" && /\$live_site/ {print $2}' ${cfg})
            if [ -z "${url}" ]; then
		url="$(from_apache ${jml})"
            fi
        fi
        printf "\n    %-75s%-10s%s\n" "${jml}" "${ver}" "${url}"
    fi; }

function magento {
    mag=$1
    mag=$(echo ${mag}|awk -F/ '{for (i=1;i<NF-1;i++) printf $i"/"}')
    cfg="${mag}app/etc/local.xml"
    inc="${mag}app/Mage.php"
    if [ -f "${inc}" -a -f "${cfg}" ]; then
	user=$(awk -F\[ '/<username>/ {print $3}' ${cfg}|cut -d\] -f1)
        pass=$(awk -F\[ '/<password>/ {print $3}' ${cfg}|cut -d\] -f1)
        db=$(awk -F\[ '/<dbname>/ {print $3}' ${cfg}|cut -d\] -f1)
        host=$(awk -F\[ '/<host>/ {print $3}' ${cfg}|cut -d\] -f1)
        pre=$(awk -F\[ '/<table_prefix>/ {print $3}' ${cfg}|cut -d\] -f1)
        ver=$(awk -F\' '/minor/ && $4 ~ "[0-9]" {print $4}' ${inc})
        if [ -z "${ver}" ]; then
            ver='Unknown'
        else
            ver="1.${ver}"
        fi
        if [ "${host}" != 'localhost' -a "${host}" != '127.0.0.1' ]; then
            url="$(from_apache ${mag})"
        elif [ -z "${user}" -o -z "${pass}" -o -z "${db}" -o -z "${host}" ]; then
            url="$(from_apache ${mag})"
        else
            qry="SELECT value FROM ${pre}core_config_data WHERE path='web/unsecure/base_url'"
            url=$(mysql -u ${user} -p${pass} ${db} -e "${qry}" -ss 2>/dev/null)
            if [ -z "${url}" ]; then
                url="$(from_apache ${mag})"
            fi
	fi
        printf "\n    %-75s%-10s%s\n" "${mag}" "${ver}" "${url}"
    fi; }

function drupal {
    drp=$1
    drp=$(echo ${drp}|awk -F/ '{for (i=1;i<NF-1;i++) printf $i"/"}')
    if [ -f "${drp}includes/bootstrap.inc" ]; then
        ver=$(awk -F\' '/VERSION/ && $1 ~ "^def" {print $4}' ${drp}includes/bootstrap.inc)
    fi
    if [ -f "${drp}modules/system/system.module" -a -z "${ver}" ]; then
        ver=$(awk -F\' '/VERSION/ {print $4}' ${drp}modules/system/system.module)
    fi
    if [ -z "${ver}" ]; then
        ver='Unknown'
    fi
    if [ -f "${drp}sites/default/settings.php" -a -d "${drp}misc" ]; then
	url="$(from_apache ${drp})"
	printf "\n    %-75s%-10s%s\n" "${drp}" "${ver}" "${url}"
    fi; }

function whmcs {
    whmcs=$1
    whmcs=$(echo $whmcs|awk -F/ '{for (i=1;i<NF-3;i++) printf $i"/"}')
    cfg="${whmcs}configuration.php"
    if [ -f "${cfg}" ]; then
        user=$(awk -F\' '$1 !~ "^( )+?[#/]" && /db_username/ {print $2}' ${cfg})
        pass=$(awk -F\' '$1 !~ "^( )+?[#/]" && /db_password/ {print $2}' ${cfg})
        db=$(awk -F\' '$1 !~ "^( )+?[#/]" && /db_name/ {print $2}' ${cfg})
        host=$(awk -F\' '$1 !~ "^( )+?[#/]" && /db_host/ {print $2}' ${cfg})
        if [ "${host}" != 'localhost' -a "${host}" != '127.0.0.1' ]; then
            url="$(from_apache ${whmcs})"
        elif [ -z "${user}" -o -z "${pass}" -o -z "${db}" -o -z "${host}" ]; then
            url="$(from_apache ${whmcs})"
        else
            qry="SELECT value FROM tblconfiguration WHERE setting='Version'"
            ver=$(mysql -u ${user} -p${pass} ${db} -e "${qry}" -ss 2>/dev/null)
            qry="SELECT value FROM tblconfiguration WHERE setting='SystemURL'"
            url=$(mysql -u ${user} -p${pass} ${db} -e "${qry}" -ss 2>/dev/null)
            if [ -z "${url}" ]; then
                url="$(from_apache ${whmcs})"
            fi
            if [ -z "${ver}" ]; then
                ver='Unknown'
            fi
	fi
        printf "\n    %-75s%-10s%s\n" "${whmcs}" "${ver}" "${url}"
    fi; }

function zencart {
    zen=$1
    zen=$(echo ${zen}|awk -F/ '{for (i=1;i<NF-1;i++) printf $i"/"}')
    inc="${zen}includes/version.php"
    cfg="${zen}includes/configure.php"
    if [ -f "${cfg}" -a -f "${inc}" ]; then
        url="$(from_apache ${zen})"
        maj=$(awk -F\' '$1 !~ "^( )+?[#/]" && /PROJECT_VERSION_MAJOR/ {print $4}' ${inc})
        min=$(awk -F\' '$1 !~ "^( )+?[#/]" && /PROJECT_VERSION_MINOR/ {print $4}' ${inc})
        if [ -z "${maj}" -o -z "${min}" ]; then
            ver='Unknown'
        else
            ver="${maj}.${min}"
        fi
        printf "\n    %-75s%-10s%s\n" "${zen}" "${ver}" "${url}"
    fi; }

function moodle {
    mood=$1
    mood=$(echo ${mood}|awk -F/ '{for (i=1;i<NF-1;i++) printf $i"/"}')
    cfg="${mood}config.php"
    inc="${mood}version.php"
    if [ -f "${cfg}" -a -f "${inc}" ]; then
	url=$(awk -F\' '$1 !~ "^( )+?[#/]" && /wwwroot/ {print $2}' ${cfg})
        ver=$(awk -F\' '$1 !~ "^( )+?[#/]" && /\$release/ {print $2}' ${inc}|cut -d\+ -f1)
        if [ -z "${ver}" ]; then
            ver='Unknown'
        fi
        if [ -z "${url}" ]; then
            url="$(from_apache ${mood})"
        fi
        printf "\n    %-75s%-10s%s\n" "${mood}" "${ver}" "${url}"
    fi; }

function prestashop {
    ps=$1
    ps=$(echo ${ps}|awk -F/ '{for (i=1;i<NF-2;i++) printf $i"/"}')
    cfg="${ps}config/settings.inc.php"
    if [ -d "${ps}config" -a -f "${cfg}" -a -d "${ps}controllers" ]; then
	user=$(awk -F\' '$1 !~ "^( )+?[#/]" && /_DB_USER_/ {print $4}' ${cfg})
        pass=$(awk -F\' '$1 !~ "^( )+?[#/]" && /_DB_PASSWD_/ {print $4}' ${cfg})
        db=$(awk -F\' '$1 !~ "^( )+?[#/]" && /_DB_NAME_/ {print $4}' ${cfg})
        host=$(awk -F\' '$1 !~ "^( )+?[#/]" && /_DB_SERVER_/ {print $4}' ${cfg})
	pre=$(awk -F\' '$1 !~ "^( )+?[#/]" && /_DB_PREFIX_/ {print $4}' ${cfg})
        if [ "${host}" != 'localhost' -a "${host}" != '127.0.0.1' ]; then
            url="$(from_apache ${ps})"
            ver='Unknown'
        elif [ -z "${user}" -o -z "${pass}" -o -z "${db}" -o -z "${host}" ]; then
            url="$(from_apache ${ps})"
            ver='Unknown'
        else
            qry="SELECT value FROM ${pre}configuration WHERE name='PS_INSTALL_VERSION'"
            ver=$(mysql -u ${user} -p${pass} ${db} -e "${qry}" -ss 2>/dev/null)
            qry="SELECT domain,physical_uri FROM ${pre}shop_url WHERE main=1"
            url=$(mysql -u ${user} -p${pass} ${db} -e "${qry}" -ss 2>/dev/null|awk '{print "http://"$1$2}')
            if [ -z "${ver}" ]; then
                ver='Unknown'
            fi
            if [ "${url}" == 'http://' -o "${url}" == 'http:///' ]; then
                url="$(from_apache ${ps})"
            fi
        fi
        printf "\n    %-75s%-10s%s\n" "${ps}" "${ver}" "${url}"
    fi; }

function mambo {
    mambo=$1
    mambo=$(echo ${mambo}|awk -F/ '{for (i=1;i<NF-2;i++) printf $i"/"}')
    cfg="${mambo}configuration.php"
    inc="${mambo}includes/version.php"
    if [ -f "${cfg}" -a -f "${inc}" ]; then
        url=$(awk -F\' '$1 !~ "^( )+?[#/]" && /mosConfig_live_site/ {print $2}' ${cfg})
        maj=$(awk -F\' '$1 !~ "^( )+?[#/]" && /\$RELEASE/ {print $2}' ${inc})
        min=$(awk -F\' '$1 !~ "^( )+?[#/]" && /\$DEV_LEVEL/ {print $2}' ${inc})
        if [ -z "${maj}" -o -z "${min}" ]; then
            ver='Unknown'
        else
            ver="${maj}.${min}"
        fi
        if [ -z "${url}" ]; then
            url="$(from_apache ${mambo})"
        fi
        printf "\n    %-75s%-10s%s\n" "${mambo}" "${ver}" "${url}"
    fi; }

function opencart {
    oc=$1
    oc=$(echo ${oc}|awk -F/ '{for (i=1;i<NF-2;i++) printf $i"/"}')
    cfg="${oc}config.php"
    inc="${oc}index.php"
    if [ -d "${oc}catalog" -a -f "${cfg}" -a -f "${inc}" ]; then
        url=$(awk -F\' '$1 !~ "^( )+?[#/]" && /HTTP_SERVER/ {print $4}' ${cfg})
        ver=$(awk -F\' '$1 !~ "^( )+?[#/]" && /VERSION/ {print $4}' ${inc})
        if [ -z "${ver}" ]; then
            ver='Unknown'
        fi
        if [ -z "${url}" ]; then
            url="$(from_apache ${oc})"
        fi
        printf "\n    %-75s%-10s%s\n" "${oc}" "${ver}" "${url}"
    fi; }

function vtiger {
    vt=$1
    vt=$(echo ${vt}|awk -F/ '{for (i=1;i<NF-2;i++) printf $i"/"}')
    cfg="${vt}config.inc.php"
    inc="${vt}vtigerversion.php"
    if [ -f "${cfg}" -a -f "${inc}" -a -f "${vt}vtigercron.php" ]; then
        url=$(awk -F\' '$1 !~ "^( )+?[#/]" && /site_URL/ {print $2}' ${cfg})
        ver=$(awk -F\' '$1 !~ "^( )+?[#/]" && /\$vtiger_current_version[^;]/ {print $2}' ${inc})
        if [ -z "${url}" ]; then
            url="$(from_apache ${vt})"
        fi
        if [ -z "${ver}" ]; then
            ver='Unknown'
        fi
        printf "\n    %-75s%-10s%s\n" "${vt}" "${ver}" "${url}"
    fi; }

function phpbb {
    phpbb=$1
    phpbb=$(echo ${phpbb}|awk -F/ '{for (i=1;i<NF-1;i++) printf $i"/"}')
    cfg="${phpbb}config.php"
    inc="${phpbb}includes/constants.php"
    if [ -f "${cfg}" -a -f "${inc}" -a -f "${phpbb}includes/constants.php" ]; then
        user=$(awk -F\' '$1 !~ "^( )+?[#/]" && /dbuser/ {print $2}' ${cfg})
        pass=$(awk -F\' '$1 !~ "^( )+?[#/]" && /dbpass/ {print $2}' ${cfg})
        db=$(awk -F\' '$1 !~ "^( )+?[#/]" && /dbname/ {print $2}' ${cfg})
        host=$(awk -F\' '$1 !~ "^( )+?[#/]" && /dbhost/ {print $2}' ${cfg})
        pre=$(awk -F\' '$1 !~ "^( )+?[#/]" && /prefix/ {print $2}' ${cfg})
        if [ "${host}" != 'localhost' -a "${host}" != '127.0.0.1' ]; then
            url="$(from_apache ${phpbb})"
        elif [ -z "${user}" -o -z "${pass}" -o -z "${db}" -o -z "${host}" ]; then
            url="$(from_apache ${phpbb})"
        else
            qry="SELECT config_value FROM ${pre}config WHERE config_name='server_name'"
            dom=$(mysql -u ${user} -p${pass} ${db} -e "${qry}" -ss 2>/dev/null)
            qry="SELECT config_value FROM ${pre}config WHERE config_name='script_path'"
            path=$(mysql -u ${user} -p${pass} ${db} -e "${qry}" -ss 2>/dev/null)
            url="${dom}${path}"
            if [ -z "${url}" ]; then
                url="$(from_apache ${phpbb})"
            else
                url="http://${url}"
            fi
        fi
        ver=$(awk -F\' '$1 !~ "^( )+?[#/]" && /PHPBB_VERSION/ {print $4}' ${inc})
        if [ -z "${ver}" ]; then
            ver='Unknown'
        fi
        printf "\n    %-75s%-10s%s\n" "${phpbb}" "${ver}" "${url}"
    fi; }

function tomatocart {
    tc=$1
    tc=$(echo ${tc}|awk -F/ '{for (i=1; i<NF-5;i++) printf $i"/"}')
    cfg="${tc}includes/configure.php"
    inc="${tc}includes/application_top.php"
    if [ -d "${tc}includes/work" -a -f "${cfg}"  -a -f "${inc}" ]; then
        dom=$(awk -F\' '$1 !~ "^( )+?[#/]" && /HTTP_SERVER/ {print $4}' ${cfg})
        path=$(awk -F\' '$1 !~ "^( )+?[#/]" && /HTTP_COOKIE_PATH/ {print $4}' ${cfg})
        ver=$(awk -F\' '$1 !~ "^( )+?[#/]" && /PROJECT_VERSION/ {print $4}' ${inc}|cut -dv -f2)
        if [ -z "${dom}" ]; then
            url="$(from_apache ${tc})"
        else
            url="${dom}${path}"
        fi
        if [ -z "${ver}" ]; then
            ver='Unknown'
        fi
        printf "\n    %-75s%-10s%s\n" "${tc}" "${ver}" "${url}"
    fi; }

function mybb {
    mybb=$1
    mybb=$(echo ${mybb}|awk -F/ '{for (i=1;i<NF-1;i++) printf $i"/"}')
    cfg="${mybb}inc/settings.php"
    inc="${mybb}index.php"
    if [ -d "${mybb}inc/datahandlers" -a -f "${cfg}" -a -f "${inc}" ]; then
        url=$(awk -F\" '$1 !~ "^( )+?[#/]" && /bburl/ {print $2}' ${cfg})
        ver=$(awk '/* MyBB/ {print $3}' ${inc})
        if [ -z "${url}" ]; then
            url="$(from_apache ${mybb})"
        fi
        if [ -z "${ver}" ]; then
            ver='Unknown'
        fi
        printf "\n    %-75s%-10s%s\n" "${mybb}" "${ver}" "${url}"
    fi; }

function pligg {
    pligg=$1
    pligg=$(echo ${pligg}|awk -F/ '{for (i=1;i<NF-2;i++) printf $i"/"}')
    cfg="${pligg}libs/dbconnect.php"
    inc="${pligg}settings.php"
    if [ -f "${pligg}libs/karma.php" -a -f "${cfg}" -a -f "${inc}" ]; then
        dom=$(awk -F\' '$1 !~ "^( )+?[#/]" && /my_base_url/ {print $2}' ${inc})
        path=$(awk -F\' '$1 !~ "^( )+?[#/]" && /my_pligg_base/ {print $2}' ${inc})
        if [ -z "${dom}" ]; then
            url="$(from_apache ${pligg})"
        else
            url="${dom}${path}"
        fi
        user=$(awk -F\' '$1 !~ "^( )+?[#/]" && /DB_USER/ {print $2}' ${cfg})
        pass=$(awk -F\' '$1 !~ "^( )+?[#/]" && /DB_PASS/ {print $2}' ${cfg})
        db=$(awk -F\' '$1 !~ "^( )+?[#/]" && /DB_NAME/ {print $2}' ${cfg})
        host=$(awk -F\' '$1 !~ "^( )+?[#/]" && /DB_HOST/ {print $2}' ${cfg})
        pre=$(awk -F\' '$1 !~ "^( )+?[#/]" && /table_pre/ {print $4}' ${inc})
        if [ "${host}" != 'localhost' -a "${host}" != '127.0.0.1' ]; then
            ver='Unknown'
        elif [ -z "${user}" -o -z "${pass}" -o -z "${db}" -o -z "${host}" ]; then
            ver='Unknown'
        else
            qry="SELECT data FROM ${pre}misc_data WHERE name = 'pligg_version'"
            ver=$(mysql -u ${user} -p${pass} ${db} -e "${qry}" -ss 2>/dev/null)
            if [ -z "${ver}" ]; then
                ver='Unknown'
            fi
        fi
        printf "\n    %-75s%-10s%s\n" "${pligg}" "${ver}" "${url}"
    fi; }

function find_stuff {
    for cms in $(find $PWD \( -regextype posix-egrep -regex "${reg}" \) -prune -o \( ${or} -o -path "*/libraries/joomla" -o -path "*/catalog/controller/amazonus" \) -print); do
	case ${cms} in
	    *wp-config.php)
		wp="${wp}$(wordpress ${cms})"
		;;
	    *joomla)
		jml="${jml}$(joomla ${cms})"
		;;
	    *Mage_All.txt)
		mag="${mag}$(magento ${cms})"
		;;
	    *drupal.js)
		drp="${drp}$(drupal ${cms})"
		;;
	    *whmcs.js)
		whm="${whm}$(whmcs ${cms})"
		;;
	    *0.about_zen_cart.html)
		zen="${zen}$(zencart ${cms})"
		;;
	    *moodlelib.php)
		moo="${moo}$(moodle ${cms})"
		;;
	    *prestashop.pub)
		pre="${pre}$(prestashop ${cms})"
		;;
	    *mambo_admin)
		mam="${mam}$(mambo ${cms})"
		;;
	    *amazonus)
		oc="${oc}$(opencart ${cms})"
		;;
	    *uninstallvtiger.sh)
		vt="${vt}$(vtiger ${cms})"
		;;
	    *bbcode.php)
		bb="${bb}$(phpbb ${cms})"
		;;
	    *tomatocart_clock.png)
		tc="${tc}$(tomatocart ${cms})"
		;;
	    *mybb_group.php)
		my="${my}$(mybb ${cms})"
		;;
	    *Pligg-API-Installation.txt)
		pl="${pl}$(pligg ${cms})"
		;;
	esac
    done
}
long='wordpress,joomla,magento,drupal,whmcs,zencart,moodle,'
long="${long}prestashop,mambo,opencart,vtiger,phpbb,tomatocart,mybb,pligg"
if [ "$@" == '-A' -o "$@" == '--all' ]; then
    vars='-wjMdWzmpaovBtbg'
else
    vars="$@"
fi
TEMP=$(getopt -q -o wjMdWzmpaovBtbg --long ${long} -n 'detect.sh' -- "$vars")
if [ $? -ne 0 ]; then
    show_help
    exit 1
fi
if [ -z $@ ]; then
    show_help
    exit 1
fi
out=''
eval set -- "$TEMP"
find_stuff
while true; do
    case "$1" in
	-w|--wordpress)
	    if [ -n "${wp}" ]; then echo -e "\n${line}\n\tWordPress\n${line}${wp}"; fi
	    shift
	    ;;
        -j|--joomla)
            if [ -n "${jml}" ]; then echo -e "\n${line}\n\tJoomla\n${line}${jml}"; fi
	    shift
            ;;
        -M|--magento)
            if [ -n "${mag}" ]; then echo -e "\n${line}\n\tMagento\n${line}${mag}"; fi
	    shift
            ;;
        -d|--drupal)
            if [ -n "${drp}" ]; then echo -e "\n${line}\n\tDrupal\n${line}${drp}"; fi
            shift
            ;;
        -W|--whmcs)
            if [ -n "${whm}" ]; then echo -e "\n${line}\n\tWHMCS\n${line}${whm}"; fi
            shift
            ;;
        -z|--zencart)
            if [ -n "${zen}" ]; then echo -e "\n${line}\n\tZenCart\n${line}${zen}"; fi
            shift
            ;;
        -m|--moodle)
            if [ -n "${moo}" ]; then echo -e "\n${line}\n\tMoodle\n${line}${moo}"; fi
            shift
            ;;
        -p|--prestashop)
            if [ -n "${pre}" ]; then echo -e "\n${line}\n\tPrestashop\n${line}${pre}"; fi
            shift
            ;;
        -a|--mambo)
            if [ -n "${mam}" ]; then echo -e "\n${line}\n\tMambo\n${line}${mam}"; fi
            shift
            ;;
        -o|--opencart)
            if [ -n "${oc}" ]; then echo -e "\n${line}\n\tOpenCart\n${line}${oc}"; fi
            shift
            ;;
        -v|--vtiger)
            if [ -n "${vt}" ]; then echo -e "\n${line}\n\tvTiger\n${line}${vt}"; fi
            shift
            ;;
        -B|--phpbb)
            if [ -n "${bb}" ]; then echo -e "\n${line}\n\tphpBB\n${line}${bb}"; fi
            shift
            ;;
        -t|--tomatocart)
            if [ -n "${tc}" ]; then echo -e "\n${line}\n\tTomatoCart\n${line}${tc}"; fi
            shift
            ;;
        -b|--mybb)
            if [ -n "${my}" ]; then echo -e "\n${line}\n\tMyBB\n${line}${my}"; fi
            shift
            ;;
        -g|--pligg)
            if [ -n "${pl}" ]; then echo -e "\n${line}\n\tPligg\n${line}${pl}"; fi
            shift
            ;;
	--)
	    shift
	    break
	    ;;
    esac
done
echo
