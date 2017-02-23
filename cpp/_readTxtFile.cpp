// _readTxtFile.cpp : Defines the entry point for the console application.
//
#include "stdafx.h"
#include "parser.h"
using namespace std;

int main() {
	Parser txt("test.txt");
	txt.parse_ini("=", ";");

	int index1 = txt.getTagIndex("aa");
	int index2 = txt.getTagIndex("b");
	int index3 = txt.getTagIndex("c");

	int aa = stoi(txt.getValString().at(index1));
	int aaa = stoi(txt.readTagValue("aa"));

/*	string line;
	ifstream myfile("test.txt");
	vector<string> rawLine, tagLine, valueLine;
	if (myfile.is_open())
	{
		while (getline(myfile, line))
		{
			size_t found1 = line.find("=");
			size_t found2 = line.find(";");
			rawLine.push_back(line);
			if (found1 != std::string::npos && found2 != std::string::npos) {

				tagLine.push_back(line.substr(0, found1 - 1));
				valueLine.push_back(line.substr(found1 + 1, found2 - found1 - 1));
//				cout << line.substr(found, line.length() - found - 1);
			}
//			cout << line << '\n';
		}
		myfile.close();
	}

	else cout << "Unable to open file";
	*/
	return 0;
}
