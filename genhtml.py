#!/usr/bin/python
import sys, os, time

from django.conf import settings
from django import setup
from django.template import Template, Context
from django.template.loader import render_to_string

def main():
	#runscript("bitcoin")
	#runscript("bitcoincash")
	#runscript("dash")
	runscript("ethereum")
	#runscript("monero")
	#runscript("litecoin")
	#runscript("qtum")
	#runscript("zcash")
 	
	TEMPLATES = [
		{
			'BACKEND': 'django.template.backends.django.DjangoTemplates',
			'DIRS': ['.'],
		}
	]
	settings.configure(TEMPLATES=TEMPLATES)
	setup()
	options = {
		"date": time.strftime('%m/%d/%Y'),
		"cryptos": []
	}

	#options["cryptos"].append(generate("bitcoin"))
	#options["cryptos"].append(generate("bitcoincash"))
	#options["cryptos"].append(generate("dash"))
	options["cryptos"].append(generate("ethereum"))
	#options["cryptos"].append(generate("monero"))
	#options["cryptos"].append(generate("litecoin"))
	#options["cryptos"].append(generate("qtum"))
	#options["cryptos"].append(generate("zcash"))

	content = render_to_string('report_template.html', options)
	report = open("report.html", "w+")
	report.write(content)
	report.close()

def runscript(dirname):
	print("Running " + dirname.title() + " Scripts")
	os.chdir(dirname)
	os.system("./" + dirname + ".sh")
	os.chdir("..")

def generate(dirname):
	g = open("report.html", "a")
	f = open(dirname + "/" + dirname + "lizard.txt", "r")
	nums = f.readline()
	numarr = nums.split()
	f.close()
	f = open(dirname + "/" + dirname + "lizarduncomp.txt", "r")
	uncomp = f.readline()
	uncomparr = uncomp.split()
	f.close()

	errors = []
	warnings = []

	f = open(dirname + "/" + dirname + "cppcheck.txt", "r")
	errlines = f.readlines()

	for i in errlines:
		if ": (error) " in str(i):
			errors.append(str(i).strip())
		else:
			warnings.append(str(i).strip())

	f.close()

	f = open(dirname + "/" + dirname + "url.txt", "r")
	url = f.readline()
	f.close()

	f = open(dirname + "/" + dirname + "time.txt", "r")
	timing = int(f.readline())
	hour = timing/3600
	minute = (timing%3600)/60
	second = (timing%3600)%60
	f.close()

	content = {
		"name": dirname,
		"display_name": dirname.title(),
		"url": url.strip(),
		"lines_of_code": uncomparr[0],
		"uncompiled_cyclomatic_complexity": uncomparr[1],
		"compiled_cyclomatic_complexity": numarr[1],
		"runtime": "%02d:%02d:%02d" % (hour, minute, second),
		"num_errors": str(len(errors)),
		"num_warnings": str(len(warnings)),
		"errors": errors,
		"warnings": warnings
	}
	return content

main()
