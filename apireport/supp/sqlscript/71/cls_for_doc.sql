with bcls as 
(select clv.mlt_id,
       clv.clf_id,
       clv.cls_id,
       clv.clv_clf_id,
       clv.clv_cls_id,
       clv.name,
       clv.code,
       clv.cfv_id,
       prj.prj_id,
       prj.name project_name,
       connect_by_isleaf isleaf,
       level clv_lev
from clv, cfv, prj
where clv.cfv_id = cfv.cfv_id
  and prj.prj_id = cfv.prj_id
  and clv.status <> 2
start with clv.mlt_id = :mlt_id
  and clv.clf_id in (:clf_id, :inclf_id)
  and clv.cls_id = :cls_id
  and clv.cfv_id = :cfv_id
connect by prior clv.mlt_id = clv.mlt_id
  and prior clv.cfv_id = clv.cfv_id 
  and prior clv.clf_id = clv.clv_clf_id
  and prior clv.cls_id = clV.clv_cls_id)
  select bcls.mlt_id,
       bcls.clf_id,
       bcls.cls_id,
       bcls.clv_clf_id,
       bcls.clv_cls_id,
       bcls.name,
       bcls.code,
       bcls.cfv_id,
       bcls.prj_id,
       bcls.project_name,
       bcls.isleaf,
       bcls.clv_lev,
       CASE WHEN nmpp.name LIKE '%разделитель%' THEN gen_shbl_cls_pp2 (45,bcls.MLT_ID,bcls.CLF_ID,bcls.CLS_ID,SUBSTR(nmpp.name,1,INSTR(nmpp.name,'=разделитель=',1)-1),1)
            ELSE gen_shbl_cls_pp2 (45,bcls.MLT_ID,bcls.CLF_ID,bcls.CLS_ID,nmpp.name,1) END sname_uni,
       CASE WHEN nmpp.name LIKE '%разделитель%' THEN gen_shbl_cls_pp2 (45,bcls.MLT_ID,bcls.CLF_ID,bcls.CLS_ID,SUBSTR(nmpp.name,INSTR(nmpp.name,'=разделитель=',1)+13),1)
            ELSE gen_shbl_cls_pp2 (45,bcls.MLT_ID,bcls.CLF_ID,bcls.CLS_ID,nmpp.name,1) END fname_uni,
       gen_shbl_cls_pp2 (45,bcls.MLT_ID,bcls.CLF_ID,bcls.CLS_ID,nmpp.name,1) name_sh,                       
       gen_shbl_cls_pp2(45, bcls.mlt_id, bcls.clf_id, bcls.cls_id, nmpp.sname, 1) sname,
       gen_shbl_cls_pp2(45, bcls.mlt_id, bcls.clf_id, bcls.cls_id, nmpp.fname, 1) fname,
       case when isleaf = 1 then  ums.code
           else null end ums_code,
       case when isleaf = 1 then  ums.name
        else null end ums_name,
      :prj_id prj_id
from bcls, nmpp, cum, ums 
where bcls.mlt_id = nmpp.mlt_id (+) 
  and bcls.clf_id = nmpp.clf_id (+)
  and bcls.cls_id = nmpp.cls_id (+)
  and bcls.prj_id = nmpp.prj_id (+)
  and bcls.mlt_id = cum.mlt_id (+)
  and bcls.clf_id = cum.clf_id (+) 
  and bcls.cls_id = cum.cls_id (+)  
  and cum.cst_id (+) = 548
  and cum.ums_id = ums.ums_id (+)

order by bcls.code