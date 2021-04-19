    pd_repoinfor = pd.read_excel(r'F:\download\工作簿2.xlsx',keep_default_na=False)
    data=[]
    for i in ['1岗', '2岗' ,'3岗','总部正职', '总部副职', '总部科员、财务', '基层正职' ,'基层副职（安全总监等）','基层科长、财务科长', '10岗项目经理', '11岗' ,'12岗',  '13岗',
 '14岗行政管理员（及物业公司人员）','财务' ,'海外','工人岗','见习岗']:
        data.append(go.Box(y=pd_repoinfor.loc[pd_repoinfor["岗位类别"]==i, '2021年月平均工资'],name=i)  )
    fig = go.Figure(data=data,layout={"title": "箱线图", "yaxis": {"dtick": 5000}})
    fig.show()
