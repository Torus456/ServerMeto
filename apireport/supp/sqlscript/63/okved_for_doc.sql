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
       level clv_lev,
       connect_by_isleaf list
from clv, cfv, prj 
where clv.cfv_id = cfv.cfv_id
  and prj.prj_id = cfv.prj_id
start with clv.mlt_id = :mlt_id
  and clv.clf_id = :clf_id
  and clv.cls_id = :cls_id
  and clv.cfv_id = :cfv_id
connect by prior clv.mlt_id = clv.mlt_id
  and prior clv.cfv_id = clv.cfv_id 
  and prior clv.clf_id = clv.clv_clf_id
  and prior clv.cls_id = clV.clv_cls_id),
zcls
as (select   distinct
           cls.mlt_id,
           cls.clf_id,
           cls.cls_id,
           cls.code,
           cls.name,
           connect_by_root (cls.cls_id) root_cls,
           connect_by_root (cls.clf_id) root_clf,
           level lev
    from   cls
    where   cls.mlt_id = 1
    start with   cls.mlt_id = 1
               and (cls.mlt_id, cls.clf_id, cls.cls_id) in
                      (select   bcls.mlt_id, bcls.clf_id, bcls.cls_id
                         from   bcls
                        where   bcls.list = 1
                                and bcls.mlt_id =
                                       cls.mlt_id
                                and bcls.clf_id =
                                       cls.clf_id
                                and bcls.cls_id =
                                       cls.cls_id)
  connect by       prior mlt_id = mlt_id
               and prior clf_id = clf_id
               and prior cls_id = cls_cls_id),                                                    
xcls
as (select   b.mlt_id,
             nvl (z.clf_id, b.clf_id) as clf_id,
             nvl (z.cls_id, b.cls_id) as cls_id,
             b.clf_id as clf_id_pp,
             b.cls_id as cls_id_pp,
             b.code,
             b.name,
             b.list,
             b.prj_id,
             ums.code ums_code,
             ums.name ums_name
      from   bcls b, zcls z, cum, ums
     where       b.mlt_id = z.mlt_id(+)
             and b.clf_id = z.root_clf(+)
             and b.cls_id = z.root_cls(+)
             and b.mlt_id = cum.mlt_id (+)
		     and b.clf_id = cum.clf_id (+)
		     and b.cls_id = cum.cls_id (+) 
		     and cum.cst_id (+) = :cst_id
		     and cum.ums_id = ums.ums_id (+)
		     )
select distinct xcls.mlt_id, 
       xcls.clf_id_pp clf_id, 
       xcls.cls_id_pp cls_id,
       xcls.code,
       xcls.name,
       oclp.sname,
       oclp.fname,
       TRIM(REPLACE(REGEXP_SUBSTR(okved.valchar, '.+?\-'), ' -'))  okved_code,
       TRIM(REPLACE(REGEXP_SUBSTR(okved.valchar, '\-.+$'), '- ')) okved_name,
       TRIM(REPLACE(REGEXP_SUBSTR(okdp.valchar, '.+?\-'), ' -'))  okdp_code,
       TRIM(REPLACE(REGEXP_SUBSTR(okdp.valchar, '\-.+$'), '- ')) okdp_name,
       lot.valchar lot_code,
       :prj_id prj_id,
       :cst_id
from xcls, ocl, obj, oclp, vobj okved, vobj okdp, vobj lot
where xcls.mlt_id = ocl.mlt_id
  and xcls.clf_id = ocl.clf_id
  and xcls.cls_id = ocl.cls_id
  and ocl.mlt_id = obj.mlt_id
  and ocl.obj_id = obj.obj_id
  and obj.status = 1  
  and obj.prj_id = :prj_id
  and ocl.clf_id = :inclf_id
  and xcls.prj_id = obj.prj_id
  and ocl.mlt_id = oclp.mlt_id
  and ocl.clf_id = oclp.clf_id
  and ocl.cls_id = oclp.cls_id
  and ocl.obj_id = oclp.obj_id
  and oclp.name not like '%?%'
  and oclp.prj_id = xcls.prj_id
  and obj.mlt_id = okved.mlt_id (+)
  and obj.obj_id = okved.obj_id (+)
  and okved.aobj_id (+) = 9270
  and obj.mlt_id = okdp.mlt_id (+)
  and obj.obj_id = okdp.obj_id (+)
  and okdp.aobj_id (+) = 9269
  and obj.mlt_id = lot.mlt_id (+)
  and obj.obj_id = lot.obj_id (+)
  and lot.aobj_id (+) = 9271
  and exists (select 1 from vobj 
              where obj.mlt_id = vobj.mlt_id
                and obj.obj_id = vobj.obj_id
                and vobj.aobj_id = :aobj_id)
union all
select distinct xcls.mlt_id, 
       xcls.clf_id_pp clf_id, 
       xcls.cls_id_pp cls_id,
       xcls.code,
       xcls.name,
       oclp.sname,
       oclp.fname,
       TRIM(REPLACE(REGEXP_SUBSTR(okved.valchar, '.+?\-'), ' -'))  okved_code,
       TRIM(REPLACE(REGEXP_SUBSTR(okved.valchar, '\-.+$'), '- ')) okved_name,
       TRIM(REPLACE(REGEXP_SUBSTR(okdp.valchar, '.+?\-'), ' -'))  okdp_code,
       TRIM(REPLACE(REGEXP_SUBSTR(okdp.valchar, '\-.+$'), '- ')) okdp_name,
       lot.valchar lot_code,
       :prj_id prj_id,
       :cst_id
from xcls, ocl, obj, oclp, vobj okved, vobj okdp, vobj lot
where xcls.mlt_id = ocl.mlt_id
  and xcls.clf_id = ocl.clf_id
  and xcls.cls_id = ocl.cls_id
  and ocl.mlt_id = obj.mlt_id
  and ocl.obj_id = obj.obj_id
  and obj.status = 1
  and obj.prj_id = :prj_id
  and ocl.clf_id = 6
  and obj.mlt_id = okved.mlt_id (+)
  and obj.obj_id = okved.obj_id (+)
  and okved.aobj_id (+) = 9270
  and obj.mlt_id = okdp.mlt_id (+)
  and obj.obj_id = okdp.obj_id (+)
  and okdp.aobj_id (+) = 9269
  and obj.mlt_id = lot.mlt_id (+)
  and obj.obj_id = lot.obj_id (+)
  and lot.aobj_id (+) = 9271
  and not exists (select 1
                  from ocl oclin
                  where ocl.mlt_id = oclin.mlt_id
                    and ocl.obj_id = oclin.obj_id
                    and oclin.clf_id = :inclf_id)
  and xcls.prj_id = obj.prj_id
  and ocl.mlt_id = oclp.mlt_id
  and ocl.clf_id = oclp.clf_id
  and ocl.cls_id = oclp.cls_id
  and ocl.obj_id = oclp.obj_id
  and oclp.prj_id = xcls.prj_id
  and oclp.name not like '%?%'
  and exists (select 1 from vobj 
              where obj.mlt_id = vobj.mlt_id
                and obj.obj_id = vobj.obj_id
                and vobj.aobj_id = :aobj_id)
order by code