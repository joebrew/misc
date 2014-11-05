# -*- coding: utf-8 -*-
"""
Created on Wed Nov 05 17:23:03 2014

@author: BrewJR
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#%% # create series by passing list of values, pandas creates integer index
s = pd.Series([1,3,5,np.nan,6,8])
s

# %% create dataframe by passing a numpy array, with datetime index and
# labeled columns
dates = pd.date_range('20130101', periods = 6)
dates
df = pd.DataFrame(np.random.randn(6,4), 
                  index = dates,
                  columns = list('ABCD'))                
df

# %% Create dataframe by passing dict of bojects that can be converted to 
# series-like
df2 = pd.DataFrame({ 'A' : 1.,
                     'B' : pd.Timestamp('20130102'),
                     'C' : pd.Series(1, index = list(range(4)), dtype = 'float32'),
                     'D' : np.array([3] * 4, dtype='int32'),
                     'E' : 'foo' })
df2

#%% spepcifc dtypes
df2.dtypes

#%% VIEWING DATA
df.head()
df.tail(2)

#%% display index, columns, underlying numpy data
df.index
df.columns
df.values

#%% describe shows quick summary statistics
df.describe()

#%% transpose data
df.T

#%% sorting by an axis
df.sort_index(axis =1, ascending = False)

#%% sorting by values
df.sort(columns = 'B')

#%% GETTING

# select singlue column, yielding series, equivalent to df.A
df['A']

# select via [], which slices rows
df[0:3]
df['20130102':'20130104']

#%% selection by label using .loc
df.loc[dates[0]]

#%% selecting on a multi-axis by label
df.loc[:,['A', 'B']]

#%% show label slicing, both endpoints included
df.loc['20130102':'20130104', ['A','B']]

#%% reduction in dimensions of returned object
df.loc['20130102',['A','B']]

#%% for getting a scalar value
df.loc[dates[0], 'A']

#%% selecting by position using .iloc
df.iloc[3]
df.iloc[3:5,0:2]

#%% by lists of integer positions
df.iloc[[1,2,4],[0,2]]

#%% for slicing rows explicitly
df.iloc[1:3,:]

#%% for slicing columns explictly
df.iloc[:,1:3]

#%% for getting a vlue explicitly
df.iloc[1,1]

#%% BOOLEAN INDEXING
df[df.A > 0]

#%% where operation
df[df > 0]

#%% isin() method for filtering
df2 = df.copy()
df2['E'] = ['one', 'one', 'two', 'three', 'four', 'three']
df2

df2[df2['E'].isin(['two','four'])]

#%% SETTING
# setting a new column automatically aligns data by indexes
s1 = pd.Series([1,2,3,4,5,6], index=pd.date_range('20130102', periods=6))
s1

#%% setting values by label
df.at[dates[0], 'A'] = 0

#%% setting values by position
df.iat[0,1] = 0

#%% setting by assigning with numpy array
df.loc[:,'D'] = np.array([5] * len(df))
df

#%% a where operation with setting
df2 = df.copy()
df2[df2 > 0] = -df2
df2

#%% MISSING DATA
# reindexing
df1 = df.reindex(index=dates[0:4], columns=list(df.columns) + ['E'])
df1.loc[dates[0]:dates[1],'E'] = 1
df1

#%% drop any rows that have missing data
df1.dropna(how='any')

#%% filling missing data
df1.fillna(value=5)

#%% to get boolean mask where values are nan
pd.isnull(df1)

#%% OPERATIONS
df.mean()
# on other axis:
df.mean(1)

# different dimensions that need alignment
s = pd.Series([1,3,5,np.nan,6,8],index=dates).shift(2)
s
df.sub(s,axis='index')

#%% APPLY
df.apply(np.cumsum)
df.apply(lambda x: x.max() - x.min())

#%% HISTOGRAMMING
s = pd.Series(np.random.randint(0,7,size=10))
s
s.value_counts()

#%% STRING METHODS
s = pd.Series(['A', 'B', 'C', 'Aaba', 'Baca', np.nan, 'CABA', 'dog', 'cat'])
s.str.lower()

#%% MERGE
df = pd.DataFrame(np.random.randn(10,4))
df

#%% break it into pieces
pieces = [df[:3], df[3:7], df[7:]]
pd.concat(pieces)

#%% JOIN
left = pd.DataFrame({'key': ['foo', 'foo'], 'lval': [1, 2]})
right =  pd.DataFrame({'key': ['foo', 'foo'], 'rval': [4, 5]})
pd.merge(left, right, on='key')

#%% APPEND ROWS TO DATAFRAME
df = pd.DataFrame(np.random.randn(8, 4), columns=['A','B','C','D'])
s = df.iloc[3]
df.append(s, ignore_index=True)

#%% GROUPING
df = pd.DataFrame({'A' : ['foo', 'bar', 'foo', 'bar',
   ....:                          'foo', 'bar', 'foo', 'foo'],
   ....:                    'B' : ['one', 'one', 'two', 'three',
   ....:                          'two', 'two', 'one', 'three'],
   ....:                    'C' : np.random.randn(8),
   ....:                    'D' : np.random.randn(8)})
df

# group and then apply sum to resulting groups
df.groupby('A').sum()

# Grouping by multiple columns forms hierarchical index, before applying fun
df.groupby(['A', 'B']).sum()

#%% RESHAPING
 tuples = list(zip(*[['bar', 'bar', 'baz', 'baz',
                         'foo', 'foo', 'qux', 'qux'],
                        ['one', 'two', 'one', 'two',
                         'one', 'two', 'one', 'two']])) 
                         
index = pd.MultiIndex.from_tuples(tuples, names=['first', 'second'])

#%%
x = pd.DataFrame(transactions)
#%%
x['amount']