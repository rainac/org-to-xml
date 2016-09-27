
check:
	./tests/test_parse.sh
	./tests/test_parse_unparse.sh
	./tests/test_includes.sh
	./tests/test_relevel.sh

clean:
	rm -f res.org res.xml ./tests/test_parse_unparse_all.sh

distclean:
	git clean -f -d
