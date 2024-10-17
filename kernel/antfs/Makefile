包括 $(TOPDIR)/rules.mk
包含 $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=antfs
PKG_RELEASE:=2

PKG_SOURCE_URL:=https://github.com/klukonin/antfs.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2020-02-10
PKG_SOURCE_VERSION:=b41ba529f6b64b429527e09a06ce0326d5456c05
PKG_MIRROR_HASH:=dae039c0fe5bf1a2c8c1cca4211d607a4d6f56fc41b38444e2234b40d710d9db

PKG_LICENSE:=GPL-2.0-或更高版本
PKG_LICENSE_FILES:=许可证

包含 $(INCLUDE_DIR)/package.mk

定义 KernelPackage/fs-antfs
	子菜单:=文件系统
	标题：=AVM NTFS 读/写驱动程序
	文件:=$(PKG_BUILD_DIR)/antfs.ko
	自动加载:=$(调用自动加载,30,antfs,1)
	取决于：=+kmod-nls-base
恩德夫

定义 KernelPackage/fs-antfs/description
	NTFS 文件系统的内核模块
恩德夫

MAKE_OPTS:= \
        ARCH =“$（LINUX_KARCH）”\
        CROSS_COMPILE =“$（TARGET_CROSS）”\
        M =“$（PKG_BUILD_DIR）”

定义构建/编译
	$(MAKE) -C "$(LINUX_DIR)" \
		$(MAKE_OPTS) \
		CONFIG_ANTFS_FS=m \
		CONFIG_ANTFS_SYMLINKS=y \
		ANTFS_VERSION=07.19-$(调用 version_abbrev,$(PKG_SOURCE_VERSION)) \
		模块
恩德夫

$ ( eval $(call KernelPackage,fs-antfs) )
