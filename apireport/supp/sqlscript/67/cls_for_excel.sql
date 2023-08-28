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
       level top_level,
       clv.top_level clv_lev,
       connect_by_isleaf isleaf
from (select *
      from clv
      where clv.cfv_id = :cfv_id
        and clv.mlt_id = :mlt_id
        and clv.status <> 2) clv, cfv, prj 
where clv.cfv_id = cfv.cfv_id
  and prj.prj_id = cfv.prj_id
start with clv.mlt_id = :mlt_id
  and clv.clf_id = :clf_id
  and (clv.cls_id = :cls_id or (:cls_id = -1 AND clv.clv_clf_id is null))
  and clv.cfv_id = :cfv_id
connect by prior clv.mlt_id = clv.mlt_id
  and prior clv.cfv_id = clv.cfv_id 
  and prior clv.clf_id = clv.clv_clf_id
  and prior clv.cls_id = clv.clv_cls_id)
select bcls.mlt_id,
       bcls.clf_id,
       bcls.cls_id,
       bcls.clv_clf_id,
       bcls.clv_cls_id,
       bcls.name "Класс",
       bcls.code name30,
       bcls.code,
       bcls.cfv_id,
       bcls.prj_id,
       bcls.project_name,
       bcls.clv_lev clv_lev,
       to_number(bcls.isleaf) isleaf,
       up_pulatov.gen_shbl_cls_ns(bcls.cfv_id, bcls.mlt_id, bcls.clf_id, bcls.cls_id, nmpp.sname, 1) sname,
       up_pulatov.gen_shbl_cls_ns(bcls.cfv_id, bcls.mlt_id, bcls.clf_id, bcls.cls_id, nmpp.fname, 1) "Шаблон",
       case when isleaf = 1
            then up_pulatov.get_sdv_name_in_string(bcls.mlt_id, bcls.clf_id, bcls.cls_id, bcls.cfv_id, bcls.prj_id, 1)
            else null
       end listfname,
       case when isleaf = 1
            then up_pulatov.get_sdv_code_name_mapping(bcls.mlt_id, bcls.clf_id, bcls.cls_id, bcls.cfv_id, bcls.prj_id, 1)
            else null
       end mapfname,
       case when isleaf = 1 then ums.code
        else null end ums_code,
       case when isleaf = 1 then ums.name
        else null end "ЕИ",
       to_char(ums.ums_id) ums_id,
       (select 1 
        from dual 
        where exists (select 1 from ocl, obj
                where ocl.mlt_id = bcls.mlt_id
                  and ocl.clf_id = bcls.clf_id
                  and ocl.cls_id = bcls.cls_id
                  and ocl.mlt_id = obj.mlt_id
                  and ocl.obj_id = obj.obj_id
                  and obj.prj_id = 73
                  and obj.status = 1)) cntobj,
         :prj_id prj_id,
         :cst_id cst_id
from bcls, nmpp, cum, ums 
where bcls.mlt_id = nmpp.mlt_id (+) 
  and bcls.clf_id = nmpp.clf_id (+)
  and bcls.cls_id = nmpp.cls_id (+)
  and bcls.prj_id = nmpp.prj_id (+)
  and bcls.mlt_id = cum.mlt_id (+)
  and bcls.clf_id = cum.clf_id (+) 
  and bcls.cls_id = cum.cls_id (+)  
  and cum.cst_id (+) = :cst_id
  and cum.ums_id = ums.ums_id (+)
  and exists (select 1 from ocl, obj
                where ocl.mlt_id = bcls.mlt_id
                  and ocl.clf_id = bcls.clf_id
                  and ocl.cls_id = bcls.cls_id
                  and ocl.mlt_id = obj.mlt_id
                  and ocl.obj_id = obj.obj_id
                  and obj.prj_id = 73
                  and obj.status = 1)
order by bcls.code