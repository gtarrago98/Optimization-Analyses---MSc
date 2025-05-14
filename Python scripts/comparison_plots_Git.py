# -*- coding: utf-8 -*-
"""
Created on Wed May 14 14:24:58 2025

@author: gtarr
"""

# Script for generating comparison plots between three prioritization scenarios: random, benefit-cost, and minimum-cost

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import geopandas as gp



# Barplot for diferent optimization scenarios

# Random - unlimited budget / Minimum Cost / Benefit-Cost - 32 parks

from tkinter import Tk
from tkinter.filedialog import askopenfilename
Tk().withdraw()
file_path = askopenfilename(title="Selecione um arquivo", 
                            filetypes=[("arquivo", "*.csv")])

print(file_path)

file = pd.read_csv('dados/comparison/min_cost.csv')

parques = pd.read_excel("dados/parques_São_Paulo_4.0.xlsx")

random = pd.read_excel('dados/comparison/random_mean.xlsx')

print(file.columns)
print(parques.columns)


file["sum_cost"] = file['Costs'].sum()
file["sum_CRP"] = file['cr_prvs'].sum()
file["sum_IP"] = file['wp_prvs'].sum()
file["sum_RCP"] = file['rc_prvs'].sum()


file["prop_custo"] = file['sum_cost'] / parques['Cost_tot']
file["prop_crp"] = file['sum_CRP'] / parques['CRP_Total']
file["prop_ip"] = file['sum_IP'] / parques['WPP_Total']
file["prop_rcp"] = file['sum_RCP'] / parques['RCP_Total']

# For random data

random.info()

random["prop_custo"] = random['Cost'] / parques['Cost_tot']
random["prop_crp"] = random['ClP'] / parques['CRP_Total']
random["prop_inp"] = random['IfP'] / parques['WPP_Total']
random["prop_rcp"] = random['RcP'] / parques['RCP_Total']


print(file.info())

selected_columns = file.iloc[:, 35:39].apply(pd.Series.unique)

combined_series = pd.concat([selected_columns[col] for col in selected_columns], ignore_index=True)

numeric_series = pd.to_numeric(combined_series, errors='coerce')

final_df = pd.DataFrame({"Objetivo" : ["Cost", "Climate Regulation", "Infiltration", "Recreation"],
                      "prop" : numeric_series})


# Barplot

colors = ["#b6b4bb","#3ba477","#016ebb","#7039b4"]

# Whitout error bars

plt.figure(figsize=(15,9), dpi = 800)
plt.gcf().set_facecolor('white') 
sns.set(style="ticks")
ax = sns.barplot(data = final_df, y = 'prop', x ='Objetivo', palette = colors, alpha=1,width=0.65,dodge=False)
ax.set_ylim(0,1)
ax.set_xticklabels(ax.get_xticklabels(), fontsize=24)  
ax.set_yticklabels(ax.get_yticklabels(), fontsize=24)
plt.xlabel('Objectives',fontsize=27, labelpad = 25)
plt.ylabel('Services Provision and Costs (%)',fontsize=27,labelpad = 25)
#plt.legend(title='', title_fontsize=22, fontsize=22, loc='lower right')
#plt.legend([],[], frameon=False)
#plt.show()
plt.savefig('barplot_mincost_100parks.png')

# Whit error bars

plt.figure(figsize=(15,9), dpi = 800)
plt.gcf().set_facecolor('white')  
sns.set(style="ticks")
ax = sns.barplot(data = final_df, y = 'prop', x ='Objetivo', palette = colors, alpha=1,width=0.65,dodge=False,
                 yerr=final_df['sd'],error_kw={
        'ecolor': 'black',  
        'capsize': 10,      
        'capthick': 2,      
        'elinewidth': 3     
    }
)
ax.set_ylim(0,1)
ax.set_xticklabels(ax.get_xticklabels(), fontsize=24)  
ax.set_yticklabels(ax.get_yticklabels(), fontsize=24)
plt.xlabel('Objectives',fontsize=27, labelpad = 25)
plt.ylabel('Services Provision and Costs (%)',fontsize=27,labelpad = 25)
#plt.legend(title='', title_fontsize=22, fontsize=22, loc='lower right')
#plt.legend([],[], frameon=False)
#plt.show()
plt.savefig('barplot_random_1000parks.png')


# Ploting diferences between Benefit cost scenario vs other

scn_100parks = pd.read_excel("dados/diferenca_cenarios_randomcostbc.xlsx")

scn_100parks.info()

total_crp = scn_100parks.iloc[0,6]
total_inp = scn_100parks.iloc[1,6]
total_rcp = scn_100parks.iloc[2,6]
total_cost = scn_100parks.iloc[3,6]


crp_values = scn_100parks.iloc[:,1] * total_crp
inp_values = scn_100parks.iloc[:,2] * total_inp
rcp_values = scn_100parks.iloc[:,3] * total_rcp
cost_values = scn_100parks.iloc[:,4] * total_cost
#parks_n = scn_100parks.iloc[:,5]

# Calculatin diference between BC and others scenarios for each service

# CRl Provision Scenario

CR_crp = round((crp_values[4] - crp_values[0]) / crp_values[0] * 100,0)
CR_inp = round((inp_values[4] - inp_values[0]) / inp_values[0] * 100,0)
CR_rcp = round((rcp_values[4] - rcp_values[0]) / rcp_values[0] * 100,0)
CR_cost = round((cost_values[4] - cost_values[0]) / cost_values[0] * 100,0)
#CR_parks = round((parks_n[4] - parks_n[0]) / parks_n[0] * 100,0)

# Inf Provision Scenario

IF_crp = round((crp_values[4] - crp_values[1]) / crp_values[1] * 100,0)
IF_inp = round((inp_values[4] - inp_values[1]) / inp_values[1] * 100,0)
IF_rcp = round((rcp_values[4] - rcp_values[1]) / rcp_values[1] * 100,0)
IF_cost = round((cost_values[4] - cost_values[1]) / cost_values[1] * 100,0)
#IF_parks = round((parks_n[4] - parks_n[1]) / parks_n[1] * 100,0)

# RC Provision Scenario

RC_crp = round((crp_values[4] - crp_values[2]) / crp_values[2] * 100,0)
RC_inp = round((inp_values[4] - inp_values[2]) / inp_values[2] * 100,0)
RC_rcp = round((rcp_values[4] - rcp_values[2]) / rcp_values[2] * 100,0)
RC_cost = round((cost_values[4] - cost_values[2]) / cost_values[2] * 100,0)
#RC_parks = round((parks_n[4] - parks_n[2]) / parks_n[2] * 100,0)

# Min Cost Scenario

Cost_crp = round((crp_values[4] - crp_values[3]) / crp_values[3] * 100,0)
Cost_inp = round((inp_values[4] - inp_values[3]) / inp_values[3] * 100,0)
Cost_rcp = round((rcp_values[4] - rcp_values[3]) / rcp_values[3] * 100,0)
Cost_cost = round((cost_values[4] - cost_values[3]) / cost_values[3] * 100,0)
#Cost_parks = 0

# Random

random_crp = round((crp_values[4] - crp_values[5]) / crp_values[5] * 100,0)
random_inp = round((inp_values[4] - inp_values[5]) / inp_values[5] * 100,0)
random_rcp = round((rcp_values[4] - rcp_values[5]) / rcp_values[5] * 100,0)
random_cost = round((cost_values[4] - cost_values[5]) / cost_values[5] * 100,0)

# Creating DataFrame with the diferences

scn_diff = pd.DataFrame({'Scenarios':scn_100parks.iloc[[0,1,2,3,5],0],
                         'CR_provision':[CR_crp,IF_crp,RC_crp,Cost_crp,random_crp],
                         'IF_provision':[CR_inp,IF_inp,RC_inp,Cost_inp,random_inp],
                         'RC_provision':[CR_rcp,IF_rcp,RC_rcp,Cost_rcp,random_rcp],
                         'Cost':[CR_cost,IF_cost,RC_cost,Cost_cost,random_cost]})
                         #'N_parks':[CR_parks,IF_parks,RC_parks,Cost_parks]})
# BarPlot

colors = ["#3ba477","#016ebb","#7039b4","#b6b4bb"]

plt.figure(figsize=(16,11), dpi = 800)
plt.gcf().set_facecolor('white')  
sns.set(style="ticks")
ax = sns.barplot(data = scn_diff, y = scn_diff.iloc[4,1:5], x = ['Climate Regulation','Infiltration','Recreation', 'Cost'], palette = colors, alpha=1,width=0.65,dodge=False)
ax.set_xticklabels(ax.get_xticklabels(), fontsize=24)  
ax.set_yticklabels(ax.get_yticklabels(), fontsize=24)
plt.axhline(y=0, color='black', linestyle='--', linewidth=1.5, label='Linha de referência (y = 0)')
plt.xlabel('Objectives',fontsize=27, labelpad = 25)
plt.ylabel('Gain/Lost in Services \n Provision and Costs (%)',fontsize=27,labelpad = 25)
plt.title('Benefit-Cost vs Random \n (100 Parks)', fontsize=30,fontweight='normal', pad=20)
#plt.legend([],[], frameon=False)
#plt.show()
plt.savefig('barplot_difference_bc_random.png')

# Regional AnAlysis 

from tkinter import Tk
from tkinter.filedialog import askopenfilename
Tk().withdraw()
file_path = askopenfilename(title="Selecione um arquivo", 
                            filetypes=[("arquivo", "*.xlsx")])

data =  'dados/Regionalizacao/combined_provision.xlsx'

data =  'dados/Regionalizacao/sp_vs_regions.xlsx'

sp_cb = pd.read_csv('dados/Regionalizacao/SP/CB.csv')


cb_reg = pd.read_excel(data)

sp_all = cb_reg.iloc[[0,5],]

# Separating for zone

sl = sp_cb[sp_cb['ZONA'] == 'S']
nt = sp_cb[sp_cb['ZONA'] == 'N']
lt = sp_cb[sp_cb['ZONA'] == 'L']
ot = sp_cb[sp_cb['ZONA'] == 'W']

# Number of parks and costs by regions in citywide prioritazation

sl.shape[0]
nt.shape[0]
lt.shape[0]
ot.shape[0]

(sl['Costs'].sum() - cb_reg.iloc[4,0]) / cb_reg.iloc[4,0]
(nt['Costs'].sum() - cb_reg.iloc[1,0]) / cb_reg.iloc[1,0]
(lt['Costs'].sum() - cb_reg.iloc[2,0]) / cb_reg.iloc[2,0]
(ot['Costs'].sum() - cb_reg.iloc[3,0]) / cb_reg.iloc[3,0]

# combined provision 

sl_comb = (sl['CRP_norm'] + sl['WPP_norm'] + sl['RCP_norm']).sum()
nt_comb = (nt['CRP_norm'] + nt['WPP_norm'] + nt['RCP_norm']).sum()
lt_comb = (lt['CRP_norm'] + lt['WPP_norm'] + lt['RCP_norm']).sum()
ot_comb = (ot['CRP_norm'] + ot['WPP_norm'] + ot['RCP_norm']).sum()

(ot_comb+sl_comb+nt_comb+lt_comb) / sp_all.iloc[0,7]

# cost-effectivness

sl_ce = ((sl['CRP_norm'] + sl['WPP_norm'] + sl['RCP_norm']) / sl['Cost_nor_1']).sum()
nt_ce = ((nt['CRP_norm'] + nt['WPP_norm'] + nt['RCP_norm']) / nt['Cost_nor_1']).sum()
lt_ce = ((lt['CRP_norm'] + lt['WPP_norm'] + lt['RCP_norm']) / lt['Cost_nor_1']).sum()
ot_ce = ((ot['CRP_norm'] + ot['WPP_norm'] + ot['RCP_norm']) / ot['Cost_nor_1']).sum()

(sl_ce+nt_ce+lt_ce+ot_ce) / sp_all.iloc[0,8]

total_ce =  ((parques['CRP_norm'] + parques['WPP_norm'] + parques['RCP_norm']) / parques['Cost_nor_1']).sum()

sl_ce/=total_ce
nt_ce/=total_ce
lt_ce/=total_ce
ot_ce/=total_ce


# CR Provision

sl_cr = sl['CRP_norm'].sum()
nt_cr = nt['CRP_norm'].sum()
lt_cr = lt['CRP_norm'].sum()
ot_cr = ot['CRP_norm'].sum()

# IF Provision 

sl_if = sl['WPP_norm'].sum()
nt_if = nt['WPP_norm'].sum()
lt_if = lt['WPP_norm'].sum()
ot_if = ot['WPP_norm'].sum()

# RC Provision

sl_rc = sl['RCP_norm'].sum()
nt_rc = nt['RCP_norm'].sum()
lt_rc = lt['RCP_norm'].sum()
ot_rc = ot['RCP_norm'].sum()

(sl_cr+sl_if+sl_rc+nt_cr+nt_if+nt_rc+lt_cr+lt_if+lt_rc+ot_cr+ot_if+ot_rc) / cb_reg.iloc[0,7]

# Services provsion in the regionalize BC optimazation scenario

cb_reg.info()

sl_cr_reg = cb_reg.iloc[4,4] / (parques['cr_prvs'].sum())
nt_cr_reg = cb_reg.iloc[1,4] / (parques['cr_prvs'].sum())
lt_cr_reg = cb_reg.iloc[2,4] / (parques['cr_prvs'].sum())
ot_cr_reg = cb_reg.iloc[3,4] / (parques['cr_prvs'].sum())


sl_if_reg = cb_reg.iloc[4,5] / (parques['wp_prvs'].sum())
nt_if_reg = cb_reg.iloc[1,5] / (parques['wp_prvs'].sum())
lt_if_reg = cb_reg.iloc[2,5] / (parques['wp_prvs'].sum())
ot_if_reg = cb_reg.iloc[3,5] / (parques['wp_prvs'].sum())

sl_rc_reg = cb_reg.iloc[4,6] / (parques['rc_prvs'].sum())
nt_rc_reg = cb_reg.iloc[1,6] / (parques['rc_prvs'].sum())
lt_rc_reg = cb_reg.iloc[2,6] / (parques['rc_prvs'].sum())
ot_rc_reg = cb_reg.iloc[3,6] / (parques['rc_prvs'].sum())

# Final dataframe

comb_regions = pd.DataFrame({'Range':['SP','Regions'],
                             'South':[sl_comb,cb_reg.iloc[4,7]],
                             'North':[nt_comb,cb_reg.iloc[1,7]],
                             'East':[lt_comb,cb_reg.iloc[2,7]],
                             'West':[ot_comb,cb_reg.iloc[3,7]]})

(comb_regions.iloc[1,[1,2,3,4]].sum()) / cb_reg.iloc[5,7]
(comb_regions.iloc[0,[1,2,3,4]].sum()) / cb_reg.iloc[0,7]

ce_regions = pd.DataFrame({'Range':['SP','Regions'],
                           'South':[sl_ce,cb_reg.iloc[4,13]],
                           'North':[nt_ce,cb_reg.iloc[1,13]],
                           'East':[lt_ce,cb_reg.iloc[2,13]],
                           'West':[ot_ce,cb_reg.iloc[3,13]]})

(ce_regions.iloc[1,[1,2,3,4]].sum()) / cb_reg.iloc[5,13]
(ce_regions.iloc[0,[1,2,3,4]].sum()) / cb_reg.iloc[0,13]

# Final dataframe (services individualy)

cr_regions = pd.DataFrame({'Range':['SP','Regions'],
                           'South':[sl_cr,sl_cr_reg],
                           'North':[nt_cr,nt_cr_reg],
                           'East':[lt_cr,lt_cr_reg],
                           'West':[ot_cr,ot_cr_reg]})

if_regions = pd.DataFrame({'Range':['SP','Regions'],
                           'South':[sl_if,sl_if_reg],
                           'North':[nt_if,nt_if_reg],
                           'East':[lt_if,lt_if_reg],
                           'West':[ot_if,ot_if_reg]})

rc_regions = pd.DataFrame({'Range':['SP','Regions'],
                           'South':[sl_rc,sl_rc_reg],
                           'North':[nt_rc,nt_rc_reg],
                           'East':[lt_rc,lt_rc_reg],
                           'West':[ot_rc,ot_rc_reg]})



# Ploting bars with regions by colors

# Extract data
barras =rc_regions['Range']
regioes = rc_regions.columns[1:]  # Regions name
contribuicoes = rc_regions.iloc[:, 1:].values.T  # Values

# Color for each region

colors = ["#3ba477","#016ebb","#7039b4","#b6b4bb"]

# Create the stacked bar chart
fig, ax = plt.subplots(figsize=(16,10),dpi = 800)

# Initialize the position of the bars
posicao_barras = range(len(barras))

# Plot each region as a portion of the bar
bottom = None  # Initialize the bar's "background" to None
for i, regiao in enumerate(regioes):
    ax.bar(posicao_barras, contribuicoes[i], bottom=bottom, label=regiao,width = 0.45, color=colors[i])
    if bottom is None:
        bottom = contribuicoes[i]
    else:
        bottom += contribuicoes[i]

# Customize the chart
ax.set_xticks(posicao_barras)
ax.set_yticklabels(ax.get_yticklabels(),fontsize=24)
ax.set_xticklabels(barras, fontsize=24)
ax.set_ylabel('Recreation Provision (%)', fontsize=24, labelpad = 25)
#ax.set_ylim(0,1)
#ax.set_title('Contribuição das Regiões por Barra', fontsize=14)
ax.legend(title='', bbox_to_anchor=(1.02, 1), loc='upper left', fontsize=18)
plt.savefig('rc_sp_regions.png', bbox_inches='tight')

ganho_comb = round(((cb_reg.iloc[0,7] - cb_reg.iloc[5,7]) / cb_reg.iloc[5,7]) * 100,0)
ganho_ce = round(((cb_reg.iloc[0,8] - cb_reg.iloc[5,8]) / cb_reg.iloc[5,8]) * 100,0)

print(f'Há ganha de',ganho_comb,'% na provisão combinada')
print(f'Há ganha de',ganho_ce,'% no custo-efetividade')

# Ploting other bars

colors = ["#21a254","#12a8e7","#7c2483","#42368d","#e84158"]

colors = ["#1e9a6f","#bebebe","#ffb500","#5271FF","#e64949"]
  

plt.figure(figsize=(16,11), dpi = 800)
plt.gcf().set_facecolor('white')  
sns.set(style="ticks")
ax = sns.barplot(data = cb_reg, y = 'prop_cb', x = 'Region', palette = colors, alpha=1,width=0.65,dodge=False)
ax.set_xticklabels(ax.get_xticklabels(), fontsize=24)  
ax.set_yticklabels(ax.get_yticklabels(), fontsize=24)
#plt.axhline(y=0, color='black', linestyle='--', linewidth=1.5, label='Linha de referência (y = 0)')
plt.xlabel('',fontsize=27, labelpad = 25)
plt.ylabel("Benefit-Cost Index (%)",fontsize=27,labelpad = 25)
plt.title("Benefit-Cost Optimization Scenario - US$ 140 million", fontsize=30,fontweight='normal', pad=20)
#plt.legend([],[], frameon=False)
#plt.show()
plt.savefig('benefit_cost_region.png')

# Calculating diference

# Combined provision

norte = round((cb_reg.iloc[0,0]- cb_reg.iloc[1,0])/cb_reg.iloc[1,0]  * 100,0)
leste = round((cb_reg.iloc[0,0]- cb_reg.iloc[2,0])/cb_reg.iloc[2,0]  * 100,0)
sul = round((cb_reg.iloc[0,0]- cb_reg.iloc[3,0])/cb_reg.iloc[3,0] * 100,0)
oeste = round((cb_reg.iloc[0,0]- cb_reg.iloc[4,0])/cb_reg.iloc[4,0]  * 100,0)

diff_reg = pd.DataFrame({'diff':[norte,leste,sul,oeste],
                        'regions':["North","East","South","West"]})

colors = ["#bebebe","#ffb500","#5271FF","#e64949"]

plt.figure(figsize=(16,11), dpi = 800)
plt.gcf().set_facecolor('white')  
sns.set(style="ticks")
ax = sns.barplot(data = diff_reg, y = 'diff', x = 'regions', palette = colors, alpha=1,width=0.65,dodge=False)
ax.set_xticklabels(ax.get_xticklabels(), fontsize=24)  
ax.set_yticklabels(ax.get_yticklabels(), fontsize=24)
plt.axhline(y=0, color='black', linestyle='--', linewidth=1.5, label='Linha de referência (y = 0)')
plt.xlabel('',fontsize=27, labelpad = 25)
plt.ylabel('Gain/Lost in Services Provision by Region (%)',fontsize=27,labelpad = 25)
plt.title("Benefit-Cost Optimization Scenario - US$ 140 million", fontsize=30,fontweight='normal', pad=20)
#plt.legend([],[], frameon=False)
#plt.show()
plt.savefig('difference_services_combined.png')