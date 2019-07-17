tar:
	( cd .. ; tar --exclude=CVS -czf perlutils.tar.gz perlutils)
	mv ../perlutils.tar.gz ~/public_html/code/

bin:
	echo "creating bin dir with symlinks"
	mkdir -p bin
	ln -sf ../simple.pl bin/date
	ln -sf ../simple.pl bin/perlsh
	ln -sf ../fs.pl bin/ls
	for x in cat tac rev sort uniq head ; do \
	  ln -sf ../simplepipe.pl bin/$$x ; done
