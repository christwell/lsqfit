# Created by G. Peter Lepage (Cornell University) on 2008-02-12.
# Copyright (c) 2008-2015 G. Peter Lepage.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version (see <http://www.gnu.org/licenses/>).
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

PIP = python -m pip
PYTHON = python
PYTHONVERSION = python`python -c 'import platform; print(platform.python_version())'`
VERSION = `python -c 'import lsqfit; print lsqfit.__version__'`

install :
	$(PIP) install . --user

install-sys :
	$(PIP) install .

# $(PYTHON) setup.py install --record files-lsqfit.$(PYTHONVERSION)

uninstall :			# mostly works (may leave some empty directories)
	- $(PIP) uninstall lsqfit

try:
	$(PYTHON) setup.py install --user --record files-lsqfit.$(PYTHONVERSION)

untry:
	- cat files-lsqfit.$(PYTHONVERSION) | xargs rm -rf

doc-html:
	rm -rf doc/html; sphinx-build -b html doc/source doc/html

doc-pdf:
	rm -rf doc/lsqfit.pdf
	sphinx-build -b latex doc/source doc/latex
	cd doc/latex; make lsqfit.pdf; mv lsqfit.pdf ..

doc-zip doc.zip:
	cd doc/html; zip -r doc *; mv doc.zip ../..

doc-all: doc-html doc-pdf doc-zip

sdist:			# source distribution
	$(PYTHON) setup.py sdist

.PHONY: tests

tests test-all:
	@echo 'N.B. Some tests involve random numbers and so fail occasionally'
	@echo '     (less than 1 in 100 times) due to multi-sigma fluctuations.'
	@echo '     Run again if any test fails.'
	@echo ''
	$(PYTHON) -m unittest discover

time:
	$(MAKE) -C examples PYTHON=$(PYTHON) time

run run-examples:
	$(MAKE) -C examples PYTHON=$(PYTHON) run

register-pypi:
	python setup.py register # use only once, first time

upload-pypi:
	python setup.py sdist upload

upload-git:
	echo  "version $(VERSION)"
	make doc-all
	git commit -a -m "prep documentation for upload"
	git push origin master

tag-git:
	echo  "version $(VERSION)"
	git tag -a v$(VERSION) -m "version $(VERSION)"
	git push origin v$(VERSION)

test-download:
	-$(PIP) uninstall lsqfit
	$(PIP) install lsqfit --no-cache-dir

clean:
	rm -f -r build
	rm -rf __pycache__
	rm -f *.so *.tmp *.pyc *.prof *.c .coverage doc.zip
	rm -f -r dist
	rm -f src/lsqfit/_utilities.c src/lsqfit/_extras.c
	$(MAKE) -C doc/source clean
	$(MAKE) -C tests clean
	$(MAKE) -C examples clean


