#!/usr/bin/python

import pandas as pd
import sys
import os
if len(sys.argv) != 3:
    print("Usage: %s <excel file path> <destination folder>"%(sys.argv[0]))
    sys.exit(2)

xls = pd.ExcelFile(sys.argv[1])
filename = os.path.splitext(os.path.basename(sys.argv[1]))[0]

if len(xls.sheet_names) == 1:
    df = xls.parse(header=None)
    dest_file = "%s/%s.csv"%(sys.argv[2],filename)
    df.to_csv(dest_file,encoding='utf-8',header=False,index=False)
    print("Wrote CSV File: %s"%(dest_file))
else:
    for sheet in xls.sheet_names:
        df = pd.read_excel(xls,sheet,header=None)
        dest_file = "%s/%s.%s.csv"%(sys.argv[2],filename,sheet)
        df.to_csv(dest_file,encoding='utf-8',header=False,index=False)
        print("Wrote CSV File: %s"%(dest_file))
