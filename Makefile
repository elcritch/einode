
all:
	nimble build --verbose -d:debug --nimbleDir:"_nimble"  --nim_cache:"_nimcache"

test:
	nimble test --verbose -d:debug --nimbleDir:"_nimble"  --nim_cache:"_nimcache"

clean:
	rm -Rf _nimcache

distclean: clean
	rm -Rf _nimble 

deps:
	nimble install -y --nimbleDir:"_nimble" nimler
