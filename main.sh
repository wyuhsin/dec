#!/bin/bash

formulas=(
	"sudo"
	"git"
	"gdb"
	"gcc"
	"tmux"
	"vim"
	"neovim"
	"make"
	"ranger"
	"net-tools"
	"go"
	"sshpass"
	"protobuf"
	"node"
	"nodejs"
	"npm"
	"python"
	"telnet"
	"tcpdump"
	"rust"
	"rust-analyzer"
	"cargo"
	"which"
	"fzf"
	"ripgrep"
	"lua"
)

casks=(
	"apifox"
	"chatgpt"
	"wechat"
	"wechatwork"
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
	"wpsoffice"
	"xmind"
)


function check_error() {
	[[ $? -ne 0 ]] && { echo "ERROR: $1 failed"; exit 1; }
}

function init_shell() {
	current_shell=$(basename "$SHELL")
	target=""

	case "$current_shell" in
		bash)
			target="${HOME}/.bashrc"
			;;
		zsh)
			target="${HOME}/.zshrc"
			;;
		fish)
			target="${HOME}/.config/fish/config.fish"
			;;
		*)
			echo "Unsupported shell: $current_shell"
			;;
	esac

	if [ -e ${target} ] || [ -L ${target} ]; then
		rm -f ${target}
	fi

	ln -s $(pwd)/shellrc ${target}
}

function init_vim() {
	target="${HOME}/.vimrc"

	if [ -e ${target} ] || [ -L ${target} ]; then
		rm -f ${target}
	fi

	ln -s $(pwd)/vimrc ${target}
}

function init_neovim() {
	target="${HOME}/.config/nvim/init.lua"

	if [ -e ${target} ] || [ -L ${target} ]; then
		rm -f ${target}
	fi

	mkdir -p "${HOME}/.config/nvim"

	ln -s $(pwd)/init.lua ${target}

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
	if [[ "$OSTYPE" == "darwin"* ]]; then
		install_homebrew
		install_command="brew install "

		s=""

		for item in ${casks[@]}; do
			if command -v ${item} > /dev/null 2>&1; then
				echo "INFO: ${item} has been installed"
				continue
			fi

			s="${s} ${item}"
		done

		${install_command} --cask ${s}

		# s=""

		# for item in ${formulas[@]}; do
		# 	if command -v ${item} > /dev/null 2>&1; then
		# 		echo "INFO: ${item} has been installed"
		# 		continue
		# 	fi

		# 	s="${s} ${item}"
		# done

		${install_command} ${s}
	elif [[ -f /etc/arch-release ]]; then
		install_yay
		install_command="sudo pacman -Syu --noconfirm "
		
		if ! command -v sudo > /dev/null 2>&1; then
			pacman -Syu --noconfirm sudo
		fi

		s=""

		for item in ${formulas[@]}; do
			if command -v ${item} > /dev/null 2>&1; then
				echo "INFO: ${item} has been installed"
				continue
			fi

			s="${s} ${item}"
		done

		${install_command} ${s}
	else
		echo "ERROR: Unsupported OS" && return
	fi
}

function init_git() {
	git config --global push.default current
	git config --global fetch.prune true
}

function main() {
	install_software
	init_neovim
	init_shell
	init_git
}

main

