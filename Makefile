NOW := $(shell date "+%Y%m%d%H%M%S")
VERSION = 1-0
HASH = $(shell git log --pretty=format:'%h' -n 1)
'PLAYER_IP = 192.168.70.100
'BRAIN_IP = 192.168.1.164

PLAYER_IP = 192.168.70.100
BRAIN_IP = 192.168.70.209
PLUGIN = dinerware_plugin.brs

clean:
	@-rm *__* 2>/dev/null || true
	@-rm *~   2>/dev/null || true

git_commit: clean
	@-git add *
	@-git commit -am"incremental commit"

hashed_release: git_commit
	cp $(PLUGIN) $(PLUGIN)_$(VERSION)__$(HASH)__$(NOW).brs

versioned_release: git_commit
	cp $(PLUGIN) $(PLUGIN)_$(VERSION)__$(NOW).brs

plugin_install: git_commit
	curl "$(PLAYER_IP)/delete?filename=sd%2f/$(PLUGIN)&delete=Delete"
	curl -i -F filedata=@$(PLUGIN) http://$(PLAYER_IP)/upload.html?rp=sd
	curl "$(PLAYER_IP)/action.html?reboot=Reboot"

player_reboot:
	curl "$(PLAYER_IP)/action.html?reboot=Reboot"

wsdl:
	 curl $(BRAIN_IP):84/VirtualClient?wsdl | xmllint --pretty 2 - > wsdl.xml

menu:
	rm menu.xml
	curl -H 'SOAPACTION: "http://tempuri.org/IVirtualClient/GetAllMenuItems"' -X POST -H 'Content-type: text/xml'   -d @all.xml $(BRAIN_IP):84/VirtualClient > menu.xml
	cat menu.xml


getmenu:
	netstring $(PLAYER_IP) 21000 'dinerware!getmenu'