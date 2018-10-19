#!/usr/bin/python
import sys, os, time

def main():

	runscript("bitcoin")
	runscript("dash")
	runscript("bitcoincash")
	runscript("ethereum")
	runscript("monero")
	runscript("litecoin")
	
	header()
	generate("bitcoin")
	generate("dash")
	generate("bitcoincash")
	generate("ethereum")
	generate("monero")
	generate("litecoin")
	footer()
	
	
def runscript(dirname):
	print("Running " + dirname.title() + " Scripts")
	os.chdir(dirname)
	os.system("./" + dirname + ".sh")
	os.chdir("..")
	
def header():
	g = open("report.html", "w+")
	g.write("<html>\n<head>\n")
	g.write("\t<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">\n")
	g.write("</head>\n<body>\n")
	g.close()
	
def footer():
	g = open("report.html", "a")
	g.write("<br><br><br>Interested in reading a near-future techno-thriller in a world where cryptocurrency has eliminated traditional money?<br>Check out <a href=\"https://smile.amazon.com/Strength-Numbers-Cryptocurrency-Bill-Laboon-ebook/dp/B07B75SL2C/\">Strength in Numbers:A Novel of Cryptocurrency by Bill Laboon</a>")
	g.write("<br><p>Last Updated: " + time.strftime("%x") + "</p>\n")
	g.write("<script>\nvar acc = document.getElementsByClassName(\"accordion\");\nvar i;\nfor (i = 0; i < acc.length; i++) {\n\tacc[i].addEventListener(\"click\", function() {\n\t\tthis.classList.toggle(\"active\");\n\t\tvar panel = this.nextElementSibling;\n\t\tif (panel.style.display === \"block\") {\n\t\t\tpanel.style.display = \"none\";\n\t\t} else {\n\t\t\tpanel.style.display = \"block\";\n\t\t}\n\t});\n}\n</script>\n")
	g.write("</body>\n</html>\n")
	g.close()

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
			errors.append(str(i))
		else:
			warnings.append(str(i))
		
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

	
	
	g.write("\n\n\t\t<h1>" + dirname.title() + " <img src=\"img/" + dirname + ".png\" height=30 width=30> </h1>\n")
	g.write("\n\n\t\t<a href=\"" + url + "\">" + dirname.title() + " Repository</a>")
	g.write("\t\t<p>Number of Lines of Code: " + uncomparr[0] + "</p>\n")
	g.write("\t\t<p>Average Cyclomatic Complexity (Uncompiled): " + uncomparr[1] + "</p>\n")
	g.write("\t\t<p>Average Cyclomatic Complexity (Compiled): " + numarr[1] + "</p>\n")
	g.write("\t\t<a href=\"" + dirname + "/lcov/index.html\">Code Coverage Report</a>\n")

	g.write("\t\t<p>Time to Run Analysis: ")
	if hour < 10:
		g.write("0"+str(hour) + ":")
	else:
		g.write(str(hour) + ":")
		
	if minute < 10:
		g.write("0" + str(minute) + ":")
	else:
		g.write(str(minute) + ":")
		
	if second < 10:
		g.write("0" + str(second) + "</p>\n")
	else:
		g.write(str(second) + "</p>\n")
		
		
	g.write("\t\t<p>Number of Errors in Code: " + str(len(errors)) + "</p>\n")
	g.write("\t\t<p>Number of Warnings in Code: " + str(len(warnings)) + "</p>\n")
	if(len(errors) > 0):
		g.write("\t\t\t<button class=\"accordion\">Show Errors</button>\n")
		g.write("\t\t\t<div class=\"panel\">\n")
		
		for i in errors:
			g.write("\t\t\t\t<p>" + str(i))
		
		g.write("\t\t\t</div>\n\n")
	if(len(warnings) > 0):
		g.write("\t\t\t<button class=\"accordion\">Show Warnings</button>\n")
		g.write("\t\t\t<div class=\"panel\">\n")
		
		for i in warnings:
			g.write("\t\t\t\t<p>" + str(i))
		
		g.write("\t\t\t</div>\n\n")
	g.close()
	
main()
