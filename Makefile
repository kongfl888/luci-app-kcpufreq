# [K] (C)2020
# http://github.com/kongfl888

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-kcpufreq
PKG_VERSION:=1.3
PKG_RELEASE:=1
PKG_DATE:=20200820

PKG_MAINTAINER:=kongfl888 <kongfl888@outlook.com>
PKG_LICENSE:=GPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI for CPU Freq Setting from Mr.K
  PKGARCH:=all
  DEPENDS:=+luci
endef

define Package/$(PKG_NAME)/description
	LuCI for CPU Freq Setting from Mr.K
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	cp ./root/etc/config/kcpufreq $(1)/etc/config/kcpufreq

	$(INSTALL_DIR) $(1)/etc/init.d
	cp ./root/etc/init.d/kcpufreq $(1)/etc/init.d/kcpufreq

	$(INSTALL_DIR) $(1)/usr
	cp -pR ./root/usr/* $(1)/usr/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/kcpufreq.po $(1)/usr/lib/lua/luci/i18n/kcpufreq.zh-cn.lmo
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
    chmod a+x $${IPKG_INSTROOT}/etc/init.d/kcpufreq >/dev/null 2>&1
    exit 0
endef

define Package/$(PKG_NAME)/postrm
#!/bin/sh
    rm -rf /tmp/luci-modulecache/ >/dev/null 2>&1 || echo ""
    rm -f /tmp/luci-indexcache >/dev/null 2>&1 || echo ""
    exit 0
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

