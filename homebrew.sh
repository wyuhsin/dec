#!/bin/bash

formulaes=(
	"git"
	"sudo"
	"vim"
	"make"
	"gdb"
	"gcc"
	"tmux"
	"ranger"
	"go"
	"sshpass"
	"protobuf"
	"node"
	"the_silver_searcher"
)

casks=(
	"apifox"
	"chatgpt"
	"dingtalk"
	"google-chrome"
	"microsoft-remote-desktop"
	"navicat-premium"
	"omnigraffle"
	"openvpn-connect"
	"orbstack"
	"paper"
	"sunloginclient"
	"tencent-lemon"
	"termius"
	"wechat"
	"wechatwork"
	"wpsoffice"
	"xmind"
)


function check_error() {
	[[ $? -ne 0 ]] && { echo "ERROR: $1 failed"; exit 1; }
}

function install_homebrew() {

	if ! command -v brew > /dev/null 2>&1; then

		echo "INFO: homebrew is not installed, installing homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

		check_error "Install homebrew"

		if [[ "$OSTYPE" == "darwin"* ]]; then
			if [[ -r ~/.zshrc ]]; then
				echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
				. ~/.zshrc
			elif [[ -r ~/.bashrc ]]; then
				echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bashrc
				. ~/.bashrc
			fi
			eval "$(/opt/homebrew/bin/brew shellenv)"

		else
			if [[ -r ~/.zshrc ]]; then
				echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
				. ~/.zshrc
			elif [[ -r ~/.bashrc ]]; then
				echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
				. ~/.bashrc
			fi

			eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
		fi

		brew tap beeftornado/rmtree
		check_error "Load homebrew enviorment variables"
	fi

}

function install_yay() {

	if ! command -v yay > /dev/null 2>&1; then
		echo "INFO: yay is not installed, installing yay..."
		
		sudo bash -c 'echo [archlinuxcn] >> /etc/pacman.conf'
		sudo bash -c 'echo Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch >> /etc/pacman.conf'
		sudo pacman -Sy
		sudo pacman -S archlinuxcn-keyring
		sudo pacman -S yay
	fi

	check_error "Install yay"

}

function install_software() {

	install_homebrew
	install_command="brew install"

	if [[ "$OSTYPE" == "darwin"* ]]; then
		for item in ${formulaes[@]}; do
			if command -v ${item} > /dev/null 2>&1; then
				echo "INFO: ${item} has been installed"
				continue
			fi

			${install_command} ${item}
		done

		for item in ${casks[@]}; do
			if command -v ${item} > /dev/null 2>&1; then
				echo "INFO: ${item} has been installed"
				continue
			fi

			${install_command} --cask ${item}
		done

	elif [[ -f /etc/arch-release ]]; then
		if ! command -v sudo > /dev/null 2>&1; then
			sudo pacman -Syu --noconfirm sudo
		fi

		for item in ${formulaes[@]}; do
			if command -v ${item} > /dev/null 2>&1; then
				echo "INFO: ${item} has been installed"
				continue
			fi

			${install_command} ${item}
		done
	else
		echo "ERROR: Unsupported OS" && return
	fi

}


function main() {
	install_software
}

main


