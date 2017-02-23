#include "stdafx.h"
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;

class Parser {
public:
	Parser(char* path) {
		_path = path;
	}
	~Parser() {};
	void parse_ini(char* eqSymbol, char* endSymbol) {
		string line;
		ifstream myfile(_path);
		if (myfile.is_open())
		{
			while (getline(myfile, line))
			{
				size_t found1 = line.find(eqSymbol);
				size_t found2 = line.find(endSymbol);
				_rawString.push_back(line);
				if (found1 != std::string::npos && found2 != std::string::npos) {

					_tagString.push_back(line.substr(0, found1));
					_valString.push_back(line.substr(found1 + 1, found2 - found1 - 1));
				}
			}
			myfile.close();
		}

		else cout << "Unable to open file";

	}
	int getTagIndex(string input) {
		for (int i = 0; i < _tagString.size(); i++) {
			if (input.compare(_tagString[i]) == 0)
				return i;
		}
		return -1;
	}
	string readTagValue(string input) {
		return _valString.at(getTagIndex(input));
	}
	vector<string> getRawString() {
		return _rawString;
	}
	vector<string> getTagString() {
		return _tagString;
	}
	vector<string> getValString() {
		return _valString;
	}

private:
	char* _path;
	vector<string> _rawString;
	vector<string> _tagString;
	vector<string> _valString;
};
