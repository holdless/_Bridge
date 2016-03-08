// parseCSV.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iterator>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <windows.h>

#include "opencv2/core/core.hpp"
//#include "opencv2/contrib/contrib.hpp"
//#include "opencv2/highgui/highgui.hpp"

using namespace std;
using namespace cv;

class CSVRow
{
    public:
        string const& operator[](size_t index) const
        {
            return m_data[index];
        }
        size_t size() const
        {
            return m_data.size();
        }
        void readNextRow(istream& str)
        {
            string         line;
            getline(str,line);

            stringstream   lineStream(line);
            string         cell;

            m_data.clear();
            while(getline(lineStream,cell,','))
            {
                m_data.push_back(cell);
            }
        }
    private:
        vector<string>    m_data;
};

istream& operator>>(istream& str,CSVRow& data)
{
    data.readNextRow(str);
    return str;
}   



int _tmain(int argc, _TCHAR* argv[])
{
	ifstream file("D:/Users/changyht/Documents/Visual Studio 2010/Projects/parseCSV/test.csv");
    CSVRow row;
	size_t a;
	int k = 0;
	Mat m(3, 4, CV_32F);
    while(file >> row)
    {
		a = row.size();
		for (int i = 0; i < a; i++)
			m.at<float>(k, i) = atof(row[i].c_str());
		k++;
//        cout << "4th Element(" << row[3] << ")\n";
    }

	return 0;
}

