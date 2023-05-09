#!/bin/sh
#==========================#
###### Author: CuteBi ######
#==========================#

option() {
    echo -n $echo_opt_e "1. 安装项目\n2. 卸载项目\n请输入选项(默认为1)\n(妖火-胡歌-ID:29109): "
    read install_opt
    echo "$install_opt"|grep -q '2' && task_type='uninstall' || task_type='install'
    echo -n $echo_opt_e "可选项目:
    \r1. cns
    \r2. xray
	\r3. ygk(YGK安装之前先更新uzip，ubuntu系统先执行 sudo apt-get update 然后执行 apt-get install zip unzip 如果是centos系统，请执行 yum -y install zip unzip  )
    \r请选择项目(多个用空格隔开): "
    read build_projects
    echo -n '后台运行吗?(输出保存在builds.out文件)[n]: '
    read daemon_run
}

getAbi() {
    abi=`uname -m`
    if echo "$abi"|grep -Eq 'i686|i386'; then
        abi="32"
    elif echo "$abi"|grep -Eq 'armv7|armv6'; then
        abi="arm"
    elif echo "$abi"|grep -Eq 'armv8|aarch64'; then
        abi="arm64"
    #mips使用le版本
    elif echo "$abi"|grep -q 'mips64'; then
        abi="mips64le"
    elif echo "$abi"|grep -q 'mips'; then
        abi="mipsle"
    else
        abi="64"
    fi
}


cns_set() {
	echo -n '请输入cns服务端口(如果不用请留空): '
	read cns_port
	echo -n '请输入cns加密密码(默认不加密): '
	read cns_encrypt_password
	echo -n "请输入cns的udp标识(默认: 'httpUDP'): "
	read cns_udp_flag
	echo -n "请输入cns代理头域(默认: 'Meng'): "
	read cns_proxy_key
	echo -n '请输入tls服务端口(如果不用请留空): '
	read cns_tls_port
	echo -n '请输入cns安装目录(默认/usr/local/cns): '
	read cns_install_dir
	echo -n "安装UPX压缩版本?[n]: "
	read cns_UPX
	echo "$cns_UPX"|grep -qi '^y' && cns_UPX="upx" || cns_UPX=""
	[ -z "$cns_install_dir" ] && cns_install_dir='/usr/local/cns'
	export cns_port cns_encrypt_password cns_udp_flag cns_proxy_key cns_tls_port cns_install_dir cns_UPX
}


xray_set() {
	echo -n "请输入xray安装目录(默认/usr/local/xray): "
	read xray_install_directory
	echo -n "安装UPX压缩版本?[n]: "
	read xray_UPX
	echo "$xray_UPX"|grep -qi '^y' && xray_UPX="upx" || xray_UPX=""
	echo $echo_opt_e "options(tls默认为自签名证书, 如有需要请自行更改):
	\r\t1. tcp_http(vmess)
	\r\t2. WebSocket(vmess)
	\r\t3. WebSocket+tls(vless)
	\r\t4. mkcp(vmess)
	\r\t5. mkcp+tls(vless)
	\r\t6. tcp+xtls(vless)
	\r请输入你的选项(用空格分隔多个选项):"
	read xray_inbounds_options
	for opt in $xray_inbounds_options; do
		case $opt in
			1)
				echo -n "请输入xray http端口: "
				read xray_http_port
			;;
			2)
				echo -n "请输入xray webSocket端口: "
				read xray_ws_port
				echo -n "请输入xray WebSocket请求头的Path(默认为/): "
				read xray_ws_path
				xray_ws_path=${xray_ws_path:-/}
			;;
			3)
				echo -n "请输入xray webSocket tls端口: "
				read xray_ws_tls_port
				echo -n "请输入xray WebSocket请求头的Path(默认为/): "
				read xray_ws_tls_path
				xray_ws_tls_path=${xray_ws_tls_path:-/}
			;;
			4)
				echo -n "请输入xray mKCP端口: "
				read xray_mkcp_port
			;;
			5)
				echo -n "请输入xray mKCP xtls端口: "
				read xray_mkcp_xtls_port
			;;
			6)
				echo -n "请输入xray tcp xtls端口: "
				read xray_tcp_xtls_port
			;;
		esac
	done
	[ -z "$xray_install_directory" ] && xray_install_directory='/usr/local/xray'
	export xray_install_directory xray_UPX xray_inbounds_options xray_http_port xray_ws_port xray_ws_path xray_ws_tls_port xray_ws_tls_path xray_mkcp_port xray_mkcp_xtls_port xray_tcp_xtls_port
}


ygk_set(){
        wget https://wuyi-1251424646.cos.ap-beijing-1.myqcloud.com/ygk/ygk.sh 
		echo
        chmod 777 ygk.sh
            echo -n 'YGK安装目录默认为(/usr/local/ygk): '
			bash ygk.sh
  
    rm -f ygk.sh
}


cns_task() {
	if $download_tool_cmd cns.sh https://wuyi-1251424646.cos.ap-beijing-1.myqcloud.com/cns/cns.sh; then
		chmod 777 cns.sh
		sed -i "s~#!/bin/bash~#!$SHELL~" cns.sh
		if [ "$task_type" != 'install' ]; then
			echo -n '请输cns卸载目录(默认/usr/local/cns): '
			read cns_install_directory
		fi
		echo $echo_opt_e "n\ny\ny\ny\ny\n"|./cns.sh $task_type && \
				echo 'cns任务成功' >>builds.log || \
				echo 'cns启动失败' >>builds.log
	else
		echo 'cns脚本下载失败' >>builds.log
	fi
	rm -f cns.sh
}


xray_task() {
	if $download_tool_cmd xray.sh http://wuyi-1251424646.costj.myqcloud.com/xray/xray.sh; then
		chmod 777 xray.sh
		sed -i "s~#!/bin/bash~#!$SHELL~" xray.sh
		if [ "$task_type" != 'install' ]; then
			echo -n '请输入xray卸载目录(默认/usr/local/xray): '
			read xray_install_directory
		fi
		echo $echo_opt_e "n\ny\ny\ny\ny\n"|./xray.sh $task_type && \
			echo 'xray任务成功' >>builds.log || \
			echo 'xray任务失败' >>builds.log
	else
		echo 'xray脚本下载失败' >>builds.log
	fi
	rm -f xray.sh
}

ygk_task() {
             echo
             echo $echo_opt_e "\033[32m如需卸载ygk: 请输入ygk，选择2卸载ygk\033[0m"
			 echo
}

ygk_uninstall_set() {
	return
}

cns_uninstall_set() {
	echo -n '请输入cns安装目录(默认/usr/local/cns): '
	read cns_install_dir
	[ -z "$cns_install_dir" ] && cns_install_dir='/usr/local/cns'
	export cns_install_dir
}


xray_uninstall_set() {
	echo -n "请输入xray安装目录(默认/usr/local/xray): "
	read xray_install_directory
	[ -z "$xray_install_directory" ] && xray_install_directory='/usr/local/xray'
	export xray_install_directory
}

server_install_set() {
	for opt in $*; do
		case $opt in
			1) cns_set;;
			2) xray_set;;
			3) ygk_set;;
			*) exec echo "选项($opt)不正确，请输入正确的选项！";;
		esac
	done
}

server_uninstall_set() {
	for opt in $*; do
		case $opt in
			1) cns_uninstall_set;;
			2) xray_uninstall_set;;
			3) ygk_uninstall_set;;
			*) exec echo "选项($opt)不正确，请输入正确的选项！";;
		esac
	done
}

server_set() {
    for opt in $*; do
        case $opt in
            1) cns_set;;
            2) xray_set;;
			3) ygk_set;;
            *) exec echo "选项($opt)不正确，请输入正确的选项！";;
        esac
    done
}

start_task() {
    dnsip=`grep nameserver /etc/resolv.conf | grep -Eo '[1-9]{1,3}[0-9]{0,2}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1`
    getAbi
    for opt in $*; do
        case $opt in
            1) cns_task;;
            2) xray_task;;
			3) ygk_task;;
        esac
        sleep 1
    done
    echo '所有任务完成' >>builds.log
    echo $echo_opt_e "\033[32m`cat builds.log 2>&-`\033[0m"
	echo
	rm -f ./clncv2.sh
}

run_tasks() {
	[ "$task_type" != 'uninstall' ] && server_install_set $build_projects || server_uninstall_set $build_projects
	if echo "$daemon_run"|grep -qi 'y'; then
		(`start_task $build_projects &>builds.out` &)
		echo "正在后台运行中......"
	else
		start_task $build_projects
		rm -f builds.log
	fi
}

init() {
    emulate bash 2>/dev/null #zsh仿真模式
    echo -e '' | grep -q 'e' && echo_opt_e='' || echo_opt_e='-e' #dash的echo没有-e选项
    PM=`which apt-get || which yum`
	type curl || type wget || $PM -y install curl wget
    type curl && download_tool_cmd='curl -sko' || download_tool_cmd='wget --no-check-certificate -qO'
    rm -f builds.log builds.out
    clear
}

main() {
    init
    option
    run_tasks
}

main
