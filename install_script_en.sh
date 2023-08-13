#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# System Required: CentOS 7+/Ubuntu 18+/Debian 10+
# Version: v2.1.6
# Description: One click Install Trojan Panel server
# Author: jonssonyan <https://jonssonyan.com>
# Github: https://github.com/trojanpanel/install-script

init_var() {
  ECHO_TYPE="echo -e"

  package_manager=""
  release=""
  get_arch=""
  can_google=0

  # Docker
  DOCKER_MIRROR='"https://hub-mirror.c.163.com","https://ccr.ccs.tencentyun.com","https://mirror.baidubce.com","https://dockerproxy.com"'

  # project directory
  TP_DATA="/tpdata/"

  STATIC_HTML="https://github.com/trojanpanel/install-script/releases/download/v1.0.0/html.tar.gz"

  # web
  WEB_PATH="/tpdata/web/"

  # cert
  CERT_PATH="/tpdata/cert/"
  DOMAIN_FILE="/tpdata/domain.lock"
  domain=""
  crt_path=""
  key_path=""

  # Caddy
  CADDY_DATA="/tpdata/caddy/"
  CADDY_CONFIG="${CADDY_DATA}config.json"
  CADDY_LOG="${CADDY_DATA}logs/"
  CADDY_CERT_DIR="${CERT_PATH}certificates/acme-v02.api.letsencrypt.org-directory/"
  caddy_port=80
  caddy_remote_port=8863
  your_email=""
  ssl_option=1
  ssl_module_type=1
  ssl_module="acme"

  # Nginx
  NGINX_DATA="/tpdata/nginx/"
  NGINX_CONFIG="${NGINX_DATA}default.conf"
  nginx_port=80
  nginx_remote_port=8863
  nginx_https=1

  # MariaDB
  MARIA_DATA="/tpdata/mariadb/"
  mariadb_ip="127.0.0.1"
  mariadb_port=9507
  mariadb_user="root"
  mariadb_pas=""

  #Redis
  REDIS_DATA="/tpdata/redis/"
  redis_host="127.0.0.1"
  redis_port=6378
  redis_pass=""

  # Trojan Panel Fron-tend
  TROJAN_PANEL_UI_DATA="/tpdata/trojan-panel-ui/"
  # Nginx
  UI_NGINX_DATA="${TROJAN_PANEL_UI_DATA}nginx/"
  UI_NGINX_CONFIG="${UI_NGINX_DATA}default.conf"
  trojan_panel_ui_port=8888
  ui_https=1
  trojan_panel_ip="127.0.0.1"
  trojan_panel_server_port=8081

  # Trojan Panel back-tend
  TROJAN_PANEL_DATA="/tpdata/trojan-panel/"
  TROJAN_PANEL_WEBFILE="${TROJAN_PANEL_DATA}webfile/"
  TROJAN_PANEL_LOGS="${TROJAN_PANEL_DATA}logs/"
  TROJAN_PANEL_CONFIG="${TROJAN_PANEL_DATA}config/"
  trojan_panel_config_path="${TROJAN_PANEL_DATA}config/config.ini"
  trojan_panel_port=8081

  # Trojan Panel kernel
  TROJAN_PANEL_CORE_DATA="/tpdata/trojan-panel-core/"
  TROJAN_PANEL_CORE_LOGS="${TROJAN_PANEL_CORE_DATA}logs/"
  TROJAN_PANEL_CORE_CONFIG="${TROJAN_PANEL_CORE_DATA}config/"
  trojan_panel_core_config_path="${TROJAN_PANEL_CORE_DATA}config/config.ini"
  database="trojan_panel_db"
  account_table="account"
  grpc_port=8100
  trojan_panel_core_port=8082

  # Update
  trojan_panel_ui_current_version=""
  trojan_panel_ui_latest_version="v2.1.5"
  trojan_panel_current_version=""
  trojan_panel_latest_version="v2.1.4"
  trojan_panel_core_current_version=""
  trojan_panel_core_latest_version="v2.1.1"

  # SQL
  sql_200="alter table \`system\` add template_config varchar(512) default '' not null comment 'Template settings' after email_config;update \`system\` set template_config = \"{\\\"systemName\\\":\\\"Trojan Panel\\\"}\" where name = \"trojan-panel\";insert into \`casbin_rule\` values ('p','sysadmin','/api/nodeServer/nodeServerState','GET','','','');insert into \`casbin_rule\` values ('p','user','/api/node/selectNodeInfo','GET','','','');insert into \`casbin_rule\` values ('p','sysadmin','/api/node/selectNodeInfo','GET','','','');"
  sql_203="alter table node add node_server_grpc_port int(10) unsigned default 8100 not null comment 'gRPC端口' after node_server_ip;alter table node_server add grpc_port int(10) unsigned default 8100 not null comment 'gRPC port' after name;alter table node_xray add xray_flow varchar(32) default 'xtls-rprx-vision' not null comment 'Xray流控' after protocol;alter table node_xray add xray_ss_method varchar(32) default 'aes-256-gcm' not null comment 'Xray Shadowsocks加密方式' after xray_flow;"
  sql_205="DROP TABLE IF EXISTS \`file_task\`;CREATE TABLE \`file_task\` ( \`id\` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '自增主键', \`name\` varchar(64) NOT NULL DEFAULT '' COMMENT '文件名称', \`path\` varchar(128) NOT NULL DEFAULT '' COMMENT 'file path', \`type\` tinyint(2) unsigned NOT NULL DEFAULT '1' COMMENT ' type  1/ user import  2/ Server import  3/User export 4/服务器导出', \`status\` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'status -1/fail 0/等待 1/正在执行 2/成功', \`err_msg\` varchar(128) NOT NULL DEFAULT '' COMMENT '错误信息', \`account_id\` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT '账户id', \`account_username\` varchar(64) NOT NULL DEFAULT '' COMMENT '账户登录用户名', \`create_time\` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间', \`update_time\` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间', PRIMARY KEY (\`id\`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文件任务';INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/account/exportAccount', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/account/importAccount', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/system/uploadLogo', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/nodeServer/exportNodeServer', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/nodeServer/importNodeServer', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/fileTask/selectFileTaskPage', 'GET', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/fileTask/deleteFileTaskById', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/fileTask/downloadFileTask', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/fileTask/downloadCsvTemplate', 'POST', '', '', '');"
  sql_210="UPDATE casbin_rule SET v1 = '/api/fileTask/downloadTemplate' WHERE v1 = '/api/fileTask/downloadCsvTemplate';UPDATE casbin_rule SET v1 = '/api/account/updateAccountPass' WHERE v1 = '/api/account/updateAccountProfile';INSERT INTO casbin_rule (p_type, v0, v1, v2) VALUES ('p', 'sysadmin', '/api/account/updateAccountProperty', 'POST');INSERT INTO casbin_rule (p_type, v0, v1, v2) VALUES ('p', 'user', '/api/account/updateAccountProperty', 'POST');alter table node_xray modify settings varchar(1024) default '' not null comment 'settings';alter table node_xray modify stream_settings varchar(1024) default '' not null comment 'streamSettings';alter table node_xray add reality_pbk varchar(64) default '' not null comment 'reality的公钥' after xray_ss_method;alter table node_hysteria add obfs varchar(64) default '' not null comment '混淆密码' after protocol;"
  sql_211="UPDATE \`system\` SET account_config = '{\"registerEnable\":1,\"registerQuota\":0,\"registerExpireDays\":0,\"resetDownloadAndUploadMonth\":0,\"trafficRankEnable\":1,\"captchaEnable\":0}' WHERE name = 'trojan-panel';INSERT INTO casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/node/nodeDefault', 'GET', '', '', '');INSERT INTO casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'user', '/api/node/nodeDefault', 'GET', '', '', '');"
  sql_212="alter table account add validity_period int unsigned default 0 not null comment '账户有效期' after email;alter table account add last_login_time bigint unsigned default 0 not null comment '最后一次登录时间' after validity_period;update account set last_login_time = unix_timestamp(NOW()) * 1000 where last_login_time = 0;INSERT INTO casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/account/createAccountBatch', 'POST', '', '', '');INSERT INTO casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/account/exportAccountUnused', 'POST', '', '', '');"
}

echo_content() {
  case $1 in
  "red")
    ${ECHO_TYPE} "\033[31m$2\033[0m"
    ;;
  "green")
    ${ECHO_TYPE} "\033[32m$2\033[0m"
    ;;
  "yellow")
    ${ECHO_TYPE} "\033[33m$2\033[0m"
    ;;
  "blue")
    ${ECHO_TYPE} "\033[34m$2\033[0m"
    ;;
  "purple")
    ${ECHO_TYPE} "\033[35m$2\033[0m"
    ;;
  "skyBlue")
    ${ECHO_TYPE} "\033[36m$2\033[0m"
    ;;
  "white")
    ${ECHO_TYPE} "\033[37m$2\033[0m"
    ;;
  esac
}

mkdir_tools() {
  # project directory
  mkdir -p ${TP_DATA}

  # web
  mkdir -p ${WEB_PATH}

  # cert
  mkdir -p ${CERT_PATH}
  touch ${DOMAIN_FILE}

  # Caddy
  mkdir -p ${CADDY_DATA}
  touch ${CADDY_CONFIG}
  mkdir -p ${CADDY_LOG}

  # Nginx
  mkdir -p ${NGINX_DATA}
  touch ${NGINX_CONFIG}

  # MariaDB
  mkdir -p ${MARIA_DATA}

  # Redis
  mkdir -p ${REDIS_DATA}

  # Trojan Panel Fron-tend
  mkdir -p ${TROJAN_PANEL_UI_DATA}
  # # Nginx
  mkdir -p ${UI_NGINX_DATA}
  touch ${UI_NGINX_CONFIG}

  # Trojan Panel back-tend
  mkdir -p ${TROJAN_PANEL_DATA}
  mkdir -p ${TROJAN_PANEL_LOGS}

  # Trojan Panel kernel
  mkdir -p ${TROJAN_PANEL_CORE_DATA}
  mkdir -p ${TROJAN_PANEL_CORE_LOGS}
}

can_connect() {
  ping -c2 -i0.3 -W1 "$1" &>/dev/null
  if [[ "$?" == "0" ]]; then
    return 0
  else
    return 1
  fi
}

get_ini_value() {
  local config_file="$1"
  local key="$2"
  local section=""
  local section_flag=0

  # Disassembling group name and key name
  IFS='.' read -r group_name key_name <<<"$key"

  while IFS='=' read -r name val; do
    # processing section name
    if [[ $name =~ ^\[(.*)\]$ ]]; then
      section="${BASH_REMATCH[1]}"
      if [[ $section == $group_name ]]; then
        section_flag=1
      else
        section_flag=0
      fi
      continue
    fi

    # 提取配置项的值
    if [[ $section_flag -eq 1 && $name == $key_name ]]; then
      echo "$val"
      return
    fi
  done <"$config_file"
}

check_sys() {
  if [[ $(command -v yum) ]]; then
    package_manager='yum'
  elif [[ $(command -v dnf) ]]; then
    package_manager='dnf'
  elif [[ $(command -v apt) ]]; then
    package_manager='apt'
  elif [[ $(command -v apt-get) ]]; then
    package_manager='apt-get'
  fi

  if [[ -z "${package_manager}" ]]; then
    echo_content red "The system is not currently supported"
    exit 0
  fi

  if [[ -n $(find /etc -name "redhat-release") ]] || grep </proc/version -q -i "centos"; then
    release="centos"
  elif grep </etc/issue -q -i "debian" && [[ -f "/etc/issue" ]] || grep </etc/issue -q -i "debian" && [[ -f "/proc/version" ]]; then
    release="debian"
  elif grep </etc/issue -q -i "ubuntu" && [[ -f "/etc/issue" ]] || grep </etc/issue -q -i "ubuntu" && [[ -f "/proc/version" ]]; then
    release="ubuntu"
  fi

  if [[ -z "${release}" ]]; then
    echo_content red "仅支持CentOS 7+/Ubuntu 18+/Debian 10+系统"
    exit 0
  fi

  if [[ $(arch) =~ ("x86_64"|"amd64"|"arm64"|"aarch64"|"arm"|"s390x") ]]; then
    get_arch=$(arch)
  fi

  if [[ -z "${get_arch}" ]]; then
    echo_content red "仅支持amd64/arm64/arm/s390x processor architecture"
    exit 0
  fi

  can_connect www.google.com
  [[ "$?" == "0" ]] && can_google=1
}

depend_install() {
  if [[ "${package_manager}" != 'yum' && "${package_manager}" != 'dnf' ]]; then
    ${package_manager} update -y
  fi
  ${package_manager} install -y \
    curl \
    wget \
    tar \
    lsof \
    systemd
}

# Install Docker
install_docker() {
  if [[ ! $(docker -v 2>/dev/null) ]]; then
    echo_content green "---> Install Docker"

    #  turn off 防火墙
    if [[ "$(firewall-cmd --state 2>/dev/null)" == "running" ]]; then
      systemctl stop firewalld.service && systemctl disable firewalld.service
    fi

    # Time zone
    timedatectl set-timezone Asia/Shanghai

    if [[ ${can_google} == 0 ]]; then
      sh <(curl -sL https://get.docker.com) --mirror Aliyun
      # Set Docker local source
      mkdir -p /etc/docker &&
        cat >/etc/docker/daemon.json <<EOF
{
  "registry-mirrors":[${DOCKER_MIRROR}],
  "log-driver":"json-file",
  "log-opts":{
      "max-size":"50m",
      "max-file":"3"
  }
}
EOF
    else
      sh <(curl -sL https://get.docker.com)
      mkdir -p /etc/docker &&
        cat >/etc/docker/daemon.json <<EOF
{
  "log-driver":"json-file",
  "log-opts":{
      "max-size":"50m",
      "max-file":"3"
  }
}
EOF
    fi

    systemctl enable docker &&
      systemctl restart docker

    if [[ $(docker -v 2>/dev/null) ]]; then
      echo_content skyBlue "---> DockerThe installation is complete"
    else
      echo_content red "---> The installation is failed "
      exit 0
    fi
  else
    echo_content skyBlue "---> You have installed Docker"
  fi
}

# 
install_caddy2() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-caddy$") ]]; then
    echo_content green "---> Install Caddy2"

    wget --no-check-certificate -O ${WEB_PATH}html.tar.gz -N ${STATIC_HTML} &&
      tar -zxvf ${WEB_PATH}html.tar.gz -k -C ${WEB_PATH}

    read -r -p "Please enter the port of Caddy(default:80): " caddy_port
    [[ -z "${caddy_port}" ]] && caddy_port=80
    read -r -p "Please enter Caddy Forwarding port of(default:8863): " caddy_remote_port
    [[ -z "${caddy_remote_port}" ]] && caddy_remote_port=8863

    echo_content yellow "hint：Please confirm that the domain name has been resolved to this machine, otherwise the installation may fail"
    while read -r -p "Please enter Your domain name (required): " domain; do
      if [[ -z "${domain}" ]]; then
        echo_content red "Domain name cannot be empty"
      else
        break
      fi
    done

    read -r -p "Please enter your mailbox(optional): " your_email

    while read -r -p "please chooseHow to set a certificate? (1/Automatic application and renewal certificate 2/Manually set the certificate path default:1/Automatic application and renewal certificate): " ssl_option; do
      if [[ -z ${ssl_option} || ${ssl_option} == 1 ]]; then
        while read -r -p "please choose How to apply for a certificate(1/acme 2/zerossl default:1/acme): " ssl_module_type; do
          if [[ -z "${ssl_module_type}" || ${ssl_module_type} == 1 ]]; then
            ssl_module="acme"
            CADDY_CERT_DIR="${CERT_PATH}certificates/acme-v02.api.letsencrypt.org-directory/"
            break
          elif [[ ${ssl_module_type} == 2 ]]; then
            ssl_module="zerossl"
            CADDY_CERT_DIR="${CERT_PATH}certificates/acme.zerossl.com-v2-dv90/"
            break
          else
            echo_content red "Cannot enter other characters except 1 and 2"
          fi
        done

        cat >${CADDY_CONFIG} <<EOF
{
    "admin":{
        "disabled":true
    },
    "logging":{
        "logs":{
            "default":{
                "writer":{
                    "output":"file",
                    "filename":"${CADDY_LOG}error.log"
                },
                "level":"ERROR"
            }
        }
    },
    "storage":{
        "module":"file_system",
        "root":"${CERT_PATH}"
    },
    "apps":{
        "http":{
            "http_port": ${caddy_port},
            "servers":{
                "srv0":{
                    "listen":[
                        ":${caddy_port}"
                    ],
                    "routes":[
                        {
                            "match":[
                                {
                                    "host":[
                                        "${domain}"
                                    ]
                                }
                            ],
                            "handle":[
                                {
                                    "handler":"static_response",
                                    "headers":{
                                        "Location":[
                                            "https://{http.request.host}:${caddy_remote_port}{http.request.uri}"
                                        ]
                                    },
                                    "status_code":301
                                }
                            ]
                        }
                    ]
                },
                "srv1":{
                    "listen":[
                        ":${caddy_remote_port}"
                    ],
                    "routes":[
                        {
                            "handle":[
                                {
                                    "handler":"subroute",
                                    "routes":[
                                        {
                                            "match":[
                                                {
                                                    "host":[
                                                        "${domain}"
                                                    ]
                                                }
                                            ],
                                            "handle":[
                                                {
                                                    "handler":"file_server",
                                                    "root":"${WEB_PATH}",
                                                    "index_names":[
                                                        "index.html",
                                                        "index.htm"
                                                    ]
                                                }
                                            ],
                                            "terminal":true
                                        }
                                    ]
                                }
                            ]
                        }
                    ],
                    "tls_connection_policies":[
                        {
                            "match":{
                                "sni":[
                                    "${domain}"
                                ]
                            }
                        }
                    ],
                    "automatic_https":{
                        "disable":true
                    }
                }
            }
        },
        "tls":{
            "certificates":{
                "automate":[
                    "${domain}"
                ]
            },
            "automation":{
                "policies":[
                    {
                        "issuers":[
                            {
                                "module":"${ssl_module}",
                                "email":"${your_email}"
                            }
                        ]
                    }
                ]
            }
        }
    }
}
EOF
        break
      elif [[ ${ssl_option} == 2 ]]; then
        install_custom_cert "${domain}"
        cat >${CADDY_CONFIG} <<EOF
{
    "admin":{
        "disabled":true
    },
    "logging":{
        "logs":{
            "default":{
                "writer":{
                    "output":"file",
                    "filename":"${CADDY_LOG}error.log"
                },
                "level":"ERROR"
            }
        }
    },
    "storage":{
        "module":"file_system",
        "root":"${CERT_PATH}"
    },
    "apps":{
        "http":{
            "http_port": ${caddy_port},
            "servers":{
                "srv0":{
                    "listen":[
                        ":${caddy_port}"
                    ],
                    "routes":[
                        {
                            "match":[
                                {
                                    "host":[
                                        "${domain}"
                                    ]
                                }
                            ],
                            "handle":[
                                {
                                    "handler":"static_response",
                                    "headers":{
                                        "Location":[
                                            "https://{http.request.host}:${caddy_remote_port}{http.request.uri}"
                                        ]
                                    },
                                    "status_code":301
                                }
                            ]
                        }
                    ]
                },
                "srv1":{
                    "listen":[
                        ":${caddy_remote_port}"
                    ],
                    "routes":[
                        {
                            "handle":[
                                {
                                    "handler":"subroute",
                                    "routes":[
                                        {
                                            "match":[
                                                {
                                                    "host":[
                                                        "${domain}"
                                                    ]
                                                }
                                            ],
                                            "handle":[
                                                {
                                                    "handler":"file_server",
                                                    "root":"${WEB_PATH}",
                                                    "index_names":[
                                                        "index.html",
                                                        "index.htm"
                                                    ]
                                                }
                                            ],
                                            "terminal":true
                                        }
                                    ]
                                }
                            ]
                        }
                    ],
                    "tls_connection_policies":[
                        {
                            "match":{
                                "sni":[
                                    "${domain}"
                                ]
                            }
                        }
                    ],
                    "automatic_https":{
                        "disable":true
                    }
                }
            }
        },
        "tls":{
            "certificates":{
                "automate":[
                    "${domain}"
                ],
                "load_files":[
                    {
                        "certificate":"${CADDY_CERT_DIR}${domain}/${domain}.crt",
                        "key":"${CADDY_CERT_DIR}${domain}/${domain}.key"
                    }
                ]
            },
            "automation":{
                "policies":[
                    {
                        "issuers":[
                            {
                                "module":"${ssl_module}",
                                "email":"${your_email}"
                            }
                        ]
                    }
                ]
            }
        }
    }
}
EOF
        break
      else
        echo_content red "Cannot enter other characters except 1 and 2"
      fi
    done

    if [[ -n $(lsof -i:${caddy_port},443 -t) ]]; then
      kill -9 "$(lsof -i:${caddy_port},443 -t)"
    fi

    docker pull caddy:2.6.2 &&
      docker run -d --name trojan-panel-caddy --restart always \
        --network=host \
        -v "${CADDY_CONFIG}":"${CADDY_CONFIG}" \
        -v ${CERT_PATH}:"${CADDY_CERT_DIR}${domain}/" \
        -v ${WEB_PATH}:${WEB_PATH} \
        -v ${CADDY_LOG}:${CADDY_LOG} \
        caddy:2.6.2 caddy run --config ${CADDY_CONFIG}

    if [[ -n $(docker ps -q -f "name=^trojan-panel-caddy$" -f "status=running") ]]; then
      cat >${DOMAIN_FILE} <<EOF
${domain}
EOF
      echo_content skyBlue "---> CaddyThe installation is complete"
    else
      echo_content red "---> CaddyInstall fail or Run abnormally, Please try to repair or Uninstall reinstall"
      exit 0
    fi
  else
    echo_content skyBlue "---> You have already Install Caddy"
  fi
}

# Install Nginx
install_nginx() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-nginx$") ]]; then
    echo_content green "---> Install Nginx"

    wget --no-check-certificate -O ${WEB_PATH}html.tar.gz -N ${STATIC_HTML} &&
      tar -zxvf ${WEB_PATH}html.tar.gz -k -C ${WEB_PATH}

    read -r -p "Please enter Nginx port (default:80): " nginx_port
    [[ -z "${nginx_port}" ]] && nginx_port=80
    read -r -p "Please enter NginxForwarding port of(default:8863): " nginx_remote_port
    [[ -z "${nginx_remote_port}" ]] && nginx_remote_port=8863

    while read -r -p "please chooseNginxWhether to open https?(0/ turn off  1/ turn on  default:1/ turn on ): " nginx_https; do
      if [[ -z ${nginx_https} || ${nginx_https} == 1 ]]; then
        install_custom_cert "custom_cert"
        domain=$(cat "${DOMAIN_FILE}")
        cat >${NGINX_CONFIG} <<-EOF
server {
    listen ${nginx_port};
    server_name localhost;

    return 301 http://\$host:${nginx_remote_port}\$request_uri;
}

server {
    listen       ${nginx_remote_port} ssl;
    server_name  localhost;

    #强制ssl
    ssl on;
    ssl_certificate      ${CERT_PATH}${domain}.crt;
    ssl_certificate_key  ${CERT_PATH}${domain}.key;
    #缓存有效期
    ssl_session_timeout  5m;
    #Encryption protocol for secure link optional
    ssl_protocols  TLSv1.3;
    #Encryption Algorithm
    ssl_ciphers  ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    #Use server-side preferred algorithm
    ssl_prefer_server_ciphers  on;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   ${WEB_PATH};
        index  index.html index.htm;
    }

    #error_page  404              /404.html;
    #497 http->https
    error_page  497               https://\$host:${nginx_remote_port}\$request_uri;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
        break
      else
        if [[ ${nginx_https} != 0 ]]; then
          echo_content red "No characters other than 0 and 1 can be entered"
        else
          cat >${NGINX_CONFIG} <<-EOF
server {
    listen       ${nginx_port};
    server_name  localhost;

    location / {
        root   ${WEB_PATH};
        index  index.html index.htm;
    }

    error_page  497               http://\$host:${nginx_port}\$request_uri;

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
          break
        fi
      fi
    done

    docker pull nginx:1.20-alpine &&
      docker run -d --name trojan-panel-nginx --restart always \
        --network=host \
        -v "${NGINX_CONFIG}":"/etc/nginx/conf.d/default.conf" \
        -v ${CERT_PATH}:${CERT_PATH} \
        -v ${WEB_PATH}:${WEB_PATH} \
        nginx:1.20-alpine

    if [[ -n $(docker ps -q -f "name=^trojan-panel-nginx$" -f "status=running") ]]; then
      echo_content skyBlue "---> NginxThe installation is complete"
    else
      echo_content red "---> NginxInstall fail or Run abnormally, Please try to repair  or Uninstall reinstall"
      exit 0
    fi
  else
    echo_content skyBlue "---> 你已经Install 了Nginx"
  fi
}

# 设置伪装Web
install_reverse_proxy() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-caddy$|^trojan-panel-nginx$") ]]; then
    echo_content green "---> 设置伪装Web"

    while :; do
      echo_content yellow "1. Install Caddy 2（推荐）"
      echo_content yellow "2. Install Nginx"
      echo_content yellow "3. 不设置"
      read -r -p "please choose(default:1): " whether_install_reverse_proxy
      [[ -z "${whether_install_reverse_proxy}" ]] && whether_install_reverse_proxy=1

      case ${whether_install_reverse_proxy} in
      1)
        install_caddy2
        break
        ;;
      2)
        install_nginx
        break
        ;;
      3)
        break
        ;;
      *)
        echo_content red "Without this option"
        continue
        ;;
      esac
    done

    echo_content skyBlue "---> 伪装Web设置完成"
  fi
}

install_custom_cert() {
  while read -r -p "Please enter 证书的.crt文件路径(required): " crt_path; do
    if [[ -z "${crt_path}" ]]; then
      echo_content red "路径不能为空"
    else
      if [[ ! -f "${crt_path}" ]]; then
        echo_content red "证书的.crt文件路径不存在"
      else
        cp "${crt_path}" "${CERT_PATH}$1.crt"
        break
      fi
    fi
  done
  while read -r -p "Please enter 证书的.key文件路径(required): " key_path; do
    if [[ -z "${key_path}" ]]; then
      echo_content red "路径不能为空"
    else
      if [[ ! -f "${key_path}" ]]; then
        echo_content red "证书的.key文件路径不存在"
      else
        cp "${key_path}" "${CERT_PATH}$1.key"
        break
      fi
    fi
  done
  cat >${DOMAIN_FILE} <<EOF
$1
EOF
}

# 设置证书
install_cert() {
  domain=$(cat "${DOMAIN_FILE}")
  if [[ -z "${domain}" ]]; then
    echo_content green "---> 设置证书"

    while :; do
      echo_content yellow "1. Install Caddy 2（自动申请/续签证书）"
      echo_content yellow "2. 手动设置证书路径"
      echo_content yellow "3. 不设置"
      read -r -p "please choose(default:1): " whether_install_cert
      [[ -z "${whether_install_cert}" ]] && whether_install_cert=1

      case ${whether_install_cert} in
      1)
        install_caddy2
        break
        ;;
      2)
        install_custom_cert "custom_cert"
        break
        ;;
      3)
        break
        ;;
      *)
        echo_content red "Without this option"
        continue
        ;;
      esac
    done

    echo_content green "---> 证书设置完成"
  fi
}

# Install MariaDB
install_mariadb() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-mariadb$") ]]; then
    echo_content green "---> Install MariaDB"

    read -r -p "Please enter 数据库 port (default:9507): " mariadb_port
    [[ -z "${mariadb_port}" ]] && mariadb_port=9507
    read -r -p "Please enter The user name of the database(default:root): " mariadb_user
    [[ -z "${mariadb_user}" ]] && mariadb_user="root"
    while read -r -p "Please enter database password(required): " mariadb_pas; do
      if [[ -z "${mariadb_pas}" ]]; then
        echo_content red "password can not be blank"
      else
        break
      fi
    done

    if [[ "${mariadb_user}" == "root" ]]; then
      docker pull mariadb:10.7.3 &&
        docker run -d --name trojan-panel-mariadb --restart always \
          --network=host \
          -e MYSQL_DATABASE="trojan_panel_db" \
          -e MYSQL_ROOT_PASSWORD="${mariadb_pas}" \
          -e TZ=Asia/Shanghai \
          mariadb:10.7.3 \
          --port ${mariadb_port} \
          --character-set-server=utf8mb4 \
          --collation-server=utf8mb4_unicode_ci
    else
      docker pull mariadb:10.7.3 &&
        docker run -d --name trojan-panel-mariadb --restart always \
          --network=host \
          -e MYSQL_DATABASE="trojan_panel_db" \
          -e MYSQL_ROOT_PASSWORD="${mariadb_pas}" \
          -e MYSQL_USER="${mariadb_user}" \
          -e MYSQL_PASSWORD="${mariadb_pas}" \
          -e TZ=Asia/Shanghai \
          mariadb:10.7.3 \
          --port ${mariadb_port} \
          --character-set-server=utf8mb4 \
          --collation-server=utf8mb4_unicode_ci
    fi

    if [[ -n $(docker ps -q -f "name=^trojan-panel-mariadb$" -f "status=running") ]]; then
      echo_content skyBlue "---> MariaDBThe installation is complete"
      echo_content yellow "---> MariaDB root的数据库密码(please keep it safe): ${mariadb_pas}"
      if [[ "${mariadb_user}" != "root" ]]; then
        echo_content yellow "---> MariaDB ${mariadb_user}的数据库密码(please keep it safe): ${mariadb_pas}"
      fi
    else
      echo_content red "---> MariaDBInstall fail or Run abnormally, Please try to repair  or Uninstall reinstall"
      exit 0
    fi
  else
    echo_content skyBlue "---> 你已经Install 了MariaDB"
  fi
}

# Install Redis
install_redis() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-redis$") ]]; then
    echo_content green "---> Install Redis"

    read -r -p "Please enter Redis port (default:6378): " redis_port
    [[ -z "${redis_port}" ]] && redis_port=6378
    while read -r -p "Please enter Redis的密码(required): " redis_pass; do
      if [[ -z "${redis_pass}" ]]; then
        echo_content red "password can not be blank"
      else
        break
      fi
    done

    docker pull redis:6.2.7 &&
      docker run -d --name trojan-panel-redis --restart always \
        --network=host \
        redis:6.2.7 \
        redis-server --requirepass "${redis_pass}" --port "${redis_port}"

    if [[ -n $(docker ps -q -f "name=^trojan-panel-redis$" -f "status=running") ]]; then
      echo_content skyBlue "---> RedisThe installation is complete"
      echo_content yellow "---> Redis database password (please keep it safe): ${redis_pass}"
    else
      echo_content red "---> RedisInstall fail or Run abnormally, Please try to repair  or Uninstall reinstall"
      exit 0
    fi
  else
    echo_content skyBlue "---> You are already install Redis"
  fi
}

# Install Trojan Panel Fron-tend
install_trojan_panel_ui() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-ui$") ]]; then
    echo_content green "---> Install Trojan Panel Fron-tend"

    read -r -p "Please enter Trojan Panel IP address of the backend(default:local back-end ): " trojan_panel_ip
    [[ -z "${trojan_panel_ip}" ]] && trojan_panel_ip="127.0.0.1"
    read -r -p "Please enter Trojan Panel backend service port(default:8081): " trojan_panel_server_port
    [[ -z "${trojan_panel_server_port}" ]] && trojan_panel_server_port=8081

    read -r -p "Please enter Trojan Panel front-end port (default:8888): " trojan_panel_ui_port
    [[ -z "${trojan_panel_ui_port}" ]] && trojan_panel_ui_port="8888"
    while read -r -p "please chooseTrojan Panel front-end Whether to open https?(0/ turn off  1/ turn on  default:1/ turn on ): " ui_https; do
      if [[ -z ${ui_https} || ${ui_https} == 1 ]]; then
        install_cert
        domain=$(cat "${DOMAIN_FILE}")
        # 配置Nginx
        cat >${UI_NGINX_CONFIG} <<-EOF
server {
    listen       ${trojan_panel_ui_port} ssl;
    server_name  localhost;

    #强制ssl
    ssl on;
    ssl_certificate      ${CERT_PATH}${domain}.crt;
    ssl_certificate_key  ${CERT_PATH}${domain}.key;
    #缓存有效期
    ssl_session_timeout  5m;
    #安全链接optional的加密协议
    ssl_protocols  TLSv1.3;
    #加密算法
    ssl_ciphers  ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    #Use server-side preferred algorithm
    ssl_prefer_server_ciphers  on;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   ${TROJAN_PANEL_UI_DATA};
        index  index.html index.htm;
    }

    location /api {
        proxy_pass http://${trojan_panel_ip}:${trojan_panel_server_port};
    }

    #error_page  404              /404.html;
    #497 http->https
    error_page  497               https://\$host:${trojan_panel_ui_port}\$request_uri;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
        break
      else
        if [[ ${ui_https} != 0 ]]; then
          echo_content red "No characters other than 0 and 1 can be entered"
        else
          cat >${UI_NGINX_CONFIG} <<-EOF
server {
    listen       ${trojan_panel_ui_port};
    server_name  localhost;

    location / {
        root   ${TROJAN_PANEL_UI_DATA};
        index  index.html index.htm;
    }

    location /api {
        proxy_pass http://${trojan_panel_ip}:${trojan_panel_server_port};
    }

    error_page  497               http://\$host:${trojan_panel_ui_port}\$request_uri;

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
          break
        fi
      fi
    done

    docker pull jonssonyan/trojan-panel-ui &&
      docker run -d --name trojan-panel-ui --restart always \
        --network=host \
        -v "${UI_NGINX_CONFIG}":"/etc/nginx/conf.d/default.conf" \
        -v ${CERT_PATH}:${CERT_PATH} \
        jonssonyan/trojan-panel-ui

    if [[ -n $(docker ps -q -f "name=^trojan-panel-ui$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel front-end The installation is complete"

      https_flag=$([[ -z ${ui_https} || ${ui_https} == 1 ]] && echo "https" || echo "http")
      domain_or_ip=$([[ -z ${domain} || "${domain}" == "custom_cert" ]] && echo "ip" || echo "${domain}")

      echo_content red "\n=============================================================="
      echo_content skyBlue "Trojan Panel front-end Install 成功"
      echo_content yellow "Admin panel address: ${https_flag}://${domain_or_ip}:${trojan_panel_ui_port}"
      echo_content red "\n=============================================================="
    else
      echo_content red "---> Trojan Panel front-end Install fail or Run abnormally, Please try to repair  or Uninstall reinstall"
      exit 0
    fi
  else
    echo_content skyBlue "---> 你已经Install 了Trojan Panel Fron-tend"
  fi
}

# Install Trojan Panel back-tend
install_trojan_panel() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel$") ]]; then
    echo_content green "---> Install Trojan Panel back-tend"

    read -r -p "Please enter Trojan Panel backend service port(default:8081): " trojan_panel_port
    [[ -z "${trojan_panel_port}" ]] && trojan_panel_port=8081

    read -r -p "Please enter 数据库的IP地址(default:本机数据库): " mariadb_ip
    [[ -z "${mariadb_ip}" ]] && mariadb_ip="127.0.0.1"
    read -r -p "Please enter 数据库 port (default:9507): " mariadb_port
    [[ -z "${mariadb_port}" ]] && mariadb_port=9507
    read -r -p "Please enter The user name of the database(default:root): " mariadb_user
    [[ -z "${mariadb_user}" ]] && mariadb_user="root"
    while read -r -p "Please enter database password(required): " mariadb_pas; do
      if [[ -z "${mariadb_pas}" ]]; then
        echo_content red "password can not be blank"
      else
        break
      fi
    done

    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -e "create database if not exists trojan_panel_db;" &>/dev/null

    read -r -p "Please enter Redis的IP地址(default:本机Redis): " redis_host
    [[ -z "${redis_host}" ]] && redis_host="127.0.0.1"
    read -r -p "Please enter Redis port (default:6378): " redis_port
    [[ -z "${redis_port}" ]] && redis_port=6378
    while read -r -p "Please enter Redis的密码(required): " redis_pass; do
      if [[ -z "${redis_pass}" ]]; then
        echo_content red "password can not be blank"
      else
        break
      fi
    done

    docker exec trojan-panel-redis redis-cli -h "${redis_host}" -p "${redis_port}" -a "${redis_pass}" -e "flushall" &>/dev/null

    docker pull jonssonyan/trojan-panel &&
      docker run -d --name trojan-panel --restart always \
        --network=host \
        -v ${WEB_PATH}:${TROJAN_PANEL_WEBFILE} \
        -v ${TROJAN_PANEL_LOGS}:${TROJAN_PANEL_LOGS} \
        -v ${TROJAN_PANEL_CONFIG}:${TROJAN_PANEL_CONFIG} \
        -v /etc/localtime:/etc/localtime \
        -e GIN_MODE=release \
        -e "mariadb_ip=${mariadb_ip}" \
        -e "mariadb_port=${mariadb_port}" \
        -e "mariadb_user=${mariadb_user}" \
        -e "mariadb_pas=${mariadb_pas}" \
        -e "redis_host=${redis_host}" \
        -e "redis_port=${redis_port}" \
        -e "redis_pass=${redis_pass}" \
        -e "server_port=${trojan_panel_port}" \
        jonssonyan/trojan-panel

    if [[ -n $(docker ps -q -f "name=^trojan-panel$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel后端The installation is complete"

      echo_content red "\n=============================================================="
      echo_content skyBlue "Trojan Panel后端Install 成功"
      echo_content yellow "MariaDB ${mariadb_user}的密码(please keep it safe): ${mariadb_pas}"
      echo_content yellow "Redis的密码(please keep it safe): ${redis_pass}"
      echo_content yellow "系统管理员 默认用户名: sysadmin 默认密码: 123456 请及时登陆管理面板修改密码"
      echo_content yellow "Trojan Panel私钥和证书目录: ${CERT_PATH}"
      echo_content red "\n=============================================================="
    else
      echo_content red "---> Trojan Panel后端Install fail or Run abnormally, Please try to repair  or Uninstall reinstall"
      exit 0
    fi
  else
    echo_content skyBlue "---> 你已经Install 了Trojan Panel back-tend"
  fi
}

# Install Trojan Panel kernel
install_trojan_panel_core() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-core$") ]]; then
    echo_content green "---> Install Trojan Panel kernel"

    read -r -p "Please enter Trojan Panel内核的服务端口(default:8082): " trojan_panel_core_port
    [[ -z "${trojan_panel_core_port}" ]] && trojan_panel_core_port=8082

    read -r -p "Please enter 数据库的IP地址(default:本机数据库): " mariadb_ip
    [[ -z "${mariadb_ip}" ]] && mariadb_ip="127.0.0.1"
    read -r -p "Please enter 数据库 port (default:9507): " mariadb_port
    [[ -z "${mariadb_port}" ]] && mariadb_port=9507
    read -r -p "Please enter The user name of the database(default:root): " mariadb_user
    [[ -z "${mariadb_user}" ]] && mariadb_user="root"
    while read -r -p "Please enter database password(required): " mariadb_pas; do
      if [[ -z "${mariadb_pas}" ]]; then
        echo_content red "password can not be blank"
      else
        break
      fi
    done
    read -r -p "Please enter 数据库名称(default:trojan_panel_db): " database
    [[ -z "${database}" ]] && database="trojan_panel_db"
    read -r -p "Please enter 数据库的用户表名称(default:account): " account_table
    [[ -z "${account_table}" ]] && account_table="account"

    read -r -p "Please enter Redis的IP地址(default:本机Redis): " redis_host
    [[ -z "${redis_host}" ]] && redis_host="127.0.0.1"
    read -r -p "Please enter Redis port (default:6378): " redis_port
    [[ -z "${redis_port}" ]] && redis_port=6378
    while read -r -p "Please enter Redis的密码(required): " redis_pass; do
      if [[ -z "${redis_pass}" ]]; then
        echo_content red "password can not be blank"
      else
        break
      fi
    done
    read -r -p "Please enter API port (default:8100): " grpc_port
    [[ -z "${grpc_port}" ]] && grpc_port=8100

    domain=$(cat "${DOMAIN_FILE}")

    docker pull jonssonyan/trojan-panel-core &&
      docker run -d --name trojan-panel-core --restart always \
        --network=host \
        -v ${TROJAN_PANEL_CORE_DATA}bin/xray/config:${TROJAN_PANEL_CORE_DATA}bin/xray/config \
        -v ${TROJAN_PANEL_CORE_DATA}bin/trojango/config:${TROJAN_PANEL_CORE_DATA}bin/trojango/config \
        -v ${TROJAN_PANEL_CORE_DATA}bin/hysteria/config:${TROJAN_PANEL_CORE_DATA}bin/hysteria/config \
        -v ${TROJAN_PANEL_CORE_DATA}bin/naiveproxy/config:${TROJAN_PANEL_CORE_DATA}bin/naiveproxy/config \
        -v ${TROJAN_PANEL_CORE_LOGS}:${TROJAN_PANEL_CORE_LOGS} \
        -v ${TROJAN_PANEL_CORE_CONFIG}:${TROJAN_PANEL_CORE_CONFIG} \
        -v ${CERT_PATH}:${CERT_PATH} \
        -v ${WEB_PATH}:${WEB_PATH} \
        -v /etc/localtime:/etc/localtime \
        -e GIN_MODE=release \
        -e "mariadb_ip=${mariadb_ip}" \
        -e "mariadb_port=${mariadb_port}" \
        -e "mariadb_user=${mariadb_user}" \
        -e "mariadb_pas=${mariadb_pas}" \
        -e "database=${database}" \
        -e "account-table=${account_table}" \
        -e "redis_host=${redis_host}" \
        -e "redis_port=${redis_port}" \
        -e "redis_pass=${redis_pass}" \
        -e "crt_path=${CERT_PATH}${domain}.crt" \
        -e "key_path=${CERT_PATH}${domain}.key" \
        -e "grpc_port=${grpc_port}" \
        -e "server_port=${trojan_panel_core_port}" \
        jonssonyan/trojan-panel-core
    if [[ -n $(docker ps -q -f "name=^trojan-panel-core$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel内核The installation is complete"
    else
      echo_content red "---> Trojan Panel内核Install fail or Run abnormally, Please try to repair  or Uninstall reinstall"
      exit 0
    fi
  else
    echo_content skyBlue "---> 你已经Install 了Trojan Panel kernel"
  fi
}

# 更新Trojan Panel数据结构
update__trojan_panel_database() {
  echo_content skyBlue "---> 更新Trojan Panel数据结构"

  if [[ "${trojan_panel_current_version}" == "v1.3.1" ]]; then
    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -Dtrojan_panel_db -e "${sql_200}" &>/dev/null &&
      trojan_panel_current_version="v2.0.0"
  fi
  version_200_203=("v2.0.0" "v2.0.1" "v2.0.2")
  if [[ "${version_200_203[*]}" =~ "${trojan_panel_current_version}" ]]; then
    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -Dtrojan_panel_db -e "${sql_203}" &>/dev/null &&
      trojan_panel_current_version="v2.0.3"
  fi
  version_203_205=("v2.0.3" "v2.0.4")
  if [[ "${version_203_205[*]}" =~ "${trojan_panel_current_version}" ]]; then
    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -Dtrojan_panel_db -e "${sql_205}" &>/dev/null &&
      trojan_panel_current_version="v2.0.5"
  fi
  version_205_210=("v2.0.5")
  if [[ "${version_205_210[*]}" =~ "${trojan_panel_current_version}" ]]; then
    domain=$(cat "${DOMAIN_FILE}")
    if [[ -z "${domain}" ]]; then
      docker rm -f trojan-panel-caddy
      rm -rf /tpdata/caddy/srv/
      rm -rf /tpdata/caddy/cert/
      rm -f /tpdata/caddy/domain.lock
      install_reverse_proxy
      cp /tpdata/nginx/default.conf ${UI_NGINX_CONFIG} &&
        sed -i "s#/tpdata/caddy/cert/#${CERT_PATH}#g" ${UI_NGINX_CONFIG}
    fi
    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -Dtrojan_panel_db -e "${sql_210}" &>/dev/null &&
      trojan_panel_current_version="v2.1.0"
  fi
  version_210_211=("v2.1.0")
  if [[ "${version_210_211[*]}" =~ "${trojan_panel_current_version}" ]]; then
    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -Dtrojan_panel_db -e "${sql_211}" &>/dev/null &&
      trojan_panel_current_version="v2.1.1"
  fi
  version_211_212=("v2.1.1")
  if [[ "${version_211_212[*]}" =~ "${trojan_panel_current_version}" ]]; then
    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -Dtrojan_panel_db -e "${sql_212}" &>/dev/null &&
      trojan_panel_current_version="v2.1.2"
  fi
  version_212_214=("v2.1.2" "v2.1.3")
  if [[ "${version_212_214[*]}" =~ "${trojan_panel_current_version}" ]]; then
    docker cp trojan-panel:${trojan_panel_config_path} ${trojan_panel_config_path} &&
      trojan_panel_current_version="v2.1.4" &&
      echo '[server]
port=8081' >>${trojan_panel_config_path}

    docker rm -f trojan-panel-ui &&
      docker rmi -f jonssonyan/trojan-panel-ui

    docker pull jonssonyan/trojan-panel-ui &&
      docker run -d --name trojan-panel-ui --restart always \
        --network=host \
        -v "${UI_NGINX_CONFIG}":"/etc/nginx/conf.d/default.conf" \
        -v ${CERT_PATH}:${CERT_PATH} \
        jonssonyan/trojan-panel-ui

    if [[ -n $(docker ps -q -f "name=^trojan-panel-ui$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel front-end 更新完成"
    else
      echo_content red "---> Trojan Panel front-end 更新fail or Run abnormally, Please try to repair  or Uninstall reinstall"
    fi
  fi

  echo_content skyBlue "---> Trojan Panel数据结构更新完成"
}

# 更新Trojan Panel内核数据结构
update__trojan_panel_core_database() {
  echo_content skyBlue "---> 更新Trojan Panel内核数据结构"

  version_204_210=("v2.0.4")
  if [[ "${version_204_210[*]}" =~ "${trojan_panel_core_current_version}" ]]; then
    domain=$(cat "${DOMAIN_FILE}")
    if [[ -z "${domain}" ]]; then
      docker rm -f trojan-panel-caddy
      rm -rf /tpdata/caddy/srv/
      rm -rf /tpdata/caddy/cert/
      rm -f /tpdata/caddy/domain.lock
      install_reverse_proxy
      cp /tpdata/nginx/default.conf ${UI_NGINX_CONFIG} &&
        sed -i "s#/tpdata/caddy/cert/#${CERT_PATH}#g" ${UI_NGINX_CONFIG}
    fi
    trojan_panel_core_current_version="v2.1.0"
  fi
  version_210_211=("v2.1.0")
  if [[ "${version_210_211[*]}" =~ "${trojan_panel_core_current_version}" ]]; then
    docker cp trojan-panel-core:${trojan_panel_core_config_path} ${trojan_panel_core_config_path} &&
      trojan_panel_core_current_version="v2.1.1" &&
      echo '[server]
port=8082' >>${trojan_panel_core_config_path}
  fi

  echo_content skyBlue "---> Trojan Panel内核数据结构更新完成"
}

# 更新Trojan Panel Fron-tend
update_trojan_panel_ui() {
  # 判断Trojan Panel front-end 是否Install 
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-ui$") ]]; then
    echo_content red "---> 请先Install Trojan Panel Fron-tend"
    exit 0
  fi

  trojan_panel_ui_current_version=$(docker exec trojan-panel-ui cat ${TROJAN_PANEL_UI_DATA}version)
  if [[ -z "${trojan_panel_ui_current_version}" || ! "${trojan_panel_ui_current_version}" =~ ^v.* ]]; then
    echo_content red "---> 当前版本不支持自动化更新"
    exit 0
  fi

  echo_content yellow "hint：Trojan Panel Fron-tend(trojan-panel-ui)当前版本为 ${trojan_panel_ui_current_version} 最新版本为 ${trojan_panel_ui_latest_version}"

  if [[ "${trojan_panel_ui_current_version}" != "${trojan_panel_ui_latest_version}" ]]; then
    echo_content green "---> 更新Trojan Panel Fron-tend"

    docker rm -f trojan-panel-ui &&
      docker rmi -f jonssonyan/trojan-panel-ui

    docker pull jonssonyan/trojan-panel-ui &&
      docker run -d --name trojan-panel-ui --restart always \
        --network=host \
        -v "${UI_NGINX_CONFIG}":"/etc/nginx/conf.d/default.conf" \
        -v ${CERT_PATH}:${CERT_PATH} \
        jonssonyan/trojan-panel-ui

    if [[ -n $(docker ps -q -f "name=^trojan-panel-ui$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel front-end 更新完成"
    else
      echo_content red "---> Trojan Panel front-end 更新fail or Run abnormally, Please try to repair  or Uninstall reinstall"
    fi
  else
    echo_content skyBlue "---> 你Install 的Trojan Panel front-end 已经是最新版"
  fi
}

# 更新Trojan Panel back-tend
update_trojan_panel() {
  # 判断Trojan Panel后端是否Install 
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel$") ]]; then
    echo_content red "---> 请先Install Trojan Panel back-tend"
    exit 0
  fi

  trojan_panel_current_version=$(docker exec trojan-panel ./trojan-panel -version)
  if [[ -z "${trojan_panel_current_version}" || ! "${trojan_panel_current_version}" =~ ^v.* ]]; then
    echo_content red "---> 当前版本不支持自动化更新"
    exit 0
  fi

  echo_content yellow "hint：Trojan Panel back-tend(trojan-panel)当前版本为 ${trojan_panel_current_version} 最新版本为 ${trojan_panel_latest_version}"

  if [[ "${trojan_panel_current_version}" != "${trojan_panel_latest_version}" ]]; then
    echo_content green "---> 更新Trojan Panel back-tend"

    update__trojan_panel_database

    mariadb_ip=$(get_ini_value ${trojan_panel_config_path} mysql.host)
    mariadb_port=$(get_ini_value ${trojan_panel_config_path} mysql.port)
    mariadb_user=$(get_ini_value ${trojan_panel_config_path} mysql.user)
    mariadb_pas=$(get_ini_value ${trojan_panel_config_path} mysql.password)
    redis_host=$(get_ini_value ${trojan_panel_config_path} redis.host)
    redis_port=$(get_ini_value ${trojan_panel_config_path} redis.port)
    redis_pass=$(get_ini_value ${trojan_panel_config_path} redis.password)
    trojan_panel_port=$(get_ini_value ${trojan_panel_config_path} server.port)

    docker exec trojan-panel-redis redis-cli -h "${redis_host}" -p "${redis_port}" -a "${redis_pass}" -e "flushall" &>/dev/null

    docker rm -f trojan-panel &&
      docker rmi -f jonssonyan/trojan-panel

    docker pull jonssonyan/trojan-panel &&
      docker run -d --name trojan-panel --restart always \
        --network=host \
        -v ${WEB_PATH}:${TROJAN_PANEL_WEBFILE} \
        -v ${TROJAN_PANEL_LOGS}:${TROJAN_PANEL_LOGS} \
        -v ${TROJAN_PANEL_CONFIG}:${TROJAN_PANEL_CONFIG} \
        -v /etc/localtime:/etc/localtime \
        -e GIN_MODE=release \
        -e "mariadb_ip=${mariadb_ip}" \
        -e "mariadb_port=${mariadb_port}" \
        -e "mariadb_user=${mariadb_user}" \
        -e "mariadb_pas=${mariadb_pas}" \
        -e "redis_host=${redis_host}" \
        -e "redis_port=${redis_port}" \
        -e "redis_pass=${redis_pass}" \
        -e "server_port=${trojan_panel_port}" \
        jonssonyan/trojan-panel

    if [[ -n $(docker ps -q -f "name=^trojan-panel$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel后端更新完成"
    else
      echo_content red "---> Trojan Panel后端更新fail or Run abnormally, Please try to repair  or Uninstall reinstall"
    fi
  else
    echo_content skyBlue "---> 你Install 的Trojan Panel后端已经是最新版"
  fi
}

# 更新Trojan Panel kernel
update_trojan_panel_core() {
  # 判断Trojan Panel内核是否Install 
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-core$") ]]; then
    echo_content red "---> 请先Install Trojan Panel kernel"
    exit 0
  fi

  trojan_panel_core_current_version=$(docker exec trojan-panel-core ./trojan-panel-core -version)
  if [[ -z "${trojan_panel_core_current_version}" || ! "${trojan_panel_core_current_version}" =~ ^v.* ]]; then
    echo_content red "---> 当前版本不支持自动化更新"
    exit 0
  fi

  echo_content yellow "hint：Trojan Panel kernel(trojan-panel-core)当前版本为 ${trojan_panel_core_current_version} 最新版本为 ${trojan_panel_core_latest_version}"

  if [[ "${trojan_panel_core_current_version}" != "${trojan_panel_core_latest_version}" ]]; then
    echo_content green "---> 更新Trojan Panel kernel"

    update__trojan_panel_core_database

    mariadb_ip=$(get_ini_value ${trojan_panel_core_config_path} mysql.host)
    mariadb_port=$(get_ini_value ${trojan_panel_core_config_path} mysql.port)
    mariadb_user=$(get_ini_value ${trojan_panel_core_config_path} mysql.user)
    mariadb_pas=$(get_ini_value ${trojan_panel_core_config_path} mysql.password)
    redis_host=$(get_ini_value ${trojan_panel_core_config_path} redis.host)
    redis_port=$(get_ini_value ${trojan_panel_core_config_path} redis.port)
    redis_pass=$(get_ini_value ${trojan_panel_core_config_path} redis.password)
    grpc_port=$(get_ini_value ${trojan_panel_core_config_path} grpc.port)
    trojan_panel_core_port=$(get_ini_value ${trojan_panel_core_config_path} server.port)

    docker exec trojan-panel-redis redis-cli -h "${redis_host}" -p "${redis_port}" -a "${redis_pass}" -e "flushall" &>/dev/null

    docker rm -f trojan-panel-core &&
      docker rmi -f jonssonyan/trojan-panel-core

    domain=$(cat "${DOMAIN_FILE}")

    docker pull jonssonyan/trojan-panel-core &&
      docker run -d --name trojan-panel-core --restart always \
        --network=host \
        -v ${TROJAN_PANEL_CORE_DATA}bin/xray/config:${TROJAN_PANEL_CORE_DATA}bin/xray/config \
        -v ${TROJAN_PANEL_CORE_DATA}bin/trojango/config:${TROJAN_PANEL_CORE_DATA}bin/trojango/config \
        -v ${TROJAN_PANEL_CORE_DATA}bin/hysteria/config:${TROJAN_PANEL_CORE_DATA}bin/hysteria/config \
        -v ${TROJAN_PANEL_CORE_DATA}bin/naiveproxy/config:${TROJAN_PANEL_CORE_DATA}bin/naiveproxy/config \
        -v ${TROJAN_PANEL_CORE_LOGS}:${TROJAN_PANEL_CORE_LOGS} \
        -v ${TROJAN_PANEL_CORE_CONFIG}:${TROJAN_PANEL_CORE_CONFIG} \
        -v ${CERT_PATH}:${CERT_PATH} \
        -v ${WEB_PATH}:${WEB_PATH} \
        -v /etc/localtime:/etc/localtime \
        -e GIN_MODE=release \
        -e "mariadb_ip=${mariadb_ip}" \
        -e "mariadb_port=${mariadb_port}" \
        -e "mariadb_user=${mariadb_user}" \
        -e "mariadb_pas=${mariadb_pas}" \
        -e "database=${database}" \
        -e "account-table=${account_table}" \
        -e "redis_host=${redis_host}" \
        -e "redis_port=${redis_port}" \
        -e "redis_pass=${redis_pass}" \
        -e "crt_path=${CERT_PATH}${domain}.crt" \
        -e "key_path=${CERT_PATH}${domain}.key" \
        -e "grpc_port=${grpc_port}" \
        -e "server_port=${trojan_panel_core_port}" \
        jonssonyan/trojan-panel-core

    if [[ -n $(docker ps -q -f "name=^trojan-panel-core$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel内核更新完成"
    else
      echo_content red "---> Trojan Panel内核更新fail or Run abnormally, Please try to repair  or Uninstall reinstall"
    fi
  else
    echo_content skyBlue "---> 你Install 的Trojan Panel内核已经是最新版"
  fi
}

# Uninstall Caddy2
uninstall_caddy2() {
  # 判断Caddy2是否Install 
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-caddy$") ]]; then
    echo_content green "---> Uninstall Caddy2"

    docker rm -f trojan-panel-caddy &&
      rm -rf ${CADDY_DATA}

    echo_content skyBlue "---> Caddy2Uninstall 完成"
  else
    echo_content red "---> 请先Install Caddy2"
  fi
}

# Uninstall Nginx
uninstall_nginx() {
  # 判断Caddy2是否Install 
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-nginx") ]]; then
    echo_content green "---> Uninstall Nginx"

    docker rm -f trojan-panel-nginx &&
      rm -rf ${NGINX_DATA}

    echo_content skyBlue "---> NginxUninstall 完成"
  else
    echo_content red "---> 请先Install Nginx"
  fi
}

# Uninstall MariaDB
uninstall_mariadb() {
  # 判断MariaDB是否Install 
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-mariadb$") ]]; then
    echo_content green "---> Uninstall MariaDB"

    docker rm -f trojan-panel-mariadb &&
      rm -rf ${MARIA_DATA}

    echo_content skyBlue "---> MariaDBUninstall 完成"
  else
    echo_content red "---> 请先Install MariaDB"
  fi
}

# Uninstall Redis
uninstall_redis() {
  # 判断Redis是否Install 
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-redis$") ]]; then
    echo_content green "---> Uninstall Redis"

    docker rm -f trojan-panel-redis &&
      rm -rf ${REDIS_DATA}

    echo_content skyBlue "---> RedisUninstall 完成"
  else
    echo_content red "---> 请先Install Redis"
  fi
}

# Uninstall Trojan Panel Fron-tend
uninstall_trojan_panel_ui() {
  # 判断Trojan Panel front-end 是否Install 
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-ui$") ]]; then
    echo_content green "---> Uninstall Trojan Panel Fron-tend"

    docker rm -f trojan-panel-ui &&
      docker rmi -f jonssonyan/trojan-panel-ui &&
      rm -rf ${TROJAN_PANEL_UI_DATA}

    echo_content skyBlue "---> Trojan Panel front-end Uninstall 完成"
  else
    echo_content red "---> 请先Install Trojan Panel Fron-tend"
  fi
}

# Uninstall Trojan Panel back-tend
uninstall_trojan_panel() {
  # 判断Trojan Panel后端是否Install 
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel$") ]]; then
    echo_content green "---> Uninstall Trojan Panel back-tend"

    docker rm -f trojan-panel &&
      docker rmi -f jonssonyan/trojan-panel &&
      rm -rf ${TROJAN_PANEL_DATA}

    echo_content skyBlue "---> Trojan Panel后端Uninstall 完成"
  else
    echo_content red "---> 请先Install Trojan Panel back-tend"
  fi
}

# Uninstall Trojan Panel kernel
uninstall_trojan_panel_core() {
  # 判断Trojan Panel内核是否Install 
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-core$") ]]; then
    echo_content green "---> Uninstall Trojan Panel kernel"

    docker rm -f trojan-panel-core &&
      docker rmi -f jonssonyan/trojan-panel-core &&
      rm -rf ${TROJAN_PANEL_CORE_DATA}

    echo_content skyBlue "---> Trojan Panel内核Uninstall 完成"
  else
    echo_content red "---> 请先Install Trojan Panel kernel"
  fi
}

# Uninstall 全部Trojan Panel相关的容器
uninstall_all() {
  echo_content green "---> Uninstall 全部Trojan Panel相关的容器"

  docker rm -f $(docker ps -a -q -f "name=^trojan-panel")
  docker rmi -f $(docker images | grep "^jonssonyan/trojan-panel" | awk '{print $3}')
  rm -rf ${TP_DATA}

  echo_content skyBlue "---> Uninstall 全部Trojan Panel相关的容器完成"
}

# 修改Trojan Panel front-end 端口
update_trojan_panel_ui_port() {
  if [[ -n $(docker ps -q -f "name=^trojan-panel-ui$" -f "status=running") ]]; then
    echo_content green "---> 修改Trojan Panel front-end 端口"

    trojan_panel_ui_port=$(grep 'listen.*ssl' ${UI_NGINX_CONFIG} | awk '{print $2}')
    if [[ -z "${trojan_panel_ui_port}" ]]; then
      ui_https=0
      trojan_panel_ui_port=$(grep -oP 'listen\s+\K\d+' ${UI_NGINX_CONFIG} | awk 'NR==1')
    fi
    if [[ -z "${trojan_panel_ui_port}" ]]; then
      echo_content red "---> 未查询到Trojan Panel front-end  port "
      exit 0
    fi
    echo_content yellow "hint：Trojan Panel Fron-tend(trojan-panel-ui)当 front-end 口为 ${trojan_panel_ui_port}"

    read -r -p "Please enter Trojan Panel front-end 新端口(default:8888): " trojan_panel_ui_port
    [[ -z "${trojan_panel_ui_port}" ]] && trojan_panel_ui_port="8888"

    if [[ ${ui_https} == 0 ]]; then
      # http
      sed -i "s/listen.*;/listen       ${trojan_panel_ui_port};/g" ${UI_NGINX_CONFIG} &&
        sed -i "s/http:\/\/\$host:.*\$request_uri;/http:\/\/\$host:${trojan_panel_ui_port}\$request_uri;/g" ${UI_NGINX_CONFIG} &&
        docker restart trojan-panel-ui
    else
      # https
      sed -i "s/listen.*ssl;/listen       ${trojan_panel_ui_port} ssl;/g" ${UI_NGINX_CONFIG} &&
        sed -i "s/https:\/\/\$host:.*\$request_uri;/https:\/\/\$host:${trojan_panel_ui_port}\$request_uri;/g" ${UI_NGINX_CONFIG} &&
        docker restart trojan-panel-ui
    fi

    if [[ "$?" == "0" ]]; then
      echo_content skyBlue "---> Trojan Panel front-end 端口修改完成"
    else
      echo_content red "---> Trojan Panel front-end 端口修改fail"
    fi
  else
    echo_content red "---> Trojan Panel front-end 未Install  or Run abnormally,请修复 or Uninstall reinstall后重试"
  fi
}

# 刷新Redis缓存
redis_flush_all() {
  # 判断Redis是否Install 
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-redis$") ]]; then
    echo_content red "---> 请先Install Redis"
    exit 0
  fi

  if [[ -z $(docker ps -q -f "name=^trojan-panel-redis$" -f "status=running") ]]; then
    echo_content red "---> RedisRun abnormally"
    exit 0
  fi

  echo_content green "---> 刷新Redis缓存"

  read -r -p "Please enter Redis的IP地址(default:本机Redis): " redis_host
  [[ -z "${redis_host}" ]] && redis_host="127.0.0.1"
  read -r -p "Please enter Redis port (default:6378): " redis_port
  [[ -z "${redis_port}" ]] && redis_port=6378
  while read -r -p "Please enter Redis的密码(required): " redis_pass; do
    if [[ -z "${redis_pass}" ]]; then
      echo_content red "password can not be blank"
    else
      break
    fi
  done

  docker exec trojan-panel-redis redis-cli -h "${redis_host}" -p "${redis_port}" -a "${redis_pass}" -e "flushall" &>/dev/null

  echo_content skyBlue "---> Redis缓存刷新完成"
}

# 更换证书
change_cert() {
  domain_1=$(cat "${DOMAIN_FILE}")

  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-caddy$") ]]; then
    docker rm -f trojan-panel-caddy &&
      rm -rf ${CADDY_LOG}* &&
      echo "" >${CADDY_CONFIG} &&
      rm -rf ${WEB_PATH}*
  fi

  rm -rf ${CERT_PATH}* &&
    echo "" >${DOMAIN_FILE}

  install_cert

  domain_2=$(cat "${DOMAIN_FILE}")
  if [[ -n "${domain_1}" && -n "${domain_2}" ]]; then
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-nginx$") ]]; then
      sed -i "s/${domain_1}/${domain_2}/g" ${NGINX_CONFIG} &&
        docker restart trojan-panel-nginx
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-ui$") ]]; then
      sed -i "s/${domain_1}/${domain_2}/g" ${UI_NGINX_DATA} &&
        docker restart trojan-panel-ui
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-core$") ]]; then
      find /tpdata/trojan-panel-core/bin/ -type f -exec sed -i "s/${domain_1}/${domain_2}/g" {} + &&
        sed -i "s/${domain_1}/${domain_2}/g" ${trojan_panel_core_config_path} &&
        docker restart trojan-panel-core
    fi
  fi
}

forget_pass() {
  while :; do
    echo_content yellow "1. 查询MariaDB密码"
    echo_content yellow "2. 查询Redis密码"
    echo_content yellow "3. 重设管理面板系统管理员用户名和密码"
    echo_content yellow "4. 退出"
    read -r -p "please choose(default:4): " forget_pass_option
    [[ -z "${forget_pass_option}" ]] && forget_pass_option=4
    case ${forget_pass_option} in
    1)
      if [[ -n $(docker ps -a -q -f "name=^trojan-panel$") ]]; then
        mariadb_user=$(get_ini_value ${trojan_panel_config_path} mysql.user)
        mariadb_pas=$(get_ini_value ${trojan_panel_config_path} mysql.password)
        echo_content red "\n=============================================================="
        echo_content yellow "MariaDB ${mariadb_user}的密码(please keep it safe): ${mariadb_pas}"
        echo_content red "\n=============================================================="
      else
        echo_content red "---> 请先Install Trojan Panel back-tend"
      fi
      ;;
    2)
      if [[ -n $(docker ps -a -q -f "name=^trojan-panel$") ]]; then
        redis_pass=$(get_ini_value ${trojan_panel_config_path} redis.password)
        echo_content red "\n=============================================================="
        echo_content yellow "Redis的密码(please keep it safe): ${redis_pass}"
        echo_content red "\n=============================================================="
      else
        echo_content red "---> 请先Install Trojan Panel back-tend"
      fi
      ;;
    3)
      if [[ -n $(docker ps -a -q -f "name=^trojan-panel-mariadb$") ]]; then
        read -r -p "Please enter 数据库的IP地址(default:本机数据库): " mariadb_ip
        [[ -z "${mariadb_ip}" ]] && mariadb_ip="127.0.0.1"
        read -r -p "Please enter 数据库 port (default:9507): " mariadb_port
        [[ -z "${mariadb_port}" ]] && mariadb_port=9507
        read -r -p "Please enter The user name of the database(default:root): " mariadb_user
        [[ -z "${mariadb_user}" ]] && mariadb_user="root"
        while read -r -p "Please enter database password(required): " mariadb_pas; do
          if [[ -z "${mariadb_pas}" ]]; then
            echo_content red "password can not be blank"
          else
            break
          fi
        done

        docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -Dtrojan_panel_db -e "update account set username = 'sysadmin',pass = 'tFjD2X1F6i9FfWp2GDU5Vbi1conuaChDKIYbw9zMFrqvMoSz',hash='4366294571b8b267d9cf15b56660f0a70659568a86fc270a52fdc9e5' where id = 1 limit 1"
        if [[ "$?" == "0" ]]; then
          echo_content red "\n=============================================================="
          echo_content yellow "系统管理员 默认用户名: sysadmin 默认密码: 123456 请及时登陆管理面板修改密码"
          echo_content red "\n=============================================================="
        else
          echo_content red "管理面板系统管理员用户名和密码重设fail"
        fi
      else
        echo_content red "---> 请先Install MariaDB"
      fi
      ;;
    4)
      break
      ;;
    *)
      echo_content red "Without this option"
      continue
      ;;
    esac
  done
}

# 故障检测
failure_testing() {
  echo_content green "---> Fault detection starts"
  if [[ ! $(docker -v 2>/dev/null) ]]; then
    echo_content red "---> Docker Run abnormally"
  else
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-caddy$") ]]; then
      if [[ -z $(docker ps -q -f "name=^trojan-panel-caddy$" -f "status=running") ]]; then
        echo_content red "---> Caddy2Run abnormally 错误日志如下："
        docker logs trojan-panel-caddy
      fi
      domain=$(cat "${DOMAIN_FILE}")
      if [[ -z ${domain} || ! -d "${CERT_PATH}" || ! -f "${CERT_PATH}${domain}.crt" ]]; then
        echo_content red "---> 证书申请异常，请尝试 1.换个子域名重新搭建 2.重启服务器将重新申请证书 3.重新搭建选择自定义证书选项 日志如下："
        if [[ -f ${CADDY_LOG}error.log ]]; then
          tail -n 20 ${CADDY_LOG}error.log | grep error
        else
          docker logs trojan-panel-caddy
        fi
      fi
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-mariadb$") && -z $(docker ps -q -f "name=^trojan-panel-mariadb$" -f "status=running") ]]; then
      echo_content red "---> MariaDBRun abnormally 日志如下："
      docker logs trojan-panel-mariadb
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-redis$") && -z $(docker ps -q -f "name=^trojan-panel-redis$" -f "status=running") ]]; then
      echo_content red "---> RedisRun abnormally 日志如下："
      docker logs trojan-panel-redis
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel$") && -z $(docker ps -q -f "name=^trojan-panel$" -f "status=running") ]]; then
      echo_content red "---> Trojan Panel后端Run abnormally 日志如下："
      if [[ -f ${TROJAN_PANEL_LOGS}trojan-panel.log ]]; then
        tail -n 20 ${TROJAN_PANEL_LOGS}trojan-panel.log | grep error
      else
        docker logs trojan-panel
      fi
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-ui$") && -z $(docker ps -q -f "name=^trojan-panel-ui$" -f "status=running") ]]; then
      echo_content red "---> Trojan Panel front-end Run abnormally 日志如下："
      docker logs trojan-panel-ui
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-core$") && -z $(docker ps -q -f "name=^trojan-panel-core$" -f "status=running") ]]; then
      echo_content red "---> Trojan Panel内核Run abnormally 日志如下："
      if [[ -f ${TROJAN_PANEL_CORE_LOGS}trojan-panel.log ]]; then
        tail -n 20 ${TROJAN_PANEL_CORE_LOGS}trojan-panel.log | grep error
      else
        docker logs trojan-panel-core
      fi
    fi
  fi
  echo_content green "---> 故障检测结束"
}

log_query() {
  while :; do
    echo_content skyBlue "可以查询日志的应用如下:"
    echo_content yellow "1. Trojan Panel back-tend"
    echo_content yellow "2. Trojan Panel kernel"
    echo_content yellow "3. 退出"
    read -r -p "please choose应用(default:1): " select_log_query_type
    [[ -z "${select_log_query_type}" ]] && select_log_query_type=1

    case ${select_log_query_type} in
    1)
      log_file_path=${TROJAN_PANEL_LOGS}trojan-panel.log
      ;;
    2)
      log_file_path=${TROJAN_PANEL_CORE_LOGS}trojan-panel-core.log
      ;;
    3)
      break
      ;;
    *)
      echo_content red "Without this option"
      continue
      ;;
    esac

    read -r -p "Please enter The number of queries(default:20): " select_log_query_line_type
    [[ -z "${select_log_query_line_type}" ]] && select_log_query_line_type=20

    if [[ -f ${log_file_path} ]]; then
      echo_content skyBlue "日志如下:"
      tail -n ${select_log_query_line_type} ${log_file_path}
    else
      echo_content red "不存在日志文件"
    fi
  done
}

version_query() {
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-ui$") && -n $(docker ps -q -f "name=^trojan-panel-ui$" -f "status=running") ]]; then
    trojan_panel_ui_current_version=$(docker exec trojan-panel-ui cat ${TROJAN_PANEL_UI_DATA}version)
    echo_content yellow "Trojan Panel Fron-tend(trojan-panel-ui)当前版本为 ${trojan_panel_ui_current_version} 最新版本为 ${trojan_panel_ui_latest_version}"
  fi
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel$") && -n $(docker ps -q -f "name=^trojan-panel$" -f "status=running") ]]; then
    trojan_panel_current_version=$(docker exec trojan-panel ./trojan-panel -version)
    echo_content yellow "Trojan Panel back-tend(trojan-panel)当前版本为 ${trojan_panel_current_version} 最新版本为 ${trojan_panel_latest_version}"
  fi
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-core$") && -n $(docker ps -q -f "name=^trojan-panel-core$" -f "status=running") ]]; then
    trojan_panel_core_current_version=$(docker exec trojan-panel-core ./trojan-panel-core -version)
    echo_content yellow "Trojan Panel kernel(trojan-panel-core)当前版本为 ${trojan_panel_core_current_version} 最新版本为 ${trojan_panel_core_latest_version}"
  fi
}

main() {
  cd "$HOME" || exit 0
  init_var
  mkdir_tools
  check_sys
  depend_install
  clear
  echo_content red "\n=============================================================="
  echo_content skyBlue "System Required: CentOS 7+/Ubuntu 18+/Debian 10+"
  echo_content skyBlue "Version: v2.1.6"
  echo_content skyBlue "Description: One click Install Trojan Panel server"
  echo_content skyBlue "Author: jonssonyan <https://jonssonyan.com>"
  echo_content skyBlue "Github: https://github.com/trojanpanel"
  echo_content skyBlue "Docs: https://trojanpanel.github.io"
  echo_content red "\n=============================================================="
  echo_content yellow "1. Install Trojan Panel front end"
  echo_content yellow "2. Install Trojan Panel back end"
  echo_content yellow "3. Install the Trojan Panel kernel"
  echo_content yellow "4. Install Caddy2"
  echo_content yellow "5. Install nginx"
  echo_content yellow "6. Install MariaDB"
  echo_content yellow "7. Install Redis"
  echo_content green "\n=============================================================="
  echo_content yellow "8.  Update Trojan Panel front end"
  echo_content yellow "9.  Update Trojan Panel back end"
  echo_content yellow "10. Update Trojan Panel kernel"
  echo_content green "\n=============================================================="
  echo_content yellow "11. Uninstall the front end of Trojan Panel"
  echo_content yellow "12. Uninstall the back end of Trojan Panel"
  echo_content yellow "13. Uninstall Trojan Panel kernel"
  echo_content yellow "14. Uninstall Caddy2"
  echo_content yellow "15. Uninstall nginx"
  echo_content yellow "16. Uninstall MariaDB"
  echo_content yellow "17. Uninstall Redis"
  echo_content yellow "18. Uninstall all applications related to Trojan Panel"
  echo_content green "\n=============================================================="
  echo_content yellow "19. Modify the front port of Trojan Panel"
  echo_content yellow "20. Refresh the Redis cache"
  echo_content yellow "21. Replace the certificate"
  echo_content yellow "22. Forget password"
  echo_content green "\n=============================================================="
  echo_content yellow "23. Failure testing"
  echo_content yellow "24. Log query"
  echo_content yellow "25. Version query"
  read -r -p "please choose:" selectInstall_type
  case ${selectInstall_type} in
  1)
    install_docker
    install_cert
    install_trojan_panel_ui
    ;;
  2)
    install_docker
    install_mariadb
    install_redis
    install_trojan_panel
    ;;
  3)
    install_docker
    install_reverse_proxy
    install_cert
    install_trojan_panel_core
    ;;
  4)
    install_docker
    install_caddy2
    ;;
  5)
    install_docker
    install_nginx
    ;;
  6)
    install_docker
    install_mariadb
    ;;
  7)
    install_docker
    install_redis
    ;;
  8)
    update_trojan_panel_ui
    ;;
  9)
    update_trojan_panel
    ;;
  10)
    update_trojan_panel_core
    ;;
  11)
    uninstall_trojan_panel_ui
    ;;
  12)
    uninstall_trojan_panel
    ;;
  13)
    uninstall_trojan_panel_core
    ;;
  14)
    uninstall_caddy2
    ;;
  15)
    uninstall_nginx
    ;;
  16)
    uninstall_mariadb
    ;;
  17)
    uninstall_redis
    ;;
  18)
    uninstall_all
    ;;
  19)
    update_trojan_panel_ui_port
    ;;
  20)
    redis_flush_all
    ;;
  21)
    change_cert
    ;;
  22)
    forget_pass
    ;;
  23)
    failure_testing
    ;;
  24)
    log_query
    ;;
  25)
    version_query
    ;;
  *)
    echo_content red "Without this option"
    ;;
  esac
}

main
