#!/usr/bin/env python
# coding: utf-8

# In[234]:


import pandas as pd
import datetime
import json

path_file = r'C:\Users\rachid.h.elihimas\Downloads\Asset_2TBDO_Fase_4_Enterprise_Challenge\Dados_GCD_Gestao_Condominio_Portaria.xlsx'

arq = pd.read_excel(path_file)


# In[252]:


arq


# In[251]:


saida = []
entrada = []

for i in range(0, len(arq)):
    tipo = arq['entrada_saida'][i]
    if tipo == 'Saída':
        saida.append(1)
        entrada.append(0)
    elif tipo == 'Entrada':
        saida.append(0)
        entrada.append(1)

arq['Saida'], arq['Entrada'] = saida, entrada


# In[253]:


dia = []
mes = []
ano = []


for i in range(0, len(arq)):

    data = arq['Data_Movimentacao'][i]
    dia.append(datetime.datetime.strftime(data, '%d'))
    mes.append(datetime.datetime.strftime(data, '%m'))
    ano.append(datetime.datetime.strftime(data, '%Y'))

arq['Dia'], arq['Mes'], arq['Ano'] = dia, mes, ano


# In[254]:


arq['weekday'] = arq['Data_Movimentacao'].dt.day_name()


# In[255]:


qquin = []

for day in dia:
    if day < '15':
       qquin.append("Primeira Quinzena")
    else:
        qquin.append("Segunda Quinzena")

arq['Quinzena'] = qquin


# In[256]:


tri = []

for month in mes:
    if month <= '03':
       tri.append("Primeiro Trimestre")
    elif '03' < month <= '06' :
        tri.append("Segundo Trimestre")
    elif '06' < month <= '09' :
        tri.append("Terceiro Trimestre")
    elif '09' < month <= '12' :
        tri.append("Quarto Trimestre")

arq['Trimestre'] = tri


# In[257]:


sem = []

for month in mes:
    if month <= '06':
       sem.append("Primeiro Semestre")
    else:
        sem.append("Segundo Semestre")

arq['Semestre'] = sem


# In[274]:


arq['Tipo'] = arq['entrada_saida']


# In[275]:


arq.head(10)


# In[278]:


b = arq.groupby(by=['nr_condominio','Tipo Veículo','Ano','Semestre', 'Trimestre','Mes','Quinzena', 'weekday','Dia','Tipo'])['entrada_saida'].count()
new_df = b.to_frame(name='entrada_saida').reset_index()

df = pd.DataFrame(new_df)

df.to_excel(r"C:\Users\rachid.h.elihimas\Downloads\output.xlsx")
print("ok")


# In[549]:


df


# In[362]:


tamanho = len(df)

dic_vei = {}
lote = []
veiculos = []
ano = []
semestre = []
trimestre = []
mes = []
quinzena = []
weekday = []
dia = []
tipo = []


for index, row in df.iterrows():
    for coluna in df.columns:
        lote.append(row['nr_condominio'])
        veiculos.append(row["Tipo Veículo"])
        ano.append(row['Ano'])
        semestre.append(row['Semestre'])
        trimestre.append(row['Trimestre'])
        mes.append(row['Mes'])
        quinzena.append(row['Quinzena'])
        weekday.append(row['weekday'])
        dia.append(row['Dia'])
        tipo.append(row['Tipo'])

lotes = list(set(lote))        
veiculos = list(set(veiculos))   
anos = list(set(ano))
semestres = list(set(semestre))
trimestres = list(set(trimestre))
meses = list(set(mes))
quinzenas = list(set(quinzena))
weekdays = list(set(weekday))
dias = list(set(dia))
tipos = list(set(tipo))


# In[551]:


for mes in meses:
    print(str(mes))


# In[565]:


payloads = []

for lote in lotes:
    
    df_base_lote = df[(df['nr_condominio'] == lote)]
    
    for auto in veiculos:
        
        df_base_veiculo = df_base_lote[(df_base_lote['Tipo Veículo'] == auto)]
        
        for ano in anos:
            
            df_base_ano = df_base_veiculo[(df_base_veiculo['Ano'] == ano)]
            
            for semestre in semestres:
                
                df_base_semestre = df_base_ano[(df_base_ano['Semestre'] == semestre)]
                
                for trimestre in trimestres:
                    
                    df_base_trimestre = df_base_semestre[(df_base_semestre['Trimestre'] == trimestre)]
                    
                    for quinzena in quinzenas:
                            
                        df_base_quinzena = df_base_trimestre[(df_base_trimestre['Quinzena'] == quinzena)]
                    
                        for wkday in weekdays:
                        
                            df_base_wkday = df_base_quinzena[(df_base_quinzena['weekday'] == wkday)]
                            
                            r, c = df_base_wkday.shape
                            
                            df_base_wkday.reset_index(inplace = True, drop = True)
                            
                            if r == 1:
                                
                                if df_base_wkday['Tipo'].values == 'Saída':
                                    
                                    valor_saida = df_base_wkday['entrada_saida'].values[0]
                                    valor_entrada = 0
                                    
                                    payload = {"lote": df_base_wkday['nr_condominio'],
                                                        "tipo_veiculo": df_base_wkday['Tipo Veículo'],
                                                        "dadosTemporais": {
                                                            "ano": df_base_wkday['Ano'],
                                                            "semestre": df_base_wkday['Semestre'] ,
                                                            "trimestre": df_base_wkday['Trimestre'],
                                                            "mes": df_base_wkday['Mes'],
                                                            "qinzena": df_base_wkday['Quinzena'],
                                                            "dia_da_semana": df_base_wkday['weekday'],
                                                            "dia": df_base_wkday['Dia']
                                                        },
                                                        "entrada_saida": {
                                                            "entrada": valor_entrada,
                                                            "saida": valor_saida
                                                        }
                                                    }
                                
                                else:
                                    
                                    valor_entrada = df_base_wkday['entrada_saida'].values[0]
                                    valor_saida = 0
                                    
                                    payload = {"lote": df_base_wkday['nr_condominio'].values[0],
                                                "tipo_veiculo": df_base_wkday['Tipo Veículo'].values[0],
                                                "dadosTemporais": {
                                                    "ano": df_base_wkday['Ano'].values[0],
                                                    "semestre": df_base_wkday['Semestre'].values[0] ,
                                                    "trimestre": df_base_wkday['Trimestre'].values[0],
                                                    "mes": df_base_wkday['Mes'].values[0],
                                                    "qinzena": df_base_wkday['Quinzena'].values[0],
                                                    "dia_da_semana": df_base_wkday['weekday'].values[0],
                                                    "dia": df_base_wkday['Dia'].values[0]
                                                },
                                                "entrada_saida": {
                                                    "entrada": valor_entrada,
                                                    "saida": valor_saida
                                                }
                                            }
                                
                            elif r >= 2:
                                
                                df_base_wkday = df_base_wkday.reset_index()
                                
                                for i in range(0, len(df_base_wkday['index'])):
                                    
                                    df_base_wkday_index = df_base_wkday[(df_base_wkday['index'] == i)]
                                    
                                    if df_base_wkday_index['Tipo'].values == 'Saída':
                                    
                                        filtro_tipos = df_base_wkday_index[(df_base_wkday_index['Tipo'] == 'Saída' )]
                                        valor_saida = filtro_tipos['entrada_saida'].values[0]
                                        
                                        df_base_wkday_entrada = df_base_wkday[(df_base_wkday['index'] == i+1)]
                                        
                                        filtro_tipoe = df_base_wkday_entrada[(df_base_wkday_entrada['Tipo'] == 'Entrada')]
                                        try:
                                            valor_entrada = filtro_tipoe['entrada_saida'].values[0]
                                        except:
                                            valor_entrada = 0
                                        
                                        payload = {"lote": df_base_wkday['nr_condominio'].values[0],
                                                "tipo_veiculo": df_base_wkday['Tipo Veículo'].values[0],
                                                "dadosTemporais": {
                                                    "ano": df_base_wkday['Ano'].values[0],
                                                    "semestre": df_base_wkday['Semestre'].values[0] ,
                                                    "trimestre": df_base_wkday['Trimestre'].values[0],
                                                    "mes": df_base_wkday['Mes'].values[0],
                                                    "qinzena": df_base_wkday['Quinzena'].values[0],
                                                    "dia_da_semana": df_base_wkday['weekday'].values[0],
                                                    "dia": df_base_wkday['Dia'].values[0]
                                                },
                                                "entrada_saida": {
                                                    "entrada": valor_entrada,
                                                    "saida": valor_saida
                                                }
                                            }
                    
                                    elif df_base_wkday_index['Tipo'].values == 'Entrada':
                                    
                                        filtro_tipoe = df_base_wkday_index[(df_base_wkday_index['Tipo'] == 'Entrada')]
                                        valor_entrada = filtro_tipoe['entrada_saida'].values[0]
                                        
                                        df_base_wkday_saida = df_base_wkday[(df_base_wkday['index'] == i+1)]
                                        
                                        filtro_tipos = df_base_wkday_saida[(df_base_wkday_saida['Tipo'] == 'Saída')]
                                        try:
                                            valor_saida = filtro_tipos['entrada_saida'].values[0]
                                        except:
                                            valor_saida = 0

                                        payload = {"lote": df_base_wkday['nr_condominio'].values[0],
                                                "tipo_veiculo": df_base_wkday['Tipo Veículo'].values[0],
                                                "dadosTemporais": {
                                                    "ano": df_base_wkday['Ano'].values[0],
                                                    "semestre": df_base_wkday['Semestre'].values[0] ,
                                                    "trimestre": df_base_wkday['Trimestre'].values[0],
                                                    "mes": df_base_wkday['Mes'].values[0],
                                                    "qinzena": df_base_wkday['Quinzena'].values[0],
                                                    "dia_da_semana": df_base_wkday['weekday'].values[0],
                                                    "dia": df_base_wkday['Dia'].values[0]
                                                },
                                                "entrada_saida": {
                                                    "entrada": valor_entrada,
                                                    "saida": valor_saida
                                                }
                                            }

                                        payloads.append(payload)


# In[566]:


payloads


# In[ ]:


payload = 
    {"lote": lote,
        "tipo_veiculo": veiculo,
        "dadosTemporais": {
            "ano":
            "semestre":
            "trimestre":
            "mes":
            "qinzena":
            "dia_da_semana":
            "dia":
        },
        "entrada_saida": {
            "entrada": 
            "saida":
        }
    }



