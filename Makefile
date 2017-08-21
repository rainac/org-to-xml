
check: $(patsubst %.sh,%.testres,$(wildcard ./tests/test_*.sh))

%.testres: %.sh
	./$<

clean:
	rm -f res.org res.xml ./tests/test_parse_unparse_all.sh

distclean:
	git clean -f -d
